module SYS_CTRL #(
    parameter OUT_WIDTH = 16,
             DATA_W = 8,
             DEPTH = 16,
             ADD_W = $clog2(DEPTH)
) (
    input wire CLK ,
    input wire rst_n ,
    //alu control signals 
    input wire [OUT_WIDTH-1 : 0 ]  ALU_OUT,
    input wire OUT_Valid,
    //output signals 
    output reg [3:0] ALU_FUN ,
    output reg ALU_EN,CLK_EN,

    //register file control signal 
    input wire [DATA_W-1:0] RdData,
    input wire RdData_Valid ,
    //output signals 
    output reg WrEn,RdEn,
    output reg [ADD_W-1 : 0] Address,
    output reg [DATA_W-1:0] WrData,

    //UART control signals 

    input wire [DATA_W-1 : 0] RX_P_DATA,
    input wire RX_D_VLD,
    input wire full,

    output reg  [DATA_W-1 : 0] TX_P_DATA,
    output reg  TX_D_VLD,

    output reg clk_div_en
);
    //FSM states 
    // 3 operation reaad write alu 
    // IDEAL check the first frame command and depend it the next state select
    //write opearation 0xAA 
    //RF_WR_ADDR state store the address frame in register
    //RF_WR_Data state use the stored address and the incoming frame to write in register file and assert the en 
    //in last write state go decoding ideal state 
    //RF_Rd_CMD(0xBB)
    //at RF_Rd_Addr state read the address acces the register file with address in same cycle 
    //once read valid enter send to fifo state FIFO_SENT if fifo !full 
    //return to ideal to decode the command 
    //ALU_OPER_W_OP_CMD(0xCC)
    //state operand one store dircet in register file in location 0
    //state operand two store dircet in register file in location 1
    // state third frame what include the alu fun and enable the alu 
    //state storing in fifo stuck here till fifo !full
    //ALU_OPER_W_NOP_CMD(0xDD)
    // state third frame what include the alu fun and enable the alu 
    //state storing in fifo stuck here till fifo !full

// command 
    localparam RF_Rd_CMD  ='hBB,
                RF_Wr_CMD ='hAA,
                ALU_OPER_W_OP_CMD ='hCC,
                ALU_OPER_W_NOP_CMD ='hDD;
// internal signals 
    reg [ADD_W-1 :0 ] address_comb , address_reg  ;
    reg [DATA_W-1:0] read_data_comb ,read_data_reg;
    reg [OUT_WIDTH-1:0] ALU_data_comb ,ALU_data_reg;
//state of finita state machine 
  localparam  IDEAL = 4'b0000,
            RF_WRITE_ADDRESS_ST = 4'b0001,
            RF_WRITE_DATA_ST= 4'b0011,
            RF_READ_ADDRESS_ST= 4'b0010,
            RF_FIFO_WRITE_ST= 4'b0110,
            FIFO_WAIT_STATE =4'b0100,
            ALU_OPERAND_A_ST= 4'b0101,
            ALU_OPERAND_B_ST= 4'b0111,
            ALU_FUN_ST= 4'b1111,
            ALU_DATA_ST =4'b1110,
            ALU_FIFO_LSB_ST= 4'b1100,
            ALU_FIFO_MSB_ST= 4'b1000;

    reg [3:0] current_state ,next_state ;
    
//next state and outputs logic 
        always @(*)
        begin
        ALU_FUN = 'b0;
        ALU_EN = 1'b0;
        CLK_EN = 1'b0;
        WrEn = 1'b0;
        RdEn = 1'b0;
        Address = 'b0;
        WrData = 'b0;
        TX_P_DATA = 'b0;
        TX_D_VLD = 1'b0;
        clk_div_en = 1'b1;

        address_comb =address_reg; //store the address value for write operation in next cycle 
        read_data_comb = read_data_reg ; //store the read data if the fifo is full and wait for available place
        ALU_data_comb = ALU_data_reg ;

            case (current_state)
            IDEAL :
        begin
            //the output signals are the default no change in it 
            if (RX_D_VLD) 
            begin
                if (RX_P_DATA == RF_Wr_CMD)
                next_state = RF_WRITE_ADDRESS_ST;
                else if(RX_P_DATA == RF_Rd_CMD)
                next_state = RF_READ_ADDRESS_ST ;
                else if (RX_P_DATA == ALU_OPER_W_OP_CMD)
                next_state = ALU_OPERAND_A_ST ;
                else if (RX_P_DATA == ALU_OPER_W_NOP_CMD )
                next_state = ALU_FUN_ST;
                else 
                next_state = IDEAL;
            end 
            else 
            next_state = IDEAL;
        end
        RF_WRITE_ADDRESS_ST :
        begin
            if (RX_D_VLD)
            begin
                //after store the address recieve the data
                next_state = RF_WRITE_DATA_ST ;
                address_comb = RX_P_DATA [ADD_W-1 :0 ]; //take only the address
            end 
            else 
            begin
                next_state = RF_WRITE_ADDRESS_ST;
            end 
        end
        RF_WRITE_DATA_ST: //write in register file state recieve the data 
        //and store it enable the write operation load the address and data
        begin
            if (RX_D_VLD)
            begin
                next_state = IDEAL ; //the state when the recieving decode
                WrEn = 1'b1;
                Address = address_reg;
                WrData = RX_P_DATA;
            end 
            else 
            begin
                next_state = RF_WRITE_DATA_ST;
            end 
        end
        RF_READ_ADDRESS_ST:
        begin
            if (RX_D_VLD)
            begin
                next_state = RF_FIFO_WRITE_ST ; //the state when the recieving decode
                RdEn = 1'b1;
                Address = RX_P_DATA [ADD_W-1 :0 ];
            end 
            else 
            begin
                next_state = RF_READ_ADDRESS_ST;
            end 
        end
        RF_FIFO_WRITE_ST:
        begin
            if (RdData_Valid)
            begin
                if (!full)
                begin
                TX_P_DATA = RdData;
                TX_D_VLD = 1'b1;    
                next_state = IDEAL;
                end 
                else 
                begin
                read_data_comb = RdData;
                next_state = FIFO_WAIT_STATE; 
                end 
            end
            else 
            next_state =  RF_FIFO_WRITE_ST;
        end
        FIFO_WAIT_STATE: //this will be common state for wait fifo state
        begin
            if (!full)
            begin
            TX_P_DATA = read_data_reg;
            TX_D_VLD = 1'b1;    
            next_state = IDEAL;
            end 
            else 
            begin
            next_state = FIFO_WAIT_STATE; //loop until the fifo has free space 
            end 
        end 
        ALU_OPERAND_A_ST: //store the operand a in register file 
        begin
            if (RX_D_VLD)
            begin
                next_state = ALU_OPERAND_B_ST ; //the state when the recieving decode
                WrEn = 1'b1;
                Address = 4'b0000;
                WrData = RX_P_DATA;
            end 
            else 
            begin
                next_state = ALU_OPERAND_A_ST ;
            end 
        end
        ALU_OPERAND_B_ST://store the operand b in register file location 1
        begin
            if (RX_D_VLD)
            begin
                next_state = ALU_FUN_ST ; //the state when the recieving decode
                WrEn = 1'b1;
                Address = 4'b0001;
                WrData = RX_P_DATA;
            end 
            else 
            begin
                next_state = ALU_OPERAND_B_ST ;
            end 
        end
        ALU_FUN_ST: // enable the alu 
        begin
            if (RX_D_VLD)
            begin
            ALU_FUN = RX_P_DATA [3:0];
            ALU_EN = 1'b1;
            CLK_EN = 1'b1;
            next_state = ALU_DATA_ST;
            end 
            else 
            begin
                next_state = ALU_FUN_ST;
            end 
        end
        ALU_DATA_ST:
        begin 
            CLK_EN = 1'b1; //to deassert the out_valid
            if (OUT_Valid)
            begin
                ALU_data_comb = ALU_OUT; 
                next_state = ALU_FIFO_LSB_ST;
            end 
            else 
            begin
                next_state = ALU_DATA_ST ;
            end 
        end 
        ALU_FIFO_LSB_ST:
        begin
            if (!full)
            begin 
                next_state = ALU_FIFO_MSB_ST ;
                TX_P_DATA = ALU_data_comb [DATA_W -1 : 0];
                TX_D_VLD = 1'b1;
            end 
            else 
            begin
                next_state = ALU_FIFO_LSB_ST ;
            end 
        end
        ALU_FIFO_MSB_ST:
        begin
            if (!full)
            begin 
                next_state = IDEAL ;
                TX_P_DATA = ALU_data_comb [ OUT_WIDTH-1 : DATA_W ];
                TX_D_VLD = 1'b1;
            end 
            else 
            begin
                next_state = ALU_FIFO_MSB_ST ;
            end 
        end
        default :
        begin
            next_state = current_state ; 
        end 
        endcase 
        end 

always @(posedge CLK or negedge rst_n )
begin
    if (!rst_n)
    begin
        current_state <= IDEAL ;
        address_reg <= 'b0;
        read_data_reg <= 'b0;
        ALU_data_reg <= 'b0;
    end
    else 
    begin
        current_state <= next_state ;
        address_reg <= address_comb;
        read_data_reg <= read_data_comb;
        ALU_data_reg <= ALU_data_comb; 
    end 
end 
endmodule

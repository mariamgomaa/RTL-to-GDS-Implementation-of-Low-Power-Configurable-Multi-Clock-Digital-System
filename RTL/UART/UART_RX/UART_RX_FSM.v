module UART_RX_FSM # (
    parameter EDGE_COUNTER_W = 6, //(FOR MAXIMIUM POSSIBLE prescaleE) 
    parameter BIT_COUNTER_W = 4
    )
(
    input wire clk ,rst_n,
      input wire  RX_IN,
      input wire PAR_EN,
      input wire [EDGE_COUNTER_W-1 :0] edge_cnt ,  //according to prescalele the check for state depent on it 
      input wire [BIT_COUNTER_W-1 : 0] bit_cnt,
      input wire [EDGE_COUNTER_W-1 : 0] prescale , //for example prescale =8 then the start bit take edge counter from 0 to 7 and data from 8 to 63         
      input wire par_err,strt_glitch,stp_err,

      output reg par_check_en,
      output reg desser_en,
      output reg stp_check_en,
      output reg strt_check_en,
      output reg data_sample_en,
      output reg counter_en,
      output reg data_valid 
);

// states IDLE STRTCHECK RECIEVING PARITYCHECK STOPCHECK 
    localparam IDLE         = 3'b000,
                START       = 3'b001,
                RECIEVING   = 3'b011,
                PARITY      = 3'b010,
                STOP        = 3'b110,
                ERRORCHECK   = 3'b100;

    reg [2:0] next_state ,current_state;
    reg data_valid_comb;
    //next state logic 
    always @(*)
    begin
        next_state        = current_state;
        par_check_en      = 1'b0;
        desser_en         = 1'b0;
        stp_check_en      = 1'b0;
        strt_check_en = 1'b0;
        data_sample_en    = 1'b0;
        counter_en        = 1'b0;
        
        data_valid_comb    =1'b0;
        case (current_state)
        IDLE :
        begin
            if (!RX_IN)
            begin
                next_state = START;
                    data_sample_en    = 1'b1;
                    counter_en        = 1'b1;
            end
            else 
            begin
                next_state = IDLE;
            end 
        end

        START :
        begin
        strt_check_en = 1'b1;
        data_sample_en    = 1'b1;
        counter_en        = 1'b1;
        if (bit_cnt == 0 && edge_cnt == prescale - 6'd1 )
        begin
            if (strt_glitch)
                begin
                    next_state = IDLE;
                end
            else 
            begin
                next_state = RECIEVING;
            end
        end
        else 
        next_state = START;
        end
        
        RECIEVING :
        begin
        data_sample_en    = 1'b1;
        counter_en        = 1'b1;
        desser_en         = 1'b1;
        if (bit_cnt == 8 && edge_cnt == prescale  - 6'd1)
        begin
            if (PAR_EN)
            next_state = PARITY;
            else 
            next_state = STOP;
        end
        else 
        begin
            next_state = RECIEVING;
        end
        end

        PARITY :
        begin
            par_check_en      = 1'b1;
            data_sample_en    = 1'b1;
            counter_en        = 1'b1;
            if (bit_cnt == 9 && edge_cnt == prescale  - 6'd1)
                begin
                    next_state = STOP ;
                end
            else 
                begin
                    next_state = PARITY ;
                end
        end

        STOP :
        begin
        stp_check_en      = 1'b1;
        data_sample_en    = 1'b1;
        counter_en        = 1'b1;
        if (PAR_EN)
        begin
            if (bit_cnt == 10 && edge_cnt == prescale  - 6'd2)
                begin
                    next_state = ERRORCHECK ;
                end
            else 
                begin
                    next_state = STOP ;
                end
        end
        else 
        begin
            if (bit_cnt == 9 && edge_cnt == prescale  - 6'd1)
                begin
                    next_state = ERRORCHECK ;
                end
            else 
                begin
                    next_state = STOP ;
                end
        end
        end

        ERRORCHECK:
        begin
        //NEXT STATE LOGIC 
        if (!RX_IN)
        begin
            next_state = START ;
        end
        else
        begin
            next_state = IDLE ;
        end
        //CONDITION ON THE VALID OUTPUT 
        if (par_err || stp_err)
        begin
        data_valid_comb        = 1'b0;
        end
        else 
        data_valid_comb        = 1'b1;
        end
        endcase 
    end

    //SEQUENTIAL LOGIC 
    always @(posedge clk or negedge rst_n )
    begin 
        if (!rst_n)
        begin
            current_state <= IDLE ;
            data_valid        = 1'b0;
        end
        else 
        begin
            current_state <= next_state ;
            data_valid        = data_valid_comb;
        end
    end 
endmodule
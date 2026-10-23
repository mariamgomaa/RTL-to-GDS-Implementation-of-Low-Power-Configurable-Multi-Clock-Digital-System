`timescale 1ns/1ps
module SYS_TOP_TB ();
parameter DATA_W = 8  ;
parameter ADDR_W  = 4  ;   
parameter OUT_WIDTH  =16  ;  
parameter PTR_W= 4  ;  
parameter NUMBER_STAGES =  4 ;   
parameter DEPTH =  16 ;   

reg  RST_N;
reg  UART_CLK;
reg  REF_CLK;
reg  UART_RX_IN;
wire UART_TX_O;
wire parity_error;
wire framing_error;

integer total_tests;
integer pass_tests;
integer fail_tests;

reg [DATA_W-1 : 0] alu_result_1 ,alu_result_2;


localparam WR_CMD  = 8'hAA ;   
localparam RD_CMD  = 8'hBB ;   
localparam ALU_WOP_CMD  = 8'hCC ;   
localparam ALU_WNOP_CMD = 8'hDD ;   

//design instantiation
SYS_TOP # (.DATA_W(DATA_W) ,   
            .DEPTH (DEPTH),
            .ADD_W (ADDR_W),
            .OUT_WIDTH (OUT_WIDTH) ,
            .PTR_W (PTR_W),
            .NUMBER_STAGES (NUMBER_STAGES)) 
            dut (
.UART_CLK(UART_CLK),
.REF_CLK(REF_CLK),
.RST_N(RST_N),
.UART_RX_IN(UART_RX_IN),
.UART_TX_O(UART_TX_O),
.parity_error(parity_error),
.framing_error(framing_error)
);

// clock generation 
always #10 REF_CLK = ~REF_CLK;
always #135.6335 UART_CLK =~UART_CLK;
// tasks 
task initialize ;
begin
total_tests = 0;
pass_tests  = 0;
fail_tests  = 0;
UART_CLK= 1'b0;
REF_CLK= 1'b0;
UART_RX_IN= 1'b1;
RST_N = 1'b1; 
end
endtask

task reset ;
  begin
	RST_N  = 'b0;           
	repeat (5)#(REF_CLK);
	RST_N  = 'b1;
  end
endtask
//send one bit for uart rx interface
task send_bit;
input bit_value;
begin
    UART_RX_IN = bit_value;
    @(posedge dut.u_UART_TOP.tx_clk );
end
endtask

function calculate_parity;
input [DATA_W-1:0] data;
begin
if (!dut.u_register_file.REG2[1])
calculate_parity = ^data; // even parity
else
calculate_parity = ~(^data); // odd parity
end
endfunction

task send_frame;
input [DATA_W-1:0] data;
input parity_error;
input stop_error;
reg parity_bit;
integer i;
begin
    $display("------------------------------------------------");
    $display("Sending UART frame ");
    $display("DATA = %h", data);
    @(posedge dut.u_UART_TOP.tx_clk );
    send_bit(1'b0);
    for (i = 0; i < DATA_W; i = i + 1)
        send_bit(data[i]);
    if (dut.u_register_file.REG2[0]) // parity enable send parity bit 
    begin
    parity_bit = calculate_parity(data);
    if (parity_error)
        parity_bit = ~parity_bit;
    send_bit(parity_bit);
    end 
    if (stop_error)
        send_bit(1'b0);       // wrong stop bit
    else
        send_bit(1'b1);       // correct stop bit

end
endtask
task read_register_check ;
input[DATA_W-1:0]expected_data ;
input[ADDR_W-1:0]data_address ;
 begin
    total_tests = total_tests + 1;
    repeat (2) @(posedge dut.u_UART_TOP.tx_clk );
	if(dut.u_register_file.reg_file[data_address] == expected_data)
    begin
			$display("write operation PASS for data = %h and address = %h",expected_data,data_address);
            pass_tests = pass_tests + 1;
    end
	else
    begin
			$display("write operation FAIL for data = %h and address = %h",expected_data,data_address);
            fail_tests = fail_tests + 1;
    end
 end
endtask 

task check_read_operation ;
input [ADDR_W-1:0] address ;
integer i;
reg [DATA_W-1:0] expected_data;
reg [DATA_W-1:0] data;
reg parity;
begin
    total_tests = total_tests + 1;
    expected_data = dut.u_register_file.reg_file[address];
    wait(dut.busy);
    @(posedge dut.u_UART_TOP.tx_clk );
    for (i=0 ; i<8 ;i=i+1)
    begin
        @(posedge dut.u_UART_TOP.tx_clk );
        data [i] =UART_TX_O;
    if (UART_TX_O == expected_data[i])
    begin
    $display("MATCHED bit %b with expected bit %b from address = %h",UART_TX_O,expected_data[i],address);
   
    end
	else
    begin
	$display("UNMATCHED bit %b with expected bit %b from address = %h",UART_TX_O,expected_data[i],address);
    end
    
    end 
    @(posedge dut.u_UART_TOP.tx_clk );
    if (dut.u_register_file.REG2[0]) //parity enable 
    begin
    parity = calculate_parity (expected_data);
    if (UART_TX_O == parity)
    $display("PARITY CORRECT");
	else
	$display("PARITY FAIL");
    end
    if (data == expected_data)
    begin
    $display("READ OPERATION PASS FOR DATA = %h",data);
     pass_tests = pass_tests + 1;
    end
	else
    begin
	$display("READ OPERATION FAIL FOR DATA = %h with EXPECTED = %h",data,expected_data);
    fail_tests = fail_tests + 1;
    end

end 
endtask
//task get the alu result from tx 
task read_alu_result ;
integer i;
input operand;
output [DATA_W-1:0] data;
begin
    wait(dut.busy);
    @(posedge dut.u_UART_TOP.tx_clk );
    for (i=0 ; i<8 ;i=i+1)
    begin
        @(posedge dut.u_UART_TOP.tx_clk );
        data [i] =UART_TX_O;
    end 
    @(posedge dut.u_UART_TOP.tx_clk );

    $display("READ OPERATION for alu result FOR operand %b DATA = %d",operand,data);

end 
endtask
//task for alu operation check alu_golden_model
task alu_check ;
input [DATA_W-1 : 0 ] A_tb,B_tb;
input [3:0] alu_function;
input [DATA_W*2 -1 : 0] ALU_OUT_tb ;
begin
    total_tests = total_tests + 1;
case (alu_function)
            4'b000 : 
    begin
        $display ("-----Addition test--------");
        if (A_tb +B_tb ==ALU_OUT_tb )
        begin
        $display ("Addition PASS");
         pass_tests = pass_tests + 1;
        end
        else 
        begin
        $display ("Addition FAIL");
        fail_tests = fail_tests + 1;
        end
    end 
    4'b0001 :
    begin
        $display ("-----Subtraction test--------");
        if (A_tb  - B_tb == ALU_OUT_tb )
        begin
        $display ("SUB PASS");
         pass_tests = pass_tests + 1;
        end
        else
        begin 
        $display ("SUB FAIL");
        fail_tests = fail_tests + 1;
        end
    end
    4'b0010:
    begin
        $display ("-----Multiblacation test--------");
        if (ALU_OUT_tb == A_tb * B_tb )
        begin
        $display ("Multiblacation PASS");
        pass_tests = pass_tests + 1;
        end
        else  begin
        $display ("Multiblacation FAIL");
        fail_tests = fail_tests + 1;
        end
    end
    4'b0011:
    begin
        $display ("-----Division test--------");
        if(B_tb!=0)
        begin
        if (ALU_OUT_tb == A_tb / B_tb ) begin
        $display ("Division PASS");
        pass_tests = pass_tests + 1;
        end
        else begin 
        $display ("Division FAIL");
        fail_tests = fail_tests + 1;
        end
        end 
        else if (B_tb == 0)
        begin
        if (ALU_OUT_tb == 0 )
        begin
        $display ("Division PASS");
        pass_tests = pass_tests + 1;
        end
        else begin
        $display ("Division FAIL");
        fail_tests = fail_tests + 1;
        end
        end 
    end 
    //logical operation 
    4'b0100:
    begin
        $display ("-----Anding test--------");
        if (ALU_OUT_tb == (A_tb & B_tb) )
        begin
        $display ("Anding PASS");
        pass_tests = pass_tests + 1;
        end
        else
        begin 
        $display ("Anding FAIL");
        fail_tests = fail_tests + 1;
        end
    end 
    4'b0101:
    begin
        $display ("-----Oring test--------");
        if (ALU_OUT_tb == (A_tb | B_tb) )
        begin
        $display ("Oring PASS");
        pass_tests = pass_tests + 1;
        end
        else begin 
        $display ("Oring FAIL");
        fail_tests = fail_tests + 1;
        end
    end 
    4'b0110:
    begin
        $display ("-----NAND test--------");
        if (ALU_OUT_tb == ~(A_tb & B_tb) )
        begin
        $display ("NAND PASS");
        pass_tests = pass_tests + 1;
        end
        else begin 
        $display ("NAND FAIL");
        fail_tests = fail_tests + 1;
        end
    end 
    4'b0111:
    begin
        $display ("-----NOR test--------");
        if (ALU_OUT_tb == ~(A_tb | B_tb) )
        begin
        $display ("NOR PASS");
        pass_tests = pass_tests + 1;
        end
        else begin 
        $display ("NOR FAIL");
        fail_tests = fail_tests + 1;
        end
    end 
    4'b1000:
    begin
        $display ("-----XOR test--------");
        if (ALU_OUT_tb == (A_tb ^ B_tb))
        begin
        $display ("XOR PASS");
        pass_tests = pass_tests + 1;
    end
        else
        begin 
        $display ("XOR FAIL");
        fail_tests = fail_tests + 1;
        end
    end 
    4'b1001:
    begin
        $display ("-----XNOR test--------");
        if (ALU_OUT_tb == ~(A_tb ^ B_tb) )
        begin
        $display ("XNOR PASS");
        pass_tests = pass_tests + 1;
        end
        else 
        begin
        $display ("XNOR FAIL");
        fail_tests = fail_tests + 1;
        end
    end

    4'b1010:
    begin
        $display ("-----Equality test--------");
        if ((A_tb == B_tb) && (ALU_OUT_tb) )
       begin
        $display ("Equality PASS");
        pass_tests = pass_tests + 1;
       end
        else if ((A_tb != B_tb) && (!ALU_OUT_tb) )
        begin
        $display ("Equality PASS");
        pass_tests = pass_tests + 1;
        end
        else 
        begin
        $display ("Equality FAIL");
        fail_tests = fail_tests + 1;
        end
    end
    4'b1011:
    begin
        $display ("-----Greater than test--------");
        if ((A_tb > B_tb) && (ALU_OUT_tb==2) )
        begin
        $display ("Greater than PASS");
        pass_tests = pass_tests + 1;
        end
        else if ((A_tb < B_tb) && (ALU_OUT_tb==0) )
        begin
        $display ("Greater than  PASS");
        pass_tests = pass_tests + 1;
        end
        else 
        begin
        $display ("Greater than FAIL");
        fail_tests = fail_tests + 1;
        end
    end

    4'b1100:
    begin
        $display ("-----smaller than test--------");
        if ((A_tb < B_tb) && (ALU_OUT_tb==3) )
        begin
        $display ("smaller than PASS");
        pass_tests = pass_tests + 1;
        end
        else if ((A_tb > B_tb) && (ALU_OUT_tb==0) )
        begin
        $display ("smaller than  PASS");
        pass_tests = pass_tests + 1;
        end
        else
        begin 
        $display ("smaller FAIL");
        fail_tests = fail_tests + 1;
        end
    end
    4'b1101: 
    begin 
        $display ("-----Shift right test--------");
        if (ALU_OUT_tb == A_tb >> 1)
        begin
        $display ("Shift right  PASS");
        pass_tests = pass_tests + 1;
        end
        else 
        begin
        $display ("Shift right  FAIL");
        fail_tests = fail_tests + 1;
        end
    end 
    4'b1110: 
    begin 
        $display ("-----Shift left test--------");
        if (ALU_OUT_tb == A_tb << 1)
        begin
        $display ("Shift left  PASS");
        pass_tests = pass_tests + 1;
        end
        else 
        begin
        $display ("Shift left  FAIL");
        fail_tests = fail_tests + 1;
        end 
    end 
    default :
       if (ALU_OUT_tb == 0 )
       begin
       $display ("NOP PASS");
       pass_tests = pass_tests + 1;
       end
       else 
      begin
        $display ("NOP FAIL");
        fail_tests = fail_tests + 1;
      end
    endcase 
end 
endtask


initial
 begin
 // Initialization
 initialize() ;
#(REF_CLK) ;
 reset() ; 
#(REF_CLK) ; 

//test cases write using default configration then read then alu operation 
//send three frames one for write command and one for address and one for data 
// address command WR_CMD  8'h05 data 8'h11
$display("*****************TRET SECNARIOS FOR PRESCALE 32 AND PARITY ENABLE AND EVEN PARITY *********************");
$display ("--------TEST CASE 1 WRITE OPERATION FOR PRESCALLE 32--------- ");
   
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h05,1'b0 ,1'b0);
  send_frame(8'h79,1'b0 ,1'b0);
  //read register file 
  read_register_check(8'h79,4'h5) ;
   
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h06,1'b0 ,1'b0);
  send_frame(8'h68,1'b0 ,1'b0);
  //read register file 
  read_register_check(8'h68,4'h6) ;
  
  //test case 2 
  $display ("-------TEST CASE 2 READ OPERATION FOR PRESCALLE 32 ------------");
   
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h07,1'b0 ,1'b0);
  send_frame(8'h22,1'b0 ,1'b0);
  send_frame(RD_CMD , 1'b0 ,1'b0);
  send_frame(8'h07,1'b0 ,1'b0);
  check_read_operation(8'h07);
  //test case 3 alu operation with operand 
  $display ("-------TEST CASE 3 ALU WITH OPERAND (ADDITION 3+4=7)OPERATION FOR PRESCALLE 32 ------------");
   
  send_frame(ALU_WOP_CMD , 1'b0 ,1'b0);
  send_frame(8'h03,1'b0 ,1'b0);
  send_frame(8'h04,1'b0 ,1'b0);
  send_frame(8'b00 , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b0000,{alu_result_2,alu_result_1});
    //test case 4 alu operation without operand 
  $display ("-------TEST CASE 3 ALU WITHout OPERAND (multibly 10*5=50)OPERATION FOR PRESCALLE 32 ------------");
   
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h00,1'b0 ,1'b0);
  send_frame(8'h0A,1'b0 ,1'b0);
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h01,1'b0 ,1'b0);
  send_frame(8'h05,1'b0 ,1'b0);
  send_frame(ALU_WNOP_CMD , 1'b0 ,1'b0);
  $display ("send multiblication operation code");
  send_frame(8'h02 , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b0010,{alu_result_2,alu_result_1});
 @(posedge dut.u_UART_TOP.tx_clk );


$display("***************TRET SECNARIOS FOR PRESCALE 16 AND with PARITY AND ODD PARITY ********************");
$display ("--------TEST CASE 4 WRITE OPERATION FOR PRESCALLE 16--------- ");
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h02,1'b0 ,1'b0);
  send_frame(8'b01000011,1'b0 ,1'b0);//parity disable and prescalle 16 
 
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h08,1'b0 ,1'b0);
  send_frame(8'h34,1'b0 ,1'b0);
  //read register file 
  read_register_check(8'h34,4'h8) ;
  
  //test case 2 
  $display ("-------TEST CASE 5 READ OPERATION FOR PRESCALLE 16 ------------");
   
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h09,1'b0 ,1'b0);
  send_frame(8'h11,1'b0 ,1'b0);
  send_frame(RD_CMD , 1'b0 ,1'b0);
  send_frame(8'h09,1'b0 ,1'b0);
  check_read_operation(8'h09);
  //test case 3 alu operation with operand 
  $display ("-------TEST CASE 6 ALU WITH OPERAND (multiblication 12*12=144)OPERATION FOR PRESCALLE 16 ------------");
   
  send_frame(ALU_WOP_CMD , 1'b0 ,1'b0);
  send_frame(8'b00001100,1'b0 ,1'b0);// 00001100
  send_frame(8'b00001100,1'b0 ,1'b0);
  send_frame(8'h02 , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b0010,{alu_result_2,alu_result_1});
    //test case 4 alu operation without operand 
  $display ("-------TEST CASE 7 ALU WITHout OPERAND (division 12/12=1)OPERATION FOR PRESCALLE 16 ------------");
   
  send_frame(ALU_WNOP_CMD , 1'b0 ,1'b0);
  send_frame(8'h03 , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b0011,{alu_result_2,alu_result_1});

  $display("***************TRET SECNARIOS FOR PRESCALE 16 AND without PARITY ********************");
$display ("--------TEST CASE 8 WRITE OPERATION FOR PRESCALLE 16--------- ");
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h02,1'b0 ,1'b0);
  send_frame(8'b01000000,1'b0 ,1'b0);//parity disable and prescalle 16 
 
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h09,1'b0 ,1'b0);
  send_frame(8'h12,1'b0 ,1'b0);
  //read register file 
  read_register_check(8'h12,4'h9) ;
  
  //test case 2 
  $display ("-------TEST CASE 9 READ OPERATION FOR PRESCALLE 16 without parity  ------------");
   
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h0A,1'b0 ,1'b0);
  send_frame(8'h22,1'b0 ,1'b0);
  send_frame(RD_CMD , 1'b0 ,1'b0);
  send_frame(8'h0A,1'b0 ,1'b0);
  check_read_operation(8'h0A);
  //test case 3 alu operation with operand 
  $display ("-------TEST CASE 10 ALU WITH OPERAND (multiblication 20*15=300)OPERATION FOR PRESCALLE 16 ------------");
   
  send_frame(ALU_WOP_CMD , 1'b0 ,1'b0);
  send_frame(8'b00010100,1'b0 ,1'b0);// 00001100
  send_frame(8'b00001111,1'b0 ,1'b0);
  send_frame(8'h02 , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b0010,{alu_result_2,alu_result_1});
    //test case 4 alu operation without operand 
  $display ("-------TEST CASE 4 ALU WITHout OPERAND (equality)OPERATION FOR PRESCALLE 16 without parity  ------------");
   
  send_frame(ALU_WNOP_CMD , 1'b0 ,1'b0);
  send_frame(8'h0A , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b1010,{alu_result_2,alu_result_1});

  $display("***************TRET SECNARIOS FOR PRESCALE 8 AND without PARITY ********************");
$display ("--------TEST CASE 11 WRITE OPERATION FOR PRESCALLE 8--------- ");
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h02,1'b0 ,1'b0);
  send_frame(8'b00100000,1'b0 ,1'b0);//parity disable and prescalle 16 
 
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h0A,1'b0 ,1'b0);
  send_frame(8'h56,1'b0 ,1'b0);
  //read register file 
  read_register_check(8'h56,4'hA) ;
  
  //test case 2 
  $display ("-------TEST CASE 12 READ OPERATION FOR PRESCALLE 8 without parity  ------------");
   
  send_frame(WR_CMD , 1'b0 ,1'b0);
  send_frame(8'h0B,1'b0 ,1'b0);
  send_frame(8'h78,1'b0 ,1'b0);
  send_frame(RD_CMD , 1'b0 ,1'b0);
  send_frame(8'h0B,1'b0 ,1'b0);
  check_read_operation(8'h0B);
  //test case 3 alu operation with operand 
  $display ("-------TEST CASE 12 ALU WITH OPERAND (and OPERATION FOR PRESCALLE 8 ------------");
   
  send_frame(ALU_WOP_CMD , 1'b0 ,1'b0);
  send_frame(8'b00010100,1'b0 ,1'b0);// 00001100
  send_frame(8'b00001111,1'b0 ,1'b0);
  send_frame(8'h04 , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b0100,{alu_result_2,alu_result_1});
    //test case 4 alu operation without operand 
  $display ("-------TEST CASE 3 ALU WITHout OPERAND (OR)OPERATION FOR PRESCALLE 8 without parity  ------------");
   
  send_frame(ALU_WNOP_CMD , 1'b0 ,1'b0);
  send_frame(8'h05 , 1'b0 ,1'b0);
  read_alu_result(0,alu_result_1);
  @(posedge dut.u_UART_TOP.tx_clk );
  read_alu_result(1,alu_result_2);
  alu_check(dut.u_register_file.reg_file[0],dut.u_register_file.reg_file[1],4'b0101,{alu_result_2,alu_result_1});
#4000


$display("");
$display("================================================");
$display("                TEST SUMMARY");
$display("================================================");
$display("TOTAL TESTS : %0d", total_tests);
$display("PASSED      : %0d", pass_tests);
$display("FAILED      : %0d", fail_tests);

if (fail_tests == 0)
    $display("RESULT      : ALL TESTS PASSED");
else
    $display("RESULT      : SOME TESTS FAILED");

$display("================================================");


$stop ;

end


endmodule

module SYS_TOP_dft # ( parameter DATA_W = 8 ,
                   DEPTH = 16,
                   ADD_W = $clog2(DEPTH),
                   OUT_WIDTH = 16 ,
                    PTR_W= 4,
                   NUMBER_STAGES =  4,
                   NUM_OF_CHAINS = 3
 )

(

input  wire                        scan_clk ,
input  wire                        scan_rst ,
input  wire                        test_mode ,
input  wire            [NUM_OF_CHAINS-1:0]            SI ,
input  wire                    SE ,
output wire             [NUM_OF_CHAINS-1:0]               SO ,
 input   wire RST_N,
 input   wire UART_CLK,
 input   wire REF_CLK,
 input   wire UART_RX_IN,
 output  wire UART_TX_O,
 output  wire parity_error,
 output  wire framing_error
);


wire sync_ref_rst_n;
wire sync_uart_rst_n;
//uart rx
wire rx_clk;
wire[DATA_W-1:0]  RX_Division_Ratio;					   
wire  [DATA_W-1:0]RX_P_DATA;
wire  UART_RX_data_valid;
wire [DATA_W-1:0]RX_P_DATA_SYNC;
wire UART_RX_data_valid_SYNC;
//register file signals 
wire [DATA_W-1 :0 ] UART_Config;
wire [DATA_W-1:0] DivRatio;

//uart tx signals 
wire [DATA_W-1:0]TX_P_DATA_IN;
wire [DATA_W-1:0]TX_P_DATA;
wire empty;
wire tx_clk;
wire busy;	
wire busy_pulse;	
wire full;
wire TX_D_VLD;

//control unit signals 
wire CLK_EN;
wire [DATA_W-1:0] RdData;
wire RdData_Valid;
wire WrEn;
wire RdEn;
wire [ADD_W-1 : 0] Address;
wire [DATA_W-1:0]  WrData;
wire clk_div_en;

//alu signals 
wire [DATA_W -1 :0] A,B;
wire [3:0] ALU_FUN;
wire ALU_EN;
wire [OUT_WIDTH-1:0 ] ALU_OUT;
wire ALU_OUT_VALID;
wire alu_clk;

wire ref_scan_fun_clk,uart_scan_fun_clk;
wire scan_fun_rst;
wire tx_clk_div, rx_clk_div, alu_clk_gated;			
wire sync_ref_rst_n_int, sync_uart_rst_n_int;
//muxes for the input clk for refernce and uart and rst 					   
    mux2X1 U0_REF_clk_mux (
        .IN_0(REF_CLK),
        .IN_1(scan_clk),
        .SEL(test_mode),
        .OUT(ref_scan_fun_clk)
);
    mux2X1 U0_UART_clk_mux (
        .IN_0(UART_CLK),
        .IN_1(scan_clk),
        .SEL(test_mode),
        .OUT(uart_scan_fun_clk)
);

    mux2X1 U0_rst_mux (
        .IN_0(RST_N),
        .IN_1(scan_rst),
        .SEL(test_mode),
        .OUT(scan_fun_rst)
);
//muxes to control generated clocks 
mux2X1 U0_TX_clk_mux  (.IN_0(tx_clk_div),    .IN_1(scan_clk), .SEL(test_mode), .OUT(tx_clk));
mux2X1 U0_RX_clk_mux  (.IN_0(rx_clk_div),    .IN_1(scan_clk), .SEL(test_mode), .OUT(rx_clk));
mux2X1 U0_ALU_clk_mux (.IN_0(alu_clk_gated), .IN_1(scan_clk), .SEL(test_mode), .OUT(alu_clk));
//muxes to control synchronace reset 
mux2X1 U1_ref_rst_mux  (.IN_0(sync_ref_rst_n_int),  .IN_1(scan_rst),
                        .SEL(test_mode), .OUT(sync_ref_rst_n));
mux2X1 U1_uart_rst_mux (.IN_0(sync_uart_rst_n_int), .IN_1(scan_rst),
                        .SEL(test_mode), .OUT(sync_uart_rst_n));

//without the generated and synchronous reset and clock the coverage will be very small

// alu insatantiation 
ALU  #(.OP_WIDTH (DATA_W),
       .OUT_WIDTH (OUT_WIDTH))
    u_ALU
    (
    .A(A),
    .B(B),
    .ALU_FUN(ALU_FUN),
    .CLK(alu_clk),
    .RST_N(sync_ref_rst_n),
    .EN(ALU_EN),
    .ALU_OUT(ALU_OUT),
    .ALU_OUT_VALID(ALU_OUT_VALID) 
    );		
//system control instantiation 
SYS_CTRL #(
    .OUT_WIDTH (OUT_WIDTH),
    .DATA_W (DATA_W),
    .DEPTH (DEPTH),
    .ADD_W (ADD_W)
)u_SYS_CTRL(
    .CLK(ref_scan_fun_clk) ,
    .rst_n(sync_ref_rst_n) ,
    .ALU_OUT(ALU_OUT),
    .OUT_Valid(ALU_OUT_VALID),
    .ALU_FUN (ALU_FUN),
    .ALU_EN(ALU_EN),
    .CLK_EN(CLK_EN),
    .RdData(RdData),
    .RdData_Valid(RdData_Valid) ,
    .WrEn(WrEn),
    .RdEn(RdEn),
    .Address(Address),
    .WrData(WrData),

    .RX_P_DATA(RX_P_DATA_SYNC),
    .RX_D_VLD(UART_RX_data_valid_SYNC),
    .full(full),

    .TX_P_DATA(TX_P_DATA),
    .TX_D_VLD(TX_D_VLD),

    .clk_div_en(clk_div_en)
);

/////asynchronous fifo 


ASYNC_FIFO #(
    .DATA_BUS_WIDTH( DATA_W),
    .FIFO_DEPTH(8),
    .ADD_W (3),
    .PTR_W (PTR_W)
) u_asynch_fifo(
    .w_clk(ref_scan_fun_clk),
    .r_clk(tx_clk),
    .w_rst(sync_ref_rst_n),
    .r_rst(sync_uart_rst_n),
    .w_inc(TX_D_VLD),
    .r_inc(busy_pulse),
    .wr_data(TX_P_DATA),

    .rd_data(TX_P_DATA_IN),
    .empty(empty),
    .full(full)
);


//////pulse generator 

PULSE_GEN u_PULSE_GEN(
.clk(tx_clk),
.rst_n(sync_uart_rst_n),
.sig_in(busy),
.pulse(busy_pulse)
);

//rst synchronizer 

RST_SYNCH #(.NUMBER_STAGES(NUMBER_STAGES)) u_RST_SYNCH_REF (
    .CLK(ref_scan_fun_clk), .RST(scan_fun_rst),
    .SYNCH_RST(sync_ref_rst_n_int));

RST_SYNCH #(.NUMBER_STAGES(NUMBER_STAGES)) u_RST_SYNCH_uart (
    .CLK(uart_scan_fun_clk), .RST(scan_fun_rst),
    .SYNCH_RST(sync_uart_rst_n_int));


///data synchronizer 
DATA_SYNC #(
    .NUM_STAGES (4) ,
    .BUS_WIDTH (DATA_W) 
    
)u_DATA_SYNC(
    .CLK(ref_scan_fun_clk),
    .RST_n(sync_ref_rst_n),
    .unsync_bus(RX_P_DATA) ,
    .bus_enable(UART_RX_data_valid),
    .sync_bus(RX_P_DATA_SYNC),
    .enable_pulse(UART_RX_data_valid_SYNC)
);
//register file 
Register_File #(.DATA_W (DATA_W), 
        .DEPTH(DEPTH),
        .ADD_W(ADD_W))
 u_register_file (
    .WrData(WrData) ,
    .Address(Address),
    .CLK (ref_scan_fun_clk),
    .RST (sync_ref_rst_n),
    .WrEn(WrEn),
    .RdEn(RdEn),
    .RdData(RdData),
    .RdData_Valid(RdData_Valid),
    .REG0 (A),
    .REG1 (B),
    .REG2(UART_Config),
    .REG3(DivRatio)
);

//clock divider for tx


CLKDiv #(.DIVIDE_RATIO_W (8))
u_CLKDiv_tx
(
   .i_ref_clk(uart_scan_fun_clk),
   .i_rst_n(sync_uart_rst_n),
   .i_clk_en(clk_div_en),
   .i_div_ratio(DivRatio),

   .o_div_clk(tx_clk_div)
);

CLKDIV_MUX u_CLKDIV_MUX (
.IN(UART_Config[7:2]),
.OUT(RX_Division_Ratio)
);

//clock divider for rx
CLKDiv #(.DIVIDE_RATIO_W (8))
u_CLKDiv_rx
(
   .i_ref_clk(uart_scan_fun_clk),
   .i_rst_n(sync_uart_rst_n),
   .i_clk_en(clk_div_en),
   .i_div_ratio(RX_Division_Ratio),

   .o_div_clk(rx_clk_div)
);

//clock gating 
CLOCK_GATE u_CLOCK_GATE (
.EN(CLK_EN),
.CLK(ref_scan_fun_clk),
.CLK_Gate(alu_clk_gated)
);


//uart top 
UART_TOP #(
    .EDGE_COUNTER_W (6), 
    .BIT_COUNTER_W (4),
    .OVERSAMPLE    ( 2) ,
    .FRAME_W      (DATA_W)
)  u_UART_TOP 
(
    //common signals
    .rst_n(sync_uart_rst_n),
    .PAR_TYPE(UART_Config[1]),
    .PAR_EN(UART_Config[0]),
    .rx_clk(rx_clk),
    .RX_IN(UART_RX_IN),
    .prescale(UART_Config[7:2]),
    //output signals 
    .data_valid(UART_RX_data_valid),
    .par_err(parity_error),
    .stp_err(framing_error),
    .RX_P_DATA(RX_P_DATA),
    .TX_P_DATA(TX_P_DATA_IN),
    .tx_clk(tx_clk),
    .DATA_VALID(!empty),// !empty
    .busy(busy),
    .TX_out(UART_TX_O)
);

endmodule
 
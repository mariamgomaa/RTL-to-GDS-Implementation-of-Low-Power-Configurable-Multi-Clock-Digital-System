
module UART_TOP #(
    parameter EDGE_COUNTER_W = 6, 
    parameter BIT_COUNTER_W = 4,
    parameter OVERSAMPLE     = 2 ,
    parameter FRAME_W      = 8
) 
(
    //common signals
    input wire rst_n,
    input wire PAR_TYPE,
    input wire PAR_EN,

    //rx input output signals 
    //input signals 
    input wire rx_clk,
    input wire RX_IN,
    input wire [EDGE_COUNTER_W-1 : 0 ] prescale,
    //output signals 
    output wire data_valid,
    output wire par_err,
    output wire stp_err,
    output wire [FRAME_W-1 : 0 ] RX_P_DATA,

    //tx sinput output signals 
    //input signals 
    input wire [FRAME_W-1 : 0] TX_P_DATA,
    input wire tx_clk,
    input wire DATA_VALID,// !empty
    //output signals 
    output  busy,
    output  TX_out
);

UART_RX_TOP #(
    .EDGE_COUNTER_W(EDGE_COUNTER_W), 
    .BIT_COUNTER_W(BIT_COUNTER_W),
    .OVERSAMPLE    (OVERSAMPLE) ,
    .FRAME_W      (FRAME_W)
)
u_UART_RX_TOP
(
    .clk(rx_clk),
    .rst_n(rst_n),
    .PAR_EN(PAR_EN),
    .PAR_TYPE(PAR_TYPE) ,
    .RX_IN(RX_IN),
    .prescale(prescale),
    
    .data_valid(data_valid),
    .par_err(par_err),
    .stp_err(stp_err),
    .P_DATA(RX_P_DATA)
);

UART_TX_TOP #(
    .DATA_W(FRAME_W),
    .COUNTER_W (BIT_COUNTER_W)
) 
u_UART_TX_TOP
(
    .P_DATA(TX_P_DATA),
    .clk(tx_clk),
    .rst_n(rst_n),
    .PAR_EN(PAR_EN),
    .PAR_TYPE(PAR_TYPE),
    .DATA_VALID(DATA_VALID),
    .busy(busy),
    .TX_out(TX_out)
);
endmodule 






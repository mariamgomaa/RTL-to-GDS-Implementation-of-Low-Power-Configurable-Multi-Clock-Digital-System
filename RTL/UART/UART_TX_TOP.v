module UART_TX_TOP #(
    parameter DATA_W = 8,
    parameter  COUNTER_W = 4
) (
    input wire [DATA_W-1 : 0] P_DATA,
    input wire clk,
    input wire rst_n,
    input wire PAR_EN,
    input wire PAR_TYPE,
    input wire DATA_VALID,
    output  busy,
    output  TX_out
);
    wire ser_done;
    wire [1:0] mux_s;
    wire ser_en;
    wire ser_data;
    wire parity ;

    FSM u_fsm(
    .clk(clk),
    .rst_n(rst_n),
    .DATA_VALID(DATA_VALID),
    .ser_done(ser_done),
    
    .PAR_EN(PAR_EN),

    .mux_s(mux_s),
    .ser_en(ser_en),
    .busy(busy)
);
serializer #(
    .DATA_W(DATA_W),
    .COUNTER_W(COUNTER_W)
) u_serializer (
    .P_DATA(P_DATA),
    .ser_en(ser_en),
    .clk(clk),
    .rst_n(rst_n),
    .ser_done(ser_done),
    .DATA_VALID(DATA_VALID),
    .ser_data (ser_data)
);

Parity #(
    .DATA_W (DATA_W)
) u_Parity (
    .P_DATA(P_DATA),
    .clk(clk),
    .PAR_TYPE(PAR_TYPE),
    .rst_n(rst_n),
    .DATA_VALID(DATA_VALID),
    .parity(parity) 
);

MUX u_MUX (
    .ser_data(ser_data),
    .parity (parity) ,
    .mux_s(mux_s),
    .TX_out(TX_out)

);

endmodule

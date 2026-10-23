module UART_RX_TOP #(
    parameter EDGE_COUNTER_W = 6, 
    parameter BIT_COUNTER_W = 4,
    parameter OVERSAMPLE     = 2 ,
    parameter FRAME_W      = 8
) (
    input wire clk,
    input wire rst_n,
    input wire PAR_EN,
    input wire PAR_TYPE ,
    input wire RX_IN,
    input wire [EDGE_COUNTER_W-1 : 0 ] prescale,
    
    output wire data_valid,
    output wire par_err,
    output wire stp_err,
    output wire [FRAME_W-1 : 0 ] P_DATA
);
    //internal wires 
    //wires for fsm signals
    wire [EDGE_COUNTER_W-1 : 0] edge_cnt;
    wire [BIT_COUNTER_W-1 : 0] bit_cnt;
    wire strt_glitch;
    wire par_check_en;
    wire desser_en ;
    wire stp_check_en;
    wire strt_check_en;
    wire data_sample_en;
    wire counter_en;
    //wires for data sampling unit 
    wire sampled_bit ;

    //module instantiation 
    UART_RX_FSM # (
    .EDGE_COUNTER_W(EDGE_COUNTER_W), 
    .BIT_COUNTER_W (BIT_COUNTER_W)
    )
    u_UART_RX_FSM
(
    .clk (clk),
    .rst_n(rst_n),
    .PAR_EN(PAR_EN),
    .RX_IN(RX_IN),
    .edge_cnt(edge_cnt) ,  
    .bit_cnt(bit_cnt),
    .prescale (prescale), 
    .par_err(par_err),
    .strt_glitch(strt_glitch),
    .stp_err(stp_err),

    .par_check_en(par_check_en),
    .desser_en(desser_en),
    .stp_check_en(stp_check_en),
    .strt_check_en(strt_check_en),
    .data_sample_en(data_sample_en),
    .counter_en(counter_en),
    .data_valid(data_valid) 
);

deserializer #(
    .EDGE_COUNTER_W (EDGE_COUNTER_W),
    .FRAME_W(FRAME_W)
)
u_deserializer
(
    .clk(clk) ,
    .rst_n(rst_n) ,
    .desser_en(desser_en),
    .sampled_bit(sampled_bit) ,
    .prescale(prescale) ,
    .edge_cnt(edge_cnt),

    .P_DATA(P_DATA)
);

data_sampling #(
    .EDGE_COUNTER_W(EDGE_COUNTER_W), 
    .OVERSAMPLE (OVERSAMPLE)
) 
u_data_sampling
(
    .clk (clk),
    .rst_n(rst_n),
    .RX_IN(RX_IN),
    .edge_cnt(edge_cnt) ,  
    .prescale (prescale), 
    .data_sample_en(data_sample_en),

    .sampled_bit(sampled_bit)
);

edge_bit_counter #(
    .EDGE_COUNTER_W(EDGE_COUNTER_W), 
    .BIT_COUNTER_W (BIT_COUNTER_W)
) 
u_edge_bit_counter
(
    .clk (clk),
    .rst_n(rst_n),
    .counter_en(counter_en),
    .prescale (prescale), 
    .PAR_EN (PAR_EN),
    .edge_cnt(edge_cnt) , 
    .bit_cnt(bit_cnt)
);

parity_check #(
.FRAME_W (FRAME_W),
.BIT_COUNTER_W (BIT_COUNTER_W),
.EDGE_COUNTER_W (EDGE_COUNTER_W)
)
u_parity_check
(
    .clk (clk),
    .rst_n(rst_n),
    .P_DATA(P_DATA),
    .sampled_bit(sampled_bit) ,
    .par_check_en(par_check_en),
    .prescale (prescale),
    .PAR_TYPE(PAR_TYPE), 
    .bit_cnt(bit_cnt),
    .edge_cnt(edge_cnt) , 
    .par_err(par_err)
);

stop_check  #(.EDGE_COUNTER_W (EDGE_COUNTER_W),.BIT_COUNTER_W (BIT_COUNTER_W))
u_stop_check
(
    .clk (clk),
    .rst_n(rst_n),
    .sampled_bit(sampled_bit) ,
    .stp_check_en(stp_check_en),
        .prescale (prescale), 
.bit_cnt(bit_cnt),
    .edge_cnt(edge_cnt) , 
    .stp_err(stp_err)
);

strt_check u_strt_check (
    .sampled_bit(sampled_bit) ,
    .strt_check_en(strt_check_en),

    .strt_glitch(strt_glitch)
);

endmodule
module deserializer #
(
    parameter EDGE_COUNTER_W = 6,
    parameter FRAME_W = 8
)
(
    input wire clk ,
    input wire rst_n ,
    input wire desser_en,
    input wire sampled_bit ,
    input wire [EDGE_COUNTER_W-1 : 0] prescale ,
    input wire [EDGE_COUNTER_W-1 : 0] edge_cnt,

    output reg  [FRAME_W-1 : 0 ] P_DATA
);
    reg [FRAME_W-1 : 0 ] P_DATA_reg ;

    always @(*)
    begin
    P_DATA_reg = P_DATA;
        if (desser_en)
        begin
            if (edge_cnt == prescale-1 )
            P_DATA_reg = {sampled_bit,P_DATA_reg[FRAME_W-1 : 1]};
        end
    end
    //1010 0101 
    // 0000 0000  --> 1 0000 000  --> 0 100 0000 --> 1 010 0000 --> 0 101 0100 --> 0 010 100 --> 1 01010100 -->0 1010100 --> 1010 0101
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            P_DATA <= 'b0;
        end
        else 
        begin
            P_DATA <= P_DATA_reg;
        end
    end
endmodule
module edge_bit_counter #(
    parameter EDGE_COUNTER_W = 6, 
    parameter BIT_COUNTER_W = 4
) (
    input wire clk ,
    input wire rst_n,
    input wire PAR_EN,
    input wire counter_en,
    input wire [EDGE_COUNTER_W-1 : 0] prescale,

    output reg  [EDGE_COUNTER_W-1 : 0] edge_cnt ,
    output reg  [BIT_COUNTER_W-1 : 0 ] bit_cnt 
);
        reg [EDGE_COUNTER_W-1 : 0] edge_cnt_reg;
        reg  [BIT_COUNTER_W-1 : 0]  bit_cnt_reg;
        reg [EDGE_COUNTER_W-1:0] prescale_prev;
        reg PAR_EN_prev;
    always @(*)
    begin
    edge_cnt_reg = edge_cnt;
    bit_cnt_reg = bit_cnt ;
        if ((prescale != prescale_prev) ||(PAR_EN != PAR_EN_prev) ) 
        begin
        edge_cnt_reg = 'b0;
        bit_cnt_reg = 'b0;
        end
        else if (counter_en)
        begin
            if (edge_cnt_reg == prescale - 6'd1 )
            begin
            edge_cnt_reg = 6'd0;
            if (PAR_EN)
                begin
                    if (bit_cnt_reg == 4'd 10 )
                    bit_cnt_reg = 4'd0;
                    else 
                    bit_cnt_reg = bit_cnt_reg + 4'd1 ;
                end
            else 
                begin
                    if (bit_cnt_reg == 4'd 9 )
                    bit_cnt_reg = 4'd0;
                    else 
                    bit_cnt_reg = bit_cnt_reg + 4'd1 ;
                end
            end
            else 
            begin
                edge_cnt_reg = edge_cnt_reg + 6'd1;
            end
        end
    end 

    always @(posedge clk or negedge rst_n) 
    begin
        if (!rst_n)
        begin
            edge_cnt <= 'b0 ;
            bit_cnt <= 'b0 ;
        end
        else 
        begin
            edge_cnt <= edge_cnt_reg;
            bit_cnt <= bit_cnt_reg ;
        end
    end
   
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prescale_prev <= 'b0;
        PAR_EN_prev <= 'b0;
    end
    else begin
        prescale_prev <= prescale;
        PAR_EN_prev <= PAR_EN ;
    end
end
endmodule
module Parity #(
    parameter DATA_W = 8
) (
    input wire [DATA_W-1 : 0] P_DATA,
    input wire clk,
    input wire rst_n,
    input wire PAR_TYPE,
    input wire DATA_VALID,
    output reg parity 
);
        reg[DATA_W-1 : 0] DATA_REG;
    always @(*) begin
        if (PAR_TYPE)
            parity = ~(^DATA_REG);// Odd parity
        else
            parity =  ^DATA_REG;// Even parity
        end
    always @(posedge clk or negedge rst_n) 
    begin
        if(!rst_n)
        DATA_REG <= 'b0;
        else if (DATA_VALID)
        DATA_REG <= P_DATA;
    end
endmodule
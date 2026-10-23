module data_sampling #(
    parameter EDGE_COUNTER_W = 6, //(FOR MAXIMIUM POSSIBLE PRESCALE) 
    parameter OVERSAMPLE     = 2 
) (
    input wire clk ,
    input wire rst_n ,
    input wire RX_IN,
    input wire [EDGE_COUNTER_W-1 : 0] prescale ,
    input wire [EDGE_COUNTER_W -1 : 0] edge_cnt,
    input wire data_sample_en,

    output reg sampled_bit
);
    reg sampled_bit_reg;
    reg [OVERSAMPLE -1 : 0 ] ones_counter , ones_counter_reg; 
    reg [OVERSAMPLE -1 : 0 ] zeros_counter, zeros_counter_reg; 

    wire [EDGE_COUNTER_W-1 : 0] sample1 ;
    wire [EDGE_COUNTER_W-1 : 0] sample2 ;
    wire [EDGE_COUNTER_W-1 : 0] sample3 ;

    assign sample1 = (prescale/2)-1;
    assign sample2 = (prescale/2);
    assign sample3 = (prescale/2)+1;


    always @(*)
    begin
    sampled_bit_reg = sampled_bit;
    ones_counter_reg = ones_counter;
    zeros_counter_reg = zeros_counter ;
        if (data_sample_en)
        begin
            if (edge_cnt == sample1)
            begin
                    if(RX_IN )
                        ones_counter_reg = ones_counter_reg + 1;
                    else
                    zeros_counter_reg = zeros_counter_reg +1 ;
            end
            else if (edge_cnt == sample2) 
                    begin
                    if(RX_IN )
                        ones_counter_reg = ones_counter_reg + 1;
                    else
                        zeros_counter_reg = zeros_counter_reg +1 ;
                    end
            else if (edge_cnt == sample3)
            begin
                    if(RX_IN )
                        ones_counter_reg = ones_counter_reg + 1;
                    else
                        zeros_counter_reg = zeros_counter_reg +1 ;
                if (zeros_counter_reg > ones_counter_reg)
                sampled_bit_reg = 1'b0;
                else begin
                sampled_bit_reg = 1'b1;
                end
            end
            else
            begin
                zeros_counter_reg = 2'b0;
                ones_counter_reg =  2'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            ones_counter <= 'b0;
            zeros_counter <= 'b0;
            sampled_bit <= 'b0;
        end
        else 
        begin
            ones_counter <= ones_counter_reg;
            zeros_counter <=zeros_counter_reg;
            sampled_bit <= sampled_bit_reg;
        end
    end
endmodule
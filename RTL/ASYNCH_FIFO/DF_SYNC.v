module DF_SYNC #( 
    parameter PTR_W = 4 )
(
    input wire clk ,
    input wire rst ,
    input wire [PTR_W-1 : 0] asynch_data,
    output reg [PTR_W-1 : 0] synch_data
);
    reg [PTR_W-1 : 0]  FF1  ;

    always @(posedge clk or negedge rst)
    begin
        if(!rst)
        begin
        FF1 <= 'b0;
        synch_data <= 'b0;
        end
        else 
        begin
        FF1 <= asynch_data;
        synch_data <= FF1;
        end
    end
endmodule
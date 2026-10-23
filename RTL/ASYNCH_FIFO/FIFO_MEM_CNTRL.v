module FIFO_MEM_CNTRL #(
    parameter DATA_BUS_WIDTH = 9,
    parameter FIFO_DEPTH = 8,
    parameter ADD_W = $clog2(FIFO_DEPTH)
) (
    input wire wr_clk ,
    input wire wr_rst,
    input wire [DATA_BUS_WIDTH-1 : 0] wdata ,
    input wire W_INC,
    input wire [ADD_W -1 : 0 ] waddr ,raddr,

    output wire [DATA_BUS_WIDTH-1 : 0] rdata
);

    reg [DATA_BUS_WIDTH-1 : 0 ] mem [0 :FIFO_DEPTH-1 ];
    integer i;
        // write block 

    always @(posedge wr_clk or negedge wr_rst )
    begin
        if (!wr_rst)
        begin
            for(i=0;i<FIFO_DEPTH;i=i+1)
            begin
            mem [i] <= 'b0; 
            end
        end
        else if (W_INC) begin
            mem [waddr] <= wdata;
        end
    end 
        //read operation 
        assign rdata = mem[raddr] ;
endmodule
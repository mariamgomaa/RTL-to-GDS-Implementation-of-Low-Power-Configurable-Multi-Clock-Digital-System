module ASYNC_FIFO #(
    parameter DATA_BUS_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADD_W = $clog2(FIFO_DEPTH),
    parameter PTR_W = 4
) (
    input wire w_clk,r_clk,
    input wire w_rst,r_rst,
    input wire w_inc,r_inc,
    input wire [DATA_BUS_WIDTH -1 : 0 ] wr_data,

    output wire [DATA_BUS_WIDTH -1 : 0 ] rd_data,
    output wire empty,full
);
    
    wire [PTR_W-1 : 0 ] asynch_wptr;
    wire [PTR_W-1 : 0 ] synch_wptr;

    wire [PTR_W-1 : 0 ] asynch_rptr;
    wire [PTR_W-1 : 0 ] synch_rptr;

    wire [ADD_W-1 : 0] read_address;
    wire [ADD_W-1 : 0] write_address;

    wire wr_en;

    assign wr_en = ((~full) &&  w_inc) ;

    FIFO_RD #(
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADD_W (ADD_W),
    .PTR_W (PTR_W)
) 
    u_FIFO_RD
(
    .r_clk(r_clk),
    .r_rst(r_rst),
    .r_inc(r_inc),
    .sync_wptr(synch_wptr),
    .raddr(read_address),
    .gray_r_ptr(asynch_rptr),
    .empty(empty) 
);

FIFO_WR #(
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADD_W (ADD_W),
    .PTR_W (PTR_W)
) 
u_FIFO_WR
(
    .w_clk(w_clk),
    .w_rst(w_rst),
    .w_inc(w_inc),
    .sync_rptr(synch_rptr),
    .waddr(write_address),
    .gray_wr_ptr(asynch_wptr),
    .full(full) 
);
//2 flip flop synchronizer for read pointer
DF_SYNC #( 
    .PTR_W (PTR_W) 
    )
u_DF_SYNC_R
(
    .clk(w_clk) ,
    .rst (w_rst),
    .asynch_data(asynch_rptr),
    .synch_data(synch_rptr)
);
//2 flip flop synchronizer for write pointer
DF_SYNC #( 
    .PTR_W (PTR_W) 
    )
u_DF_SYNC_W
(
    .clk(r_clk) ,
    .rst (r_rst),
    .asynch_data(asynch_wptr),
    .synch_data(synch_wptr)
);

FIFO_MEM_CNTRL #(
    .DATA_BUS_WIDTH (DATA_BUS_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH),
    .ADD_W (ADD_W)
)
u_FIFO_MEM_CNTRL
(
    .wr_clk (w_clk),
    .wr_rst(w_rst),
    .wdata (wr_data),
    .W_INC(wr_en),
    .waddr(write_address) ,
    .raddr(read_address),

    .rdata(rd_data)
);
endmodule
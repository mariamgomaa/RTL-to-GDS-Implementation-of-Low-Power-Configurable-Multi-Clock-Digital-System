module FIFO_WR #(
    parameter FIFO_DEPTH = 8,
    parameter ADD_W = $clog2(FIFO_DEPTH),
    parameter PTR_W = 4
) (
    input wire w_clk,
    input wire w_rst,
    input wire w_inc,
    input wire [PTR_W-1 : 0] sync_rptr,
    output reg [ADD_W-1 : 0] waddr,
    output reg [PTR_W-1 : 0] gray_wr_ptr,
    output reg full 
);
        reg [PTR_W-1 : 0] gray_wr_ptr_next ;
        reg [PTR_W-1 : 0] wr_ptr ,wr_ptr_next ;
        wire full_comb;
    // full condition
    assign full_comb = ((gray_wr_ptr_next [PTR_W-1 ] != sync_rptr [PTR_W-1 ])&&(gray_wr_ptr_next [PTR_W-2] != sync_rptr [PTR_W-2])
    &&(gray_wr_ptr_next [PTR_W-3 :0] == sync_rptr [PTR_W-3 :0]) ) ? 1'b1 : 1'b0; 
    //increment condition 
    always @(*)
    begin
        wr_ptr_next = wr_ptr;
        if (w_inc && !full)
        begin
        wr_ptr_next = wr_ptr + 1'b1;
        end
    end
    //binary to gray 
    always @(*)
    begin
        gray_wr_ptr_next = gray_wr_ptr;
        case (wr_ptr_next)
            4'b0000: gray_wr_ptr_next = 4'b0000;
	        4'b0001: gray_wr_ptr_next = 4'b0001;
	        4'b0010: gray_wr_ptr_next = 4'b0011;
	        4'b0011: gray_wr_ptr_next = 4'b0010;
	        4'b0100: gray_wr_ptr_next = 4'b0110;
	        4'b0101: gray_wr_ptr_next = 4'b0111;
	        4'b0110: gray_wr_ptr_next = 4'b0101;
	        4'b0111: gray_wr_ptr_next = 4'b0100;
	        4'b1000: gray_wr_ptr_next = 4'b1100;
	        4'b1001: gray_wr_ptr_next = 4'b1101;
	        4'b1010: gray_wr_ptr_next = 4'b1111;
	        4'b1011: gray_wr_ptr_next = 4'b1110;
	        4'b1100: gray_wr_ptr_next = 4'b1010;
	        4'b1101: gray_wr_ptr_next = 4'b1011;
	        4'b1110: gray_wr_ptr_next = 4'b1001;
	        4'b1111: gray_wr_ptr_next = 4'b1000;
        endcase
    end

    always @(posedge w_clk or negedge w_rst)
    begin
        if (!w_rst)
        begin
        waddr <= 'b0;
        gray_wr_ptr <= 'b0;
        wr_ptr <= 'b0;
        full <= 1'b0;
        end
        else begin
        waddr <= wr_ptr_next [PTR_W-2 : 0];
        gray_wr_ptr <= gray_wr_ptr_next;
        wr_ptr <= wr_ptr_next;
        full <= full_comb;
            
        end
    end
endmodule
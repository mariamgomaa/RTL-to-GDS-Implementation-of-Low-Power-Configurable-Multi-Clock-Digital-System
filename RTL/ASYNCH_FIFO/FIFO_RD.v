module FIFO_RD #(
    parameter FIFO_DEPTH = 8,
    parameter ADD_W = $clog2(FIFO_DEPTH),
    parameter PTR_W = 4
) (
    input wire r_clk,
    input wire r_rst,
    input wire r_inc,
    input wire [PTR_W-1 : 0] sync_wptr,
    output reg [ADD_W-1 : 0] raddr,
    output reg [PTR_W-1 : 0] gray_r_ptr,
    output reg empty 
);
        reg [PTR_W-1 : 0] gray_r_ptr_next ;
        reg [PTR_W-1 : 0] r_ptr ,r_ptr_next ;
        wire empty_comb;
    // empty condition
    assign empty_comb = (gray_r_ptr_next == sync_wptr  ) ? 1'b1 : 1'b0; 
    //increment condition 
    always @(*)
    begin
        r_ptr_next = r_ptr;
        if (r_inc && !empty)
        begin
        r_ptr_next = r_ptr + 1'b1;
        end
    end
    //binary to gray 
    always @(*)
    begin
        gray_r_ptr_next = gray_r_ptr;
        case (r_ptr_next)
            4'b0000: gray_r_ptr_next = 4'b0000;
	        4'b0001: gray_r_ptr_next = 4'b0001;
	        4'b0010: gray_r_ptr_next = 4'b0011;
	        4'b0011: gray_r_ptr_next = 4'b0010;
	        4'b0100: gray_r_ptr_next = 4'b0110;
	        4'b0101: gray_r_ptr_next = 4'b0111;
	        4'b0110: gray_r_ptr_next = 4'b0101;
	        4'b0111: gray_r_ptr_next = 4'b0100;
	        4'b1000: gray_r_ptr_next = 4'b1100;
	        4'b1001: gray_r_ptr_next = 4'b1101;
	        4'b1010: gray_r_ptr_next = 4'b1111;
	        4'b1011: gray_r_ptr_next = 4'b1110;
	        4'b1100: gray_r_ptr_next = 4'b1010;
	        4'b1101: gray_r_ptr_next = 4'b1011;
	        4'b1110: gray_r_ptr_next = 4'b1001;
	        4'b1111: gray_r_ptr_next = 4'b1000;
        endcase
    end

    always @(posedge r_clk or negedge r_rst)
    begin
        if (!r_rst)
        begin
        raddr <= 'b0;
        gray_r_ptr <= 'b0;
        r_ptr <= 'b0;
        empty <= 1'b1;
        end
        else begin
        raddr <= r_ptr_next [PTR_W-2 : 0];
        gray_r_ptr <= gray_r_ptr_next;
        r_ptr <= r_ptr_next;
        empty <= empty_comb;
        end
    end
endmodule
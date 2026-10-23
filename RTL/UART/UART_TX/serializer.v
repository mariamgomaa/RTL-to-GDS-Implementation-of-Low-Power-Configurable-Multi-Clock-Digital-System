module serializer #(
    parameter DATA_W    = 8,
    parameter COUNTER_W = 4
) (
    input  wire [DATA_W-1:0] P_DATA,
    input  wire              DATA_VALID,
    input  wire              ser_en,
    input  wire              clk,
    input  wire              rst_n,
    output wire              ser_done,
    output wire              ser_data
);

reg [COUNTER_W-1:0] count, next_count;
reg [DATA_W-1:0]    DATA_reg, next_DATA_reg;

//////////////////////////////////////////////////
// Sequential Logic
//////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count    <= 'b0;
        DATA_reg <= 'b0;
    end
    else begin
        count    <= next_count;
        DATA_reg <= next_DATA_reg;
    end
end

//////////////////////////////////////////////////
// Combinational Logic
//////////////////////////////////////////////////
always @(*) begin
    // Default assignments
    next_count    = count;
    next_DATA_reg = DATA_reg;

    if (DATA_VALID && !ser_en) begin
        next_DATA_reg = P_DATA;
        next_count    = 'b0;
    end
    else if (ser_en && (count != DATA_W)) begin
        next_DATA_reg = DATA_reg >> 1;
        next_count    = count + 1'b1;
    end
    else if (count == DATA_W) begin
        next_count = 'b0;
    end
end

//////////////////////////////////////////////////
// Output Logic
//////////////////////////////////////////////////
assign ser_done = (count == DATA_W-1);
assign ser_data = DATA_reg[0];

endmodule

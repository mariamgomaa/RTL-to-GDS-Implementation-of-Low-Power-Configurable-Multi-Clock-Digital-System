module MUX (
    input wire ser_data,
    input wire  parity ,
    input wire [1:0] mux_s,
    output reg TX_out 
);
    localparam START = 2'b00,
                STOP = 2'b01,
                SERIAL = 2'b10,
                PARITY = 2'b11;

    always @(*)
        begin
        TX_out = 1;
            case (mux_s)
                START : 
                TX_out = 1'b0;
                STOP:
                TX_out = 1'b1;
                SERIAL:
                TX_out = ser_data ;
                PARITY:
                TX_out = parity;
            endcase 
        end
endmodule
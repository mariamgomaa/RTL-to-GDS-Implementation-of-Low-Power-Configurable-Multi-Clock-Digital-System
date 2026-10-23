module FSM (
    input wire clk,
    input wire rst_n,
    input wire DATA_VALID,
    input wire ser_done,
    input wire PAR_EN,
    output reg [1:0] mux_s,
    output reg ser_en,
    output reg busy
);
    reg [2:0] current_state , next_state;
    //MUX VALUES FOR DIFFERENT CASES 
    localparam  MSTART = 2'b00,
                MSTOP =  2'b01,
                MDATA_TRANSMATION = 2'b10,
                MPARITY           = 2'b11;
    // states IDLE FOR WAITING THE START BIT 
    localparam  IDLE  = 3'b000, //CHECK ON THE VALID AND BUSY 
                START = 3'b001,
                TRANSMITION = 3'b011,
                PARITY =3'b010,
                STOP = 3'b110;
    //next state logic 
    always @(*)
    begin
        mux_s=   MSTOP;
        ser_en = 1'b0;
        busy = 1'b0;
        case (current_state)
        IDLE:
        begin
            if (DATA_VALID)
            next_state = START;
            else 
            next_state = IDLE;
        end
        START : 
        begin
            ser_en = 1'b0;
            busy = 1'b1;
            mux_s=   MSTART;
            next_state = TRANSMITION;
        end
        TRANSMITION : 
        begin
            ser_en = 1'b1;
            busy = 1'b1;
            mux_s=   MDATA_TRANSMATION;
            if (ser_done)
            begin
                if(PAR_EN)
                next_state = PARITY;
                else 
                next_state = STOP;
            end
            else 
                next_state = TRANSMITION;
        end
        PARITY : 
        begin
            busy = 1'b1;
            mux_s=   MPARITY;
            next_state = STOP;
        end
        STOP : 
        begin
        mux_s=   MSTOP;
        busy = 1'b1;
        next_state = IDLE;
        end
default :next_state = IDLE;
        endcase 
    end
    //sequential block 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
        current_state <= IDLE;
        else 
        current_state <= next_state;
    end

endmodule

module DATA_SYNC #(
    parameter NUM_STAGES = 4 ,
    parameter BUS_WIDTH  = 8 
    
) (
    input wire CLK,
    input wire RST_n,
    input wire [BUS_WIDTH-1 : 0] unsync_bus ,
    input wire bus_enable,

    output reg [BUS_WIDTH-1 : 0] sync_bus,
    output reg enable_pulse

);

    reg [NUM_STAGES-1 : 0] bus_enable_FF;
    reg generated_pulse_reg;
    wire sync_bulse_enable;
    wire generated_pulse;
    wire [BUS_WIDTH-1 : 0] mux_out;

    //multi flip flop block 
    always @(posedge CLK or negedge RST_n)
    begin
        if(!RST_n)
        begin
            bus_enable_FF <= 'b0;
        end
        else
        begin
        bus_enable_FF <= {bus_enable_FF[NUM_STAGES-2 : 0] ,bus_enable };
        end
    end 
    assign sync_bulse_enable = bus_enable_FF [NUM_STAGES-1 ];

    //pulse geneartor block 
    always @(posedge CLK or negedge RST_n)
    begin
        if(!RST_n)
        begin
        generated_pulse_reg <= 'b0;
        end
        else
        begin
        generated_pulse_reg <= sync_bulse_enable;
        end
    end

    //compinational logic 

    assign generated_pulse = (~generated_pulse_reg) & sync_bulse_enable;
    assign mux_out = (generated_pulse ) ? unsync_bus : sync_bus; 
    
    
    // register output 
        always @(posedge CLK or negedge RST_n)
    begin
        if(!RST_n)
        begin
            enable_pulse <= 'b0;
            sync_bus <= 'b0;
        end
        else
        begin
                enable_pulse <= generated_pulse ;
                sync_bus     <= mux_out;
        end
    end



 
    
endmodule
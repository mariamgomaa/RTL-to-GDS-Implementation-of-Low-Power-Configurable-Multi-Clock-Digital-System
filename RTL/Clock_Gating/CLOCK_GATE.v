module CLOCK_GATE(
    input wire  CLK ,
    input wire EN,
    output wire CLK_Gate
);

TLATNCAX12M U0_TLATNCAX12M (
.E(EN),
.CK(CLK),
.ECK(CLK_Gate)
);

/*
//internal connections
reg     Latch_Out ;
//latch (Level Sensitive Device)
always @(CLK or EN)
 begin
  if(!CLK)      // active low
   begin
    Latch_Out <= EN ;
   end
 end
// ANDING
assign  CLK_Gate = CLK && Latch_Out ;

 */
endmodule
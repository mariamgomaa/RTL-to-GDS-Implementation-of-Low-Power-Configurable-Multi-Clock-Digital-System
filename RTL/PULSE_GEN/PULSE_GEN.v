module PULSE_GEN (
input wire clk,
input wire rst_n,
input wire  sig_in,
output wire pulse
);
reg FF1,FF2;
always @(posedge clk or negedge rst_n)
 begin
  if(!rst_n)
   begin
    FF1 <= 1'b0 ;
    FF2 <= 1'b0 ;	
   end
  else
   begin
    FF1 <= sig_in;   
    FF2 <= FF1;
   end  
 end
assign pulse = FF1 && !FF2 ;


endmodule
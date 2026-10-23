module stop_check #(parameter EDGE_COUNTER_W = 6,BIT_COUNTER_W=4)
(
    input wire clk ,
    input wire rst_n,
    input wire sampled_bit,
    input wire stp_check_en,
    input wire [EDGE_COUNTER_W-1 :0] edge_cnt ,  //according to prescalele the check for state depent on it 
    input wire [BIT_COUNTER_W-1 :0] bit_cnt ,  //according to prescalele the check for state depent on it 

      input wire [EDGE_COUNTER_W-1 : 0] prescale ,

    output reg stp_err
); 
always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            stp_err <= 1'b0;
        else if (stp_check_en && edge_cnt == prescale - 6'd2)
        begin
        
            if (sampled_bit )
                stp_err <= 1'b0 ;
            else 
                stp_err <= 1'b1 ;
        end
        else if (bit_cnt==0)
        stp_err <= 1'b0;
    end
endmodule 
module parity_check #(
    parameter FRAME_W = 8,
    parameter BIT_COUNTER_W=4,
    parameter EDGE_COUNTER_W = 6
) (
    input wire clk ,rst_n,
    input wire [FRAME_W-1 : 0 ] P_DATA ,
    input wire sampled_bit ,
    input wire par_check_en,
    input wire PAR_TYPE,

    input wire [EDGE_COUNTER_W-1 :0] edge_cnt ,  //according to prescalele the check for state depent on it 
      input wire [EDGE_COUNTER_W-1 : 0] prescale ,
      input wire [BIT_COUNTER_W-1 :0] bit_cnt , 

    output reg par_err
);
reg par_err_reg;
    always @(*)
    begin
    par_err_reg = par_err ;
        if (par_check_en && edge_cnt == prescale-6'd2 )
        begin
            if (PAR_TYPE) //odd parity 
            begin
                if (sampled_bit == ~(^P_DATA))
                par_err_reg = 1'b0;
                else 
                par_err_reg = 1'b1;
            end
            else //even parity 
            begin
                if (sampled_bit == (^P_DATA))
                par_err_reg = 1'b0;
                else 
                par_err_reg = 1'b1;
            end
        end
        else if (bit_cnt==1) begin
            par_err_reg = 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        par_err <= 1'b0 ;
        else 
        par_err <= par_err_reg;
    end
endmodule
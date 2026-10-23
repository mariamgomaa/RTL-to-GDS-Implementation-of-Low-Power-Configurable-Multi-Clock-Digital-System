module CLKDiv #
(parameter DIVIDE_RATIO_W = 8)
(
   input wire i_ref_clk,
   input wire i_rst_n,
   input wire i_clk_en,
   input wire [DIVIDE_RATIO_W-1 : 0 ] i_div_ratio,

   output reg o_div_clk
);
    // create counter to divide the clock to it according to divation ratio 
    // the way to know if the div ratio is even or odd is by checking the least significant bit
    // div ratio not allowed to be 1 or 0 
    // if div ratio is even the the clock will flip at divation ratio /2  
    // if div ratio is odd the clock will flip two times for example /3  flip 1 2 0011 
    // 1st one at 0011>>1 =0001 equivelant to (/2)
    // 2nd one at 0001+1 equivelant to ((/2)+1)

    reg [DIVIDE_RATIO_W-1 : 0 ] half_of_ratio ;
    reg [DIVIDE_RATIO_W-1 : 0 ] second_flip ;
    reg CLK_DIV_EN;

    reg [DIVIDE_RATIO_W-1 : 0 ] ratio_counter ;
    reg divided_clk;
    reg flip ;

    always @(*)
    begin
        half_of_ratio = (i_div_ratio >> 1) -'b1  ;
        second_flip   = ( i_div_ratio >> 1)   ;
        CLK_DIV_EN    = (i_clk_en && (i_div_ratio!= 'b0) &&(i_div_ratio!= 'b1));
        if (CLK_DIV_EN)
        o_div_clk     = divided_clk;
        else 
        o_div_clk     = i_ref_clk;

    end
        
    always@(posedge i_ref_clk or negedge i_rst_n)
        if (!i_rst_n)
        begin
            ratio_counter <= 'b0;
            flip <= 1;
            divided_clk   <= 'b0;
        end 
        else if (CLK_DIV_EN)
        begin
        if (i_div_ratio[0]) //odd divation ratio 
        begin
            if( (ratio_counter == half_of_ratio ) && flip)
            begin
                    divided_clk <= ~divided_clk;
                    ratio_counter <= 'b0;
                    flip <= 1'b0;
            end 
            else if ((ratio_counter == second_flip ) && !flip)
            begin
                    divided_clk <= ~divided_clk;
                    ratio_counter <= 'b0;
                    flip <= 1'b1;
            end 
            else 
                    ratio_counter <= ratio_counter + 'b1;
        end 
        else //even ratio of divatoin 
        begin
            if (ratio_counter == half_of_ratio )
            begin
                    divided_clk <= ~divided_clk;
                    ratio_counter <= 'b0;
            end 
            else
            begin 
                    ratio_counter <= ratio_counter + 'b1;
            end
        end 
        end 
endmodule

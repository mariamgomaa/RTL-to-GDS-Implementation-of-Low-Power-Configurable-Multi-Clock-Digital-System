module ALU  #(parameter OP_WIDTH = 8 ,
              parameter OUT_WIDTH = 2 * OP_WIDTH  )
    (
    input wire [OP_WIDTH-1:0] A,B,
    input wire [3:0] ALU_FUN,
    input wire  CLK,RST_N,EN,
    output reg [OUT_WIDTH-1:0] ALU_OUT,
    output reg ALU_OUT_VALID
    // output reg Carry_Flag,Arithm_Flag,CMP_Flag,Logic_Flag,Shift_Flag 
    );

//internal wire declaration 
        reg [OUT_WIDTH-1:0] ALU_result ;
        reg ALU_VALID;

//combinational logic for ALU
 always @(*)
 begin
    // Carry_Flag = 1'b0;
    // Arithm_Flag = 1'b0;
    // CMP_Flag = 1'b0;
    // Logic_Flag = 1'b0;
    // Shift_Flag  = 1'b0;
    ALU_result = 'b0;
    ALU_VALID  = 1'b0;
    if (EN)
    begin
    case (ALU_FUN)
    //arthmitaic operation 
    4'b0000 : 
    begin
        ALU_result = A+B;
        ALU_VALID  = 1'b1;
        // Arithm_Flag = 1'b1;
    end 
    4'b0001 :
    begin
        ALU_result = A-B;
        ALU_VALID  = 1'b1;
        // Arithm_Flag = 1'b1;
    end
    4'b0010:
    begin
    ALU_result = A * B ;
    ALU_VALID  = 1'b1;
    // Arithm_Flag = 1'b1; 
    end
    4'b0011:
    begin
    if (B!=0)
    begin
    ALU_result = (A / B) ;
    ALU_VALID  = 1'b1;
    end
    else 
    ALU_result = 16'b0;
    
    // Arithm_Flag = 1'b1;
    end 
    //logical operation 
    4'b0100:
    begin
        ALU_result = {8'b0,(A & B)};
        ALU_VALID  = 1'b1;
        // Logic_Flag = 1'b1;
    end 
    4'b0101:
    begin
        ALU_result = {8'b0,(A | B)};
        ALU_VALID  = 1'b1;
        // Logic_Flag = 1'b1;
    end 
    4'b0110:
    begin
        ALU_result = {8'b0,~(A & B)};
        ALU_VALID  = 1'b1;
        // Logic_Flag = 1'b1;
    end 
    4'b0111:
    begin
        ALU_result ={8'b0, ~ (A | B)};
        ALU_VALID  = 1'b1;
        // Logic_Flag = 1'b1;
    end 
    4'b1000:
    begin
        ALU_result = {8'b0,(A ^ B)};
        ALU_VALID  = 1'b1;
        // Logic_Flag = 1'b1;
    end 
    4'b1001:
    begin
        ALU_result = {8'b0,~(A ^ B)};
        ALU_VALID  = 1'b1;
        // Logic_Flag = 1'b1;
    end 
    4'b1010:
    begin
        // CMP_Flag = 1'b1;
        if (A==B)
        begin
        ALU_result = 16'b1;
        ALU_VALID  = 1'b1;
        end
        else 
        begin
        ALU_result = 16'b0;
        ALU_VALID  = 1'b1;
        end
    end
    4'b1011:
    begin
        // CMP_Flag = 1'b1;

        if (A > B)
        begin
        ALU_result = 16'b10;
        ALU_VALID  = 1'b1;
        end
        else 
        begin
        ALU_result = 16'b0;
        ALU_VALID  = 1'b1;
        end
    end
    4'b1100:
    begin
        ALU_VALID  = 1'b1;
        // CMP_Flag = 1'b1;
        if (A < B)
        ALU_result = 16'b11;
        else 
        ALU_result = 16'b0;
    end
    4'b1101: 
    begin 
        ALU_VALID  = 1'b1;
        //  Shift_Flag  = 1'b1;
         ALU_result = A>>1;
    end 
    4'b1110: 
    begin 
        ALU_VALID  = 1'b1;
        //  Shift_Flag  = 1'b1;
         ALU_result = A<<1;
    end 
    default :
    begin
    ALU_VALID  = 1'b0;
    ALU_result ='b0;
    end
    endcase 
    end
 end

 // sequantial circuit implementation (update the output of ALU at posedfge clk) 
 always @(posedge CLK or negedge RST_N)
 begin
    if(!RST_N)
    begin
        ALU_OUT <= 'b0;
        ALU_OUT_VALID <= 1'b0;
    end 
    else 
    begin
        ALU_OUT <= ALU_result ;
        ALU_OUT_VALID <= ALU_VALID;
    end
 end 
    
endmodule
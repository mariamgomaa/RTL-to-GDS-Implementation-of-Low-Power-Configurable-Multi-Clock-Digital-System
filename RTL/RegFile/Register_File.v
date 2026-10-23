module Register_File #(parameter DATA_W = 8, 
               DEPTH = 16,
               ADD_W = $clog2(DEPTH))
 (
    input wire [DATA_W -1 :0] WrData ,
    input wire [ADD_W-1:0] Address,
    input wire CLK ,
    input wire RST ,
    input wire WrEn,RdEn,
    output reg [DATA_W -1:0]  RdData,
    output reg  RdData_Valid,
    output  [DATA_W -1 :0] REG0 ,REG1 ,REG2,REG3
);
integer i ;
//register defination 
 reg [DATA_W -1:0] reg_file [0:DEPTH-1];

always @(posedge CLK or negedge RST )
    begin
        if (!RST)
        begin 
            for (i=0;i<DEPTH;i=i+1)
            begin
            if (i==2)
            begin
                reg_file [i] <= 'b100000_01;
            end 
            else if (i==3) begin
                reg_file [i] <= 'b0010_0000;
            end
            else 
            reg_file [i] <= 'b0;
            end
            RdData <= 'b0;
            RdData_Valid <= 'b0;
        end 
        else if (WrEn && !RdEn)
        begin
            reg_file [Address] <= WrData;
        end 
        else if (RdEn && !WrEn)
        begin
            RdData <= reg_file[Address];
            RdData_Valid <= 'b1;
        end 
        else 
        RdData_Valid <= 'b0;
    end 
    assign REG0 = reg_file [0];
    assign REG1 = reg_file [1];
    assign REG2 = reg_file [2];
    assign REG3 = reg_file [3];


endmodule 
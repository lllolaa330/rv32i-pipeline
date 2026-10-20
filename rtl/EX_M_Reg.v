// Recovered from the 2025 course presentation, slides 20.
// Transcribed and formatted in 2026; see docs/provenance.md.
module EX_M_Reg(input clk, input rst, input [31:0] inst_EX, input [31:0] pc_EX,
                input [31:0] ALUresult_EX, input [31:0] DataB_EX,
                output reg [31:0] inst_M, output reg [31:0] pc_M,
                output reg [31:0] ALUresult_M, output reg [31:0] DataB_M);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inst_M <= 32'h0;
            pc_M <= 32'h0;
            ALUresult_M <= 32'h0;
            DataB_M <= 32'h0;
        end else begin
            inst_M <= inst_EX;
            pc_M <= pc_EX;
            ALUresult_M <= ALUresult_EX;
            DataB_M <= DataB_EX;
        end
    end
endmodule

// Recovered from the 2025 course presentation, slides 18.
// Transcribed and formatted in 2026; see docs/provenance.md.
module ALU(input [31:0] A, input [31:0] B, input [3:0] ALUSel, output reg [31:0] ALUresult);
    wire [4:0] shamt = B[4:0];
    always @(*) begin
        case (ALUSel)
            4'b0000: ALUresult <= A + B;
            4'b1000: ALUresult <= A - B;
            4'b0111: ALUresult <= A & B;
            4'b0110: ALUresult <= A | B;
            4'b0100: ALUresult <= A ^ B;
            4'b0001: ALUresult <= A << shamt;
            4'b0101: ALUresult <= A >> shamt;
            4'b1101: ALUresult <= $signed(A) >>> shamt;
            4'b0010: ALUresult <= ($signed(A) < $signed(B)) ? 32'h00000001 : 32'h0;
            4'b0011: ALUresult <= (A < B) ? 32'h00000001 : 32'h0;
            4'b1001: ALUresult <= B;
            default: ALUresult <= 32'h0;
        endcase
    end
endmodule

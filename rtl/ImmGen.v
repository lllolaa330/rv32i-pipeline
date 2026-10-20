// Recovered from the 2025 course presentation, slides 17.
// Transcribed and formatted in 2026; see docs/provenance.md.
module ImmGen(input [31:0] inst, input [2:0] ImmSel, output reg [31:0] Imm);
    always @(*) begin
        case (ImmSel)
            3'b001: Imm <= {{20{inst[31]}}, inst[31:20]};
            3'b010: Imm <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
            3'b011: Imm <= {inst[31:12], 12'h0};
            3'b100: Imm <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            3'b101: Imm <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            default: Imm <= 32'b0;
        endcase
    end
endmodule

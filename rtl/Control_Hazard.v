// Recovered from the 2025 course presentation, slides 12.
// Transcribed and formatted in 2026; see docs/provenance.md.
module Control_Hazard(input [31:0] inst_EX, input BrEq, input BrLT,
                      output reg IF_ID_Flush, output reg ID_EX_Flush);
    reg EX_BranchTaken;
    always @(*) begin
        case (inst_EX[14:12])
            3'b000: EX_BranchTaken <= BrEq;
            3'b001: EX_BranchTaken <= ~BrEq;
            3'b100: EX_BranchTaken <= BrLT;
            3'b101: EX_BranchTaken <= ~BrLT;
            3'b110: EX_BranchTaken <= BrLT;
            3'b111: EX_BranchTaken <= ~BrLT;
            default: EX_BranchTaken <= 1'b0;
        endcase
    end
    always @(*) begin
        if (inst_EX[6:0] == 7'b1100011 && EX_BranchTaken) begin
            IF_ID_Flush = 1'b1;
            ID_EX_Flush = 1'b1;
        end else if (inst_EX[6:0] == 7'b1100111 || inst_EX[6:0] == 7'b1101111) begin
            IF_ID_Flush = 1'b1;
            ID_EX_Flush = 1'b1;
        end else begin
            IF_ID_Flush = 1'b0;
            ID_EX_Flush = 1'b0;
        end
    end
endmodule

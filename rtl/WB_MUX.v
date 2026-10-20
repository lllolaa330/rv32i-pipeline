// Recovered from the 2025 course presentation, slides 22.
// Transcribed and formatted in 2026; see docs/provenance.md.
module WB_MUX(input [1:0] WBSel, input [31:0] pc, input [31:0] ALUresult,
              input [31:0] DataR, output reg [31:0] DataWB);
    always @(*) begin
        case (WBSel)
            2'b00: DataWB <= DataR;
            2'b01: DataWB <= ALUresult;
            2'b10: DataWB <= pc;
            default: DataWB <= 32'h0;
        endcase
    end
endmodule

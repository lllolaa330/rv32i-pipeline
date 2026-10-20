// Recovered from the 2025 course presentation, slides 16.
// Transcribed and formatted in 2026; see docs/provenance.md.
module Branch_Comp(input BrUn, input [31:0] DataA, input [31:0] DataB,
                   output reg BrEq, output reg BrLT);
    always @(*) begin
        BrEq <= (DataA == DataB);
    end
    always @(*) begin
        if (BrUn) BrLT <= (DataA < DataB);
        else BrLT <= ($signed(DataA) < $signed(DataB));
    end
endmodule

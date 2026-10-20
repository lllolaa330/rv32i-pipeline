// Recovered from the 2025 course presentation, slides 22.
// Transcribed and formatted in 2026; see docs/provenance.md.
module MUX(input Control, input [31:0] D0, input [31:0] D1, output [31:0] Output);
    assign Output = (Control==1'b1) ? D1 : D0;
endmodule

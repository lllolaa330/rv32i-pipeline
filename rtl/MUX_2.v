// Recovered from the 2025 course presentation, slides 21.
// Transcribed and formatted in 2026; see docs/provenance.md.
module MUX_2(input [1:0] Control, input [31:0] D0, input [31:0] D1,
             input [31:0] D2, input [31:0] D3, output reg [31:0] Output);
    always @(*) begin
        case (Control)
            2'b00: Output <= D0;
            2'b01: Output <= D1;
            2'b10: Output <= D2;
            2'b11: Output <= D3;
            default: Output <= 32'h0;
        endcase
    end
endmodule

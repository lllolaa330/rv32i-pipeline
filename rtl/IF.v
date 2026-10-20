// Recovered from the 2025 course presentation, slides 13.
// Transcribed and formatted in 2026; see docs/provenance.md.
module IF(input clk, input rst, input [31:0] nextpc, output reg [31:0] pc);
    always @(posedge clk or posedge rst) begin
        if (rst) pc <= 32'h0;
        else pc <= nextpc;
    end
endmodule

// Recovered from the 2025 course presentation, slides 20.
// Transcribed and formatted in 2026; see docs/provenance.md.
module M_WB_Reg(input clk, input rst, input [31:0] inst_M, input [31:0] DataWB_M,
                output reg [31:0] inst_WB, output reg [31:0] DataWB_WB);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inst_WB <= 32'h0;
            DataWB_WB <= 32'h0;
        end else begin
            inst_WB <= inst_M;
            DataWB_WB <= DataWB_M;
        end
    end
endmodule

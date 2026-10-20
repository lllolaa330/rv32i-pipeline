// Recovered from the 2025 course presentation, slides 20.
// Transcribed and formatted in 2026; see docs/provenance.md.
module IF_ID_Reg(input clk, input rst, input [31:0] inst_IF, input [31:0] pc_IF,
                 input IF_ID_Flush, output reg [31:0] inst_ID, output reg [31:0] pc_ID);
    always @(posedge clk or posedge rst) begin
        if (rst || IF_ID_Flush) begin
            inst_ID <= 32'h0;
            pc_ID <= 32'h0;
        end else begin
            inst_ID <= inst_IF;
            pc_ID <= pc_IF;
        end
    end
endmodule

// Recovered from the 2025 course presentation, slides 20.
// Transcribed and formatted in 2026; see docs/provenance.md.
module ID_EX_Reg(input clk, input rst, input [31:0] inst_ID, input [31:0] pc_ID,
                 input [31:0] DataA_ID, input [31:0] DataB_ID, input ID_EX_Flush,
                 output reg [31:0] inst_EX, output reg [31:0] pc_EX,
                 output reg [31:0] DataA_EX, output reg [31:0] DataB_EX);
    always @(posedge clk or posedge rst) begin
        if (rst || ID_EX_Flush) begin
            inst_EX <= 32'h0;
            pc_EX <= 32'h0;
        end else begin
            inst_EX <= inst_ID;
            pc_EX <= pc_ID;
            DataA_EX <= DataA_ID;
            DataB_EX <= DataB_ID;
        end
    end
endmodule

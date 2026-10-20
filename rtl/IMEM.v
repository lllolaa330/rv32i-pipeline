// Recovered from the 2025 course presentation, slides 14.
// Transcribed and formatted in 2026; see docs/provenance.md.
module IMEM(input [31:0] pc, output reg [31:0] inst,
            output [4:0] rs1, output [4:0] rs2);
    reg [31:0] inst_mem [0:255];
    initial begin
        $readmemh("program.txt", inst_mem);
    end
    always @(*) begin
        inst <= inst_mem[pc[9:2]];
    end
    assign rs2 = inst[24:20];
    assign rs1 = inst[19:15];
endmodule

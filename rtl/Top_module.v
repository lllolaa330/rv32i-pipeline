// Recovered from the 2025 course presentation, slides 9.
// Transcribed and formatted in 2026; see docs/provenance.md.
module Top_module(input clk, input rst);
    wire [31:0] nextpc;
    wire [31:0] pc_IF, pc_ID, pc_EX, pc_M;
    wire [31:0] inst_IF, inst_ID, inst_EX, inst_M, inst_WB;
    wire [31:0] Imm, ALUresult_EX, ALUresult_M;
    wire [31:0] DataA_ID, DataA_EX, DataASel_EX, DatabranchSelA;
    wire [31:0] DataB_ID, DataB_EX, DataBSel_EX, DatabranchSelB, DataB_M, DataBSel_M;
    wire [31:0] DataR, DataWB_M, DataWB_WB;
    wire PCSel, RegWEn, BrUn, MemRW, BrEq, BrLT, DataBSel;
    wire [1:0] ASel, BSel, WBSel, branchASel, branchBSel;
    wire [3:0] ALUSel;
    wire [2:0] ImmSel;
    wire IF_ID_Flush, ID_EX_Flush;

    Control_logic u_Control_logic(inst_ID, inst_EX, inst_M, inst_WB, BrEq, BrLT,
        PCSel, ALUSel, ImmSel, RegWEn, ASel, BSel, BrUn, MemRW, WBSel,
        DataBSel, branchASel, branchBSel);
    Control_Hazard u_Control_Hazard(inst_EX, BrEq, BrLT, IF_ID_Flush, ID_EX_Flush);
    IF u_IF(clk, rst, nextpc, pc_IF);
    // Presentation shows two ports, but IMEM on slide 14 declares four.
    IMEM u_IMEM(pc_IF, inst_IF);
    IF_ID_Reg u_IF_ID_Reg(clk, rst, inst_IF, pc_IF, IF_ID_Flush, inst_ID, pc_ID);
    // Referenced in the presentation; implementation was not supplied.
    WBReg_ID_Hazard u_WBReg_ID_Hazard(clk, RegWEn, inst_WB[11:7],
        inst_ID[19:15], inst_ID[24:20], DataWB_WB, DataA_ID, DataB_ID);
    ID_EX_Reg u_ID_EX_Reg(clk, rst, inst_ID, pc_ID, DataA_ID, DataB_ID,
        ID_EX_Flush, inst_EX, pc_EX, DataA_EX, DataB_EX);
    ImmGen u_ImmGen(inst_EX, ImmSel, Imm);
    MUX_2 u_bracnhASel_MUX(branchASel, DataA_EX, DataWB_M, DataWB_WB, DataA_EX, DatabranchSelA);
    MUX_2 u_bracnhBSel_MUX(branchBSel, DataB_EX, DataWB_M, DataWB_WB, DataB_EX, DatabranchSelB);
    Branch_Comp u_Branch_Comp(BrUn, DatabranchSelA, DatabranchSelB, BrEq, BrLT);
    MUX_2 u_ASel_MUX(ASel, pc_EX, DataA_EX, DataWB_M, DataWB_WB, DataASel_EX);
    MUX_2 u_BSel_MUX(BSel, Imm, DataB_EX, DataWB_M, DataWB_WB, DataBSel_EX);
    ALU u_ALU(DataASel_EX, DataBSel_EX, ALUSel, ALUresult_EX);
    EX_M_Reg u_EX_M_Reg(clk, rst, inst_EX, pc_EX, ALUresult_EX, DataB_EX,
        inst_M, pc_M, ALUresult_M, DataB_M);
    MUX u_DataB_MUX(DataBSel, DataB_M, DataWB_WB, DataBSel_M);
    DMEM u_DMEM(clk, inst_M, MemRW, ALUresult_M, DataBSel_M, DataR);
    WB_MUX u_WB_MUX(WBSel, pc_M+4, ALUresult_M, DataR, DataWB_M);
    M_WB_Reg u_M_WB_Reg(clk, rst, inst_M, DataWB_M, inst_WB, DataWB_WB);
    MUX u_PCSel_MUX(PCSel, pc_IF+4, ALUresult_EX, nextpc);
endmodule

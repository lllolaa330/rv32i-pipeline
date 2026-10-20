// Recovered from the 2025 course presentation, slides 10-11.
// Transcribed and formatted in 2026; see docs/provenance.md.
module Control_logic(
    input [31:0] inst_ID, input [31:0] inst_EX, input [31:0] inst_M, input [31:0] inst_WB,
    input BrEq, input BrLT, output reg PCSel, output reg [3:0] ALUSel,
    output reg [2:0] ImmSel, output reg RegWEn, output reg [1:0] ASel,
    output reg [1:0] BSel, output reg BrUn, output reg MemRW,
    output reg [1:0] WBSel, output reg DataBSel,
    output reg [1:0] branchASel, output reg [1:0] branchBSel
);
    reg RegWEn_WB, RegWEn_M;
    always @(*) begin
        case (inst_WB[6:0])
            7'b0110011: RegWEn_WB <= 1'b1;
            7'b0010011, 7'b0000011, 7'b1100111: RegWEn_WB <= 1'b1;
            7'b0100011: RegWEn_WB <= 1'b0;
            7'b1100011: RegWEn_WB <= 1'b0;
            7'b1101111: RegWEn_WB <= 1'b1;
            7'b0010111, 7'b0110111: RegWEn_WB <= 1'b1;
            default: RegWEn_WB <= 1'b0;
        endcase
    end
    always @(*) begin
        case (inst_M[6:0])
            7'b0110011: RegWEn_M <= 1'b1;
            7'b0010011, 7'b0000011, 7'b1100111: RegWEn_M <= 1'b1;
            7'b0100011: RegWEn_M <= 1'b0;
            7'b1100011: RegWEn_M <= 1'b0;
            7'b1101111: RegWEn_M <= 1'b1;
            7'b0010111, 7'b0110111: RegWEn_M <= 1'b1;
            default: RegWEn_M <= 1'b0;
        endcase
    end
    always @(*) begin
        if (inst_M[6:0] == 7'b0100011 && RegWEn_WB == 1 && inst_M[24:20] == inst_WB[11:7])
            DataBSel <= 1'b1;
        else DataBSel <= 1'b0;
    end
    always @(*) begin
        if (inst_EX[6:0] == 7'b1100011 && RegWEn_M == 1 && inst_EX[19:15] == inst_M[11:7])
            branchASel <= 2'b01;
        else if (inst_EX[6:0] == 7'b1100011 && RegWEn_WB == 1 && inst_EX[19:15] == inst_WB[11:7])
            branchASel <= 2'b10;
        else branchASel <= 2'b00;
    end
    always @(*) begin
        if (inst_EX[6:0] == 7'b1100011 && RegWEn_M == 1 && inst_EX[24:20] == inst_M[11:7])
            branchBSel <= 2'b01;
        else if (inst_EX[6:0] == 7'b1100011 && RegWEn_WB == 1 && inst_EX[24:20] == inst_WB[11:7])
            branchBSel <= 2'b10;
        else branchBSel <= 2'b00;
    end
    always @(*) begin
        case (inst_EX[6:0])
            7'b0110011: begin
                case (inst_EX[14:12])
                    3'b000: ALUSel <= (inst_EX[31:25]) ? 4'b1000 : 4'b0000;
                    3'b111: ALUSel <= 4'b0111;
                    3'b110: ALUSel <= 4'b0110;
                    3'b100: ALUSel <= 4'b0100;
                    3'b001: ALUSel <= 4'b0001;
                    3'b101: ALUSel <= (inst_EX[31:25]) ? 4'b1101 : 4'b0101;
                    3'b010: ALUSel <= 4'b0010;
                    3'b011: ALUSel <= 4'b0011;
                    default: ALUSel <= 4'b0000;
                endcase
            end
            7'b0010011: begin
                case (inst_EX[14:12])
                    3'b000: ALUSel <= 4'b0000;
                    3'b111: ALUSel <= 4'b0111;
                    3'b110: ALUSel <= 4'b0110;
                    3'b100: ALUSel <= 4'b0100;
                    3'b001: ALUSel <= 4'b0001;
                    3'b101: ALUSel <= (inst_EX[30]) ? 4'b1101 : 4'b0101;
                    3'b010: ALUSel <= 4'b0010;
                    3'b011: ALUSel <= 4'b0011;
                    default: ALUSel <= 4'b0000;
                endcase
            end
            7'b0110111: ALUSel <= 4'b1001;
            default: ALUSel <= 4'b0000;
        endcase
    end
    always @(*) begin
        case (inst_EX[6:0])
            7'b0110011: ImmSel <= 3'b000;
            7'b0010011, 7'b0000011, 7'b1100111: ImmSel <= 3'b001;
            7'b0100011: ImmSel <= 3'b010;
            7'b1100011: ImmSel <= 3'b100;
            7'b1101111: ImmSel <= 3'b101;
            7'b0010111, 7'b0110111: ImmSel <= 3'b011;
            default: ImmSel <= 3'b000;
        endcase
    end
    always @(*) begin
        if ((inst_EX[6:0] == 7'b0110011 || inst_EX[6:0] == 7'b0010011 ||
             inst_EX[6:0] == 7'b0000011 || inst_EX[6:0] == 7'b1100111 ||
             inst_EX[6:0] == 7'b0100011) && RegWEn_M == 1'b1 && inst_EX[19:15] == inst_M[11:7])
            ASel <= 2'b10;
        else if ((inst_EX[6:0] == 7'b0110011 || inst_EX[6:0] == 7'b0010011 ||
                  inst_EX[6:0] == 7'b0000011 || inst_EX[6:0] == 7'b1100111 ||
                  inst_EX[6:0] == 7'b0100011) && RegWEn_WB == 1'b1 && inst_EX[19:15] == inst_WB[11:7])
            ASel <= 2'b11;
        else begin
            case (inst_EX[6:0])
                7'b0110011, 7'b0010011, 7'b0000011, 7'b1100111, 7'b0100011: ASel <= 2'b01;
                7'b1100011, 7'b1101111, 7'b0010111, 7'b0110111: ASel <= 2'b00;
                default: ASel <= 2'b01;
            endcase
        end
    end
    always @(*) begin
        if (inst_EX[6:0] == 7'b0110011 && RegWEn_M == 1 && inst_EX[24:20] == inst_M[11:7])
            BSel <= 2'b10;
        else if (inst_EX[6:0] == 7'b0110011 && RegWEn_WB == 1 && inst_EX[24:20] == inst_WB[11:7])
            BSel <= 2'b11;
        else begin
            case (inst_EX[6:0])
                7'b0110011: BSel <= 2'b01;
                7'b0010011, 7'b0000011, 7'b1100111, 7'b0100011,
                7'b1100011, 7'b1101111, 7'b0010111, 7'b0110111: BSel <= 2'b00;
                default: BSel <= 2'b01;
            endcase
        end
    end
    always @(*) begin
        if (inst_EX[6:0] == 7'b1100011) begin
            case (inst_EX[14:12])
                3'b000: BrUn <= 1'b0;
                3'b001: BrUn <= 1'b0;
                3'b100: BrUn <= 1'b0;
                3'b101: BrUn <= 1'b0;
                3'b110: BrUn <= 1'b1;
                3'b111: BrUn <= 1'b1;
                default: BrUn <= 1'b0;
            endcase
        end else BrUn <= 1'b0;
    end
    always @(*) begin
        case (inst_M[6:0])
            7'b0110011: MemRW <= 1'b0;
            7'b0010011: MemRW <= 1'b0;
            7'b0000011, 7'b1100111: MemRW <= 1'b1;
            7'b0100011: MemRW <= 1'b1;
            7'b1100011: MemRW <= 1'b0;
            7'b1101111: MemRW <= 1'b0;
            7'b0010111, 7'b0110111: MemRW <= 1'b0;
            default: MemRW <= 1'b0;
        endcase
    end
    always @(*) begin
        case (inst_M[6:0])
            7'b0110011: WBSel <= 2'b01;
            7'b0010011: WBSel <= 2'b01;
            7'b0000011: WBSel <= 2'b00;
            7'b1100111: WBSel <= 2'b10;
            7'b0100011: WBSel <= 2'b00;
            7'b1100011: WBSel <= 2'b01;
            7'b1101111: WBSel <= 2'b10;
            7'b0010111, 7'b0110111: WBSel <= 2'b01;
            default: WBSel <= 2'b01;
        endcase
    end
    always @(*) begin
        case (inst_WB[6:0])
            7'b0110011: RegWEn <= 1'b1;
            7'b0010011, 7'b0000011, 7'b1100111: RegWEn <= 1'b1;
            7'b0100011: RegWEn <= 1'b0;
            7'b1100011: RegWEn <= 1'b0;
            7'b1101111: RegWEn <= 1'b1;
            7'b0010111, 7'b0110111: RegWEn <= 1'b1;
            default: RegWEn <= 1'b0;
        endcase
    end
    always @(*) begin
        case (inst_EX[6:0])
            7'b0110011: PCSel <= 1'b0;
            7'b0010011: PCSel <= 1'b0;
            7'b0000011: PCSel <= 1'b0;
            7'b1100111: PCSel <= 1'b1;
            7'b0100011: PCSel <= 1'b0;
            7'b1100011: begin
                case (inst_EX[14:12])
                    3'b000: PCSel <= BrEq;
                    3'b001: PCSel <= ~BrEq;
                    3'b100: PCSel <= BrLT;
                    3'b101: PCSel <= ~BrLT;
                    3'b110: PCSel <= BrLT;
                    3'b111: PCSel <= ~BrLT;
                    default: PCSel <= 1'b0;
                endcase
            end
            7'b1101111: PCSel <= 1'b1;
            7'b0010111, 7'b0110111: PCSel <= 1'b0;
            default: PCSel <= 1'b0;
        endcase
    end
endmodule

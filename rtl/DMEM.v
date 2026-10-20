// Recovered from the 2025 course presentation, slides 19.
// Transcribed and formatted in 2026; see docs/provenance.md.
module DMEM(input clk, input [31:0] inst_M, input MemRW,
            input [31:0] addr, input [31:0] DataW, output reg [31:0] DataR);
    wire [2:0] funct3;
    reg [31:0] data_mem [0:4095];
    reg [31:0] sel_data, write_data;
    integer file, i=0;
    initial begin
        $readmemh("dmem.txt", data_mem);
    end
    assign funct3 = inst_M[14:12];
    always @(*) begin
        if (MemRW) begin
            sel_data <= data_mem[addr[13:2]];
            case (funct3)
                3'b000: begin
                    DataR <= {{24{sel_data[7]}}, sel_data[7:0]};
                    write_data <= {{24{DataW[7]}}, DataW[7:0]};
                end
                3'b001: begin
                    DataR <= {{16{sel_data[15]}}, sel_data[15:0]};
                    write_data <= {{16{DataW[15]}}, DataW[15:0]};
                end
                3'b010: begin
                    DataR <= sel_data;
                    write_data <= DataW;
                end
                3'b100: begin
                    DataR <= {{24{1'b0}}, sel_data[7:0]};
                    write_data <= 32'h0;
                end
                3'b101: begin
                    DataR <= {{16{1'b0}}, sel_data[15:0]};
                    write_data <= 32'h0;
                end
                default: begin
                    DataR <= 32'h0;
                    write_data <= 32'h0;
                end
            endcase
        end else begin
            DataR <= 32'h0;
            write_data <= 32'h0;
        end
    end
    always @(posedge clk) begin
        if (inst_M[6:0] == 7'b0100011)
            data_mem[addr[13:2]] <= write_data;
        else
            data_mem[addr[13:2]] <= data_mem[addr[13:2]];
    end
    always @(*) begin
        file = $fopen("dmem.txt", "w");
        $fclose(file);
        file = $fopen("dmem.txt", "a");
        for (i = 0; i < 4095; i = i + 1) begin
            $fdisplay(file, "%h", data_mem[i]);
        end
        $fclose(file);
    end
endmodule

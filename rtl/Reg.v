// Recovered from the 2025 course presentation, slides 15.
// Transcribed and formatted in 2026; see docs/provenance.md.
module Reg(input clk, input RegWEn, input [4:0] AddrD, input [4:0] AddrA,
           input [4:0] AddrB, input [31:0] DataD, output [31:0] DataA, output [31:0] DataB);
    reg [31:0] reg_file [0:31];
    integer file;
    integer i = 0;
    initial begin
        $readmemh("reg_file.txt", reg_file);
    end
    always @(posedge clk) begin
        if (RegWEn) begin
            reg_file[AddrD] <= (AddrD==0) ? 0 : DataD;
            file = $fopen("reg_file.txt", "w");
            $fclose(file);
            file = $fopen("reg_file.txt", "a");
            for (i = 0; i < 32; i = i + 1) begin
                $fdisplay(file, "%h", reg_file[i]);
            end
            $fclose(file);
        end else begin
            file = $fopen("reg_file.txt", "w");
            $fclose(file);
            file = $fopen("reg_file.txt", "a");
            for (i = 0; i < 32; i = i + 1) begin
                $fdisplay(file, "%h", reg_file[i]);
            end
            $fclose(file);
        end
    end
    assign DataA = (AddrA == 0) ? 0 : reg_file[AddrA];
    assign DataB = (AddrB == 0) ? 0 : reg_file[AddrB];
endmodule

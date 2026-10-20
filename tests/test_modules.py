"""2026 recovery checks; not the original course test1-test10."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
RTL = sorted((ROOT / 'rtl').glob('*.v'))

class RecoveredModules(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        for tool in ('iverilog', 'vvp'):
            if not shutil.which(tool):
                raise RuntimeError(f'{tool} is required')

    def simulate(self, declarations, body):
        # Original models overwrite input files: always run in an isolated directory.
        with tempfile.TemporaryDirectory(prefix='rv32i-test-') as directory:
            work = Path(directory)
            for name, count in [('program.txt',256), ('reg_file.txt',32), ('dmem.txt',4096)]:
                (work/name).write_text('00000000\n'*count)
            tb=work/'tb.sv'
            tb.write_text('`timescale 1ns/1ps\nmodule tb;\n'+declarations+'\ninitial begin\n'+body+'\n$display("PASS"); $finish;\nend\nendmodule\n')
            result=subprocess.run(['iverilog','-g2012','-s','tb','-o',str(work/'sim'),*map(str,RTL),str(tb)],cwd=work,text=True,capture_output=True,timeout=30)
            self.assertEqual(result.returncode,0,result.stderr)
            result=subprocess.run(['vvp',str(work/'sim')],cwd=work,text=True,capture_output=True,timeout=30)
            self.assertEqual(result.returncode,0,result.stdout+result.stderr)
            self.assertIn('PASS',result.stdout)

    def test_components_elaborate(self):
        with tempfile.TemporaryDirectory() as directory:
            for path in RTL:
                if path.stem=='Top_module': continue
                with self.subTest(module=path.stem):
                    result=subprocess.run(['iverilog','-g2012','-s',path.stem,'-o',str(Path(directory)/'sim'),str(path)],text=True,capture_output=True,timeout=30)
                    self.assertEqual(result.returncode,0,result.stderr)

    @unittest.expectedFailure
    def test_known_missing_top_dependency(self):
        with tempfile.TemporaryDirectory() as directory:
            result=subprocess.run(['iverilog','-g2012','-s','Top_module','-o',str(Path(directory)/'sim'),*map(str,RTL)],text=True,capture_output=True,timeout=30)
            self.assertEqual(result.returncode,0,result.stderr)

    def test_alu(self):
        vectors=[(0,0xffffffff,1,0),(8,0,1,0xffffffff),(7,0xa5,15,5),(6,0xa0,15,0xaf),(4,0xa5,255,0x5a),(1,1,31,0x80000000),(1,1,32,1),(5,0x80000000,31,1),(13,0x80000000,31,0xffffffff),(2,0xffffffff,0,1),(3,0xffffffff,0,0),(9,123,0xabcd0000,0xabcd0000),(15,1,1,0)]
        body='\n'.join(f'a=32\'h{a:08x}; b=32\'h{b:08x}; s={s}; #1; if(y!==32\'h{y:08x}) $fatal(1,"ALU {i}");' for i,(s,a,b,y) in enumerate(vectors))
        self.simulate('reg [31:0] a,b; reg [3:0] s; wire [31:0] y; ALU dut(a,b,s,y);',body)

    def test_immediates(self):
        vectors=[(0xfff00013,1,0xffffffff),(0x80000013,1,0xfffff800),(0xfe000fa3,2,0xffffffff),(0xabcde037,3,0xabcde000),(0xfe000ee3,4,0xfffffffc),(0x00400063,4,0),(0x0080006f,5,8),(0xffdff06f,5,0xfffffffc),(0xffffffff,0,0)]
        body='\n'.join(f'inst=32\'h{i:08x}; s={s}; #1; if(y!==32\'h{y:08x}) $fatal(1,"immediate");' for i,s,y in vectors)
        self.simulate('reg [31:0] inst; reg [2:0] s; wire [31:0] y; ImmGen dut(inst,s,y);',body)

    def test_branch_comparison(self):
        self.simulate('reg un; reg [31:0] a,b; wire eq,lt; Branch_Comp dut(un,a,b,eq,lt);', '''
            a=32'hffffffff; b=0; un=0; #1; if(lt!==1 || eq!==0) $fatal(1,"signed");
            un=1; #1; if(lt!==0) $fatal(1,"unsigned");
            b=a; #1; if(eq!==1 || lt!==0) $fatal(1,"equal");
        ''')

    def test_muxes(self):
        self.simulate('''reg [1:0] s; reg one; wire [31:0] y,z,w;
            MUX_2 m(s,32'd10,32'd20,32'd30,32'd40,y);
            MUX n(one,32'd50,32'd60,z); WB_MUX p(s,32'd10,32'd20,32'd30,w);''','''
            s=0; one=0; #1; if(y!==10 || z!==50 || w!==30) $fatal;
            s=1; one=1; #1; if(y!==20 || z!==60 || w!==20) $fatal;
            s=2; #1; if(y!==30 || w!==10) $fatal;
            s=3; #1; if(y!==40 || w!==0) $fatal;
        ''')

    def test_pipeline(self):
        self.simulate('''reg clk=0,rst=0,flush=0; reg [31:0] inst=32'h12345678,pc=32'h40;
            wire [31:0] npc,ii,pi,ie,pe,ae,be,im,pm,am,bm,iw,dw;
            IF f(clk,rst,pc,npc); IF_ID_Reg a(clk,rst,inst,pc,flush,ii,pi);
            ID_EX_Reg b(clk,rst,inst,pc,32'd11,32'd22,flush,ie,pe,ae,be);
            EX_M_Reg c(clk,rst,inst,pc,32'd33,32'd44,im,pm,am,bm);
            M_WB_Reg d(clk,rst,inst,32'd55,iw,dw);''','''
            #1; rst=1; #1;
            if(npc!==0 || ii!==0 || pi!==0 || ie!==0 || pe!==0 || im!==0 || pm!==0 || am!==0 || bm!==0 || iw!==0 || dw!==0) $fatal(1,"reset");
            rst=0; #1; clk=1; #1;
            if(npc!==pc || ii!==inst || pi!==pc || ie!==inst || pe!==pc || ae!==11 || be!==22 || im!==inst || pm!==pc || am!==33 || bm!==44 || iw!==inst || dw!==55) $fatal(1,"transfer");
            clk=0; flush=1; #1; clk=1; #1; if(ii!==0 || pi!==0 || ie!==0 || pe!==0) $fatal(1,"flush");
        ''')

    def test_control_hazard(self):
        body=''
        for f in (0,1,4,5,6,7):
            for eq in (0,1):
                for lt in (0,1):
                    taken=eq if f==0 else not eq if f==1 else lt if f in (4,6) else not lt
                    body+=f'inst=32\'h{((f<<12)|0x63):08x}; eq={eq}; lt={lt}; #1; if(a!==1\'b{int(taken)} || b!==1\'b{int(taken)}) $fatal(1,"branch flush");\n'
        body+='''inst=32'h6f; #1; if(a!==1 || b!==1) $fatal;
            inst=32'h67; #1; if(a!==1 || b!==1) $fatal;
            inst=32'h13; #1; if(a!==0 || b!==0) $fatal;'''
        self.simulate('reg [31:0] inst; reg eq,lt; wire a,b; Control_Hazard dut(inst,eq,lt,a,b);',body)

    CONTROL='''reg [31:0] id=0,ex=0,m=0,wb=0; reg eq=0,lt=0;
        wire pcsel,rwen,un,mrw,ds; wire [3:0] alu; wire [2:0] imm; wire [1:0] asel,bsel,wsel,ba,bb;
        Control_logic dut(id,ex,m,wb,eq,lt,pcsel,alu,imm,rwen,asel,bsel,un,mrw,wsel,ds,ba,bb);'''

    def test_forwarding_priority(self):
        self.simulate(self.CONTROL,'''ex=32'h00528333; m=32'h00100293; wb=32'h00200293; #1;
            if(asel!==2 || bsel!==2 || rwen!==1) $fatal(1,"M priority");
            m=0; #1; if(asel!==3 || bsel!==3) $fatal(1,"WB forwarding");
            wb=0; #1; if(asel!==1 || bsel!==1) $fatal(1,"register operands");
            ex=32'h00528063; m=32'h00100293; eq=1; #1;
            if(ba!==1 || bb!==1 || pcsel!==1 || imm!==4) $fatal(1,"branch");
            eq=0; #1; if(pcsel!==0) $fatal;
            ex=0; m=32'h00502023; wb=32'h00100293; #1; if(ds!==1 || mrw!==1) $fatal(1,"store forwarding");''')

    @unittest.expectedFailure
    def test_known_x0_forwarding(self):
        self.simulate(self.CONTROL,'''ex=32'h00100093; m=32'h00500013; wb=0; #1;
            // addi x1,x0,1 must not consume addi x0,x0,5 via forwarding.
            if(asel!==1) $fatal(1,"rd=x0 must not forward from M");''')

    def test_register_file(self):
        self.simulate('''reg clk=0,we=0; reg [4:0] rd=0,ra=0,rb=0; reg [31:0] data=0;
            wire [31:0] a,b; Reg dut(clk,we,rd,ra,rb,data,a,b);''','''
            #1; we=1; rd=5; ra=5; rb=0; data=32'h12345678; #1; clk=1; #1;
            if(a!==data || b!==0) $fatal(1,"write/read");
            clk=0; rd=0; ra=0; data=32'hffffffff; #1; clk=1; #1; if(a!==0 || b!==0) $fatal(1,"x0");''')

    def test_imem(self):
        self.simulate('reg [31:0] pc=0; wire [31:0] inst; wire [4:0] a,b; IMEM dut(pc,inst,a,b);','''
            #1; dut.inst_mem[1]=32'h00528333; pc=4; #1;
            if(inst!==32'h00528333 || a!==5 || b!==5) $fatal(1,"fetch");''')

    DMEM='''reg clk=0,rw=1; reg [31:0] inst=32'h00002003,addr=0,data=0;
        wire [31:0] result; DMEM dut(clk,inst,rw,addr,data,result);'''

    def test_dmem_word_and_sign_extension(self):
        self.simulate(self.DMEM,'''#1; data=32'h123480ff; inst=32'h00002023; #1; clk=1; #1;
            clk=0; inst=32'h00002003; #1; if(result!==32'h123480ff) $fatal(1,"word");
            inst=32'h00000003; #1; if(result!==32'hffffffff) $fatal(1,"lb offset 0");
            inst=32'h00005003; #1; if(result!==32'h80ff) $fatal(1,"lhu offset 0");''')

    @unittest.expectedFailure
    def test_known_byte_load_offset(self):
        self.simulate(self.DMEM,'''#1; dut.data_mem[0]=32'h12345678; inst=32'h00004003; addr=1; #1;
            if(result!==32'h56) $fatal(1,"LBU offset 1 must select second byte");''')

    @unittest.expectedFailure
    def test_known_byte_store(self):
        self.simulate(self.DMEM,'''#1; dut.data_mem[0]=32'h12345678; inst=32'h00000023; data=32'haa; #1; clk=1; #1;
            if(dut.data_mem[0]!==32'h123456aa) $fatal(1,"SB must preserve other bytes");''')

if __name__=='__main__':
    unittest.main(verbosity=2)

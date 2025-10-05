module testbench();

  logic        clk;
  logic        reset;

  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  // instantiate device to be tested
  top dut(clk, reset, WriteData, DataAdr, MemWrite);

  initial 
    begin
      $dumpfile("wave.vcd");
      $dumpvars(0, testbench);
    end
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check results
  always @(negedge clk)
    begin
      if(MemWrite) begin
        if(DataAdr === 100 & WriteData === 25) begin
          $display("Simulation succeeded");
          $stop;
        end else if (DataAdr !== 96) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule

module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

  logic [31:0] PC, Instr, ReadData;
  
  // instantiate processor and memories
  riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr, 
                       WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

module riscvsingle(input  logic        clk, reset,
                   output logic [31:0] PC,
                   input  logic [31:0] Instr,
                   output logic        MemWrite,
                   output logic [31:0] ALUResult, WriteData,
                   input  logic [31:0] ReadData);

  logic       ALUSrc, RegWrite, Jump, Zero;
  logic [1:0] ResultSrc, ImmSrc;
  logic [4:0] ALUControl;

  controller c(Instr[6:0], Instr[14:12], Instr[30], Instr[26:25], Zero,
               ResultSrc, MemWrite, PCSrc,
               ALUSrc, RegWrite, Jump,
               ImmSrc, ALUControl);
  datapath dp(clk, reset, ResultSrc, PCSrc,
              ALUSrc, RegWrite,
              ImmSrc, ALUControl,
              Zero, PC, Instr,
              ALUResult, WriteData, ReadData);
endmodule

module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic [1:0] funct7b10, // First two bits of funct7 for RVX10
                  input  logic       Zero,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [4:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op[5], funct3, funct7b5, funct7b10, ALUOp, ALUControl);

  assign PCSrc = Branch & Zero | Jump;
endmodule

module maindec(input  logic [6:0] op,
               output logic [1:0] ResultSrc,
               output logic       MemWrite,
               output logic       Branch, ALUSrc,
               output logic       RegWrite, Jump,
               output logic [1:0] ImmSrc,
               output logic [1:0] ALUOp);

  logic [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always_comb
    case(op)
    // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type 
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0001011: controls = 11'b1_xx_0_0_00_0_11_0; // Custom-0, R-type
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // non-implemented instruction
    endcase
endmodule

module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic       funct7b5, 
              input  logic [1:0] funct7b10,
              input  logic [1:0] ALUOp,
              output logic [4:0] ALUControl);

  logic  RtypeSub;
  assign RtypeSub = funct7b5 & opb5;  // TRUE for R-type subtract instruction

  always_comb
    case(ALUOp)
      2'b00:                ALUControl = 5'b00000; // addition
      2'b01:                ALUControl = 5'b00001; // subtraction
      2'b10: case(funct3) // R-type or I-type ALU
                 3'b000:  if (RtypeSub) 
                            ALUControl = 5'b00001; // sub
                          else          
                            ALUControl = 5'b00000; // add, addi
                 3'b010:    ALUControl = 5'b00101; // slt, slti
                 3'b110:    ALUControl = 5'b00011; // or, ori
                 3'b111:    ALUControl = 5'b00010; // and, andi
                 default:   ALUControl = 5'bxxxxx; // ???
             endcase

      2'b11: case(funct7b10) //RVX10 Instructions

                2'b00:  case(funct3)
                          3'b000:  ALUControl = 5'b01000;  // andn
                          3'b001:  ALUControl = 5'b01001;  // orn
                          3'b010:  ALUControl = 5'b01010;  // xnor
                          default: ALUControl = 5'bxxxxx;  // ???
                        endcase

                2'b01:  case(funct3)
                          3'b000:  ALUControl = 5'b01011;  // min
                          3'b001:  ALUControl = 5'b01100;  // max
                          3'b010:  ALUControl = 5'b01101;  // minu
                          3'b011:  ALUControl = 5'b01110;  // maxu
                          default: ALUControl = 5'bxxxxx;  // ???
                        endcase

                2'b10:  case(funct3)
                          3'b000:  ALUControl = 5'b01111;  // rol
                          3'b001:  ALUControl = 5'b10000;  // ror
                          default: ALUControl = 5'bxxxxx;  // ???
                        endcase
                        
                2'b11:  case(funct3)
                          3'b000:  ALUControl = 5'b10001;  // abs
                          default: ALUControl = 5'bxxxxx;  // ???
                        endcase
                default: ALUControl = 5'bxxxxx;            // ???
             endcase
             
      default: ALUControl = 5'bxxxxx;
    endcase
endmodule

module datapath(input  logic        clk, reset,
                input  logic [1:0]  ResultSrc, 
                input  logic        PCSrc, ALUSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic [4:0]  ALUControl,
                output logic        Zero,
                output logic [31:0] PC,
                input  logic [31:0] Instr,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);

  logic [31:0] PCNext, PCPlus4, PCTarget;
  logic [31:0] ImmExt;
  logic [31:0] SrcA, SrcB;
  logic [31:0] Result;

  // next PC logic
  flopr #(32) pcreg(clk, reset, PCNext, PC); 
  adder       pcadd4(PC, 32'd4, PCPlus4);
  adder       pcaddbranch(PC, ImmExt, PCTarget);
  mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
 
  // register file logic
  regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20], 
                 Instr[11:7], Result, SrcA, WriteData);
  extend      ext(Instr[31:7], ImmSrc, ImmExt);

  // ALU logic
  mux2 #(32)  srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
  alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
  mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule

module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [ 4:0] a1, a2, a3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally (A1/RD1, A2/RD2)
  // write third port on rising edge of clock (A3/WD3/WE3)
  // register 0 hardwired to 0

  always_ff @(posedge clk)
    if (we3 & a3!=0) rf[a3] <= wd3;	// a3 != 0 ensures No Writes to x0

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(input  [31:0] a, b,
             output [31:0] y);

  assign y = a + b;
endmodule

module extend(input  logic [31:7] instr,
              input  logic [1:0]  immsrc,
              output logic [31:0] immext);
 
  always_comb
    case(immsrc) 
               // I-type 
      2'b00:   immext = {{20{instr[31]}}, instr[31:20]};  
               // S-type (stores)
      2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
               // B-type (branches)
      2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
               // J-type (jal)
      2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; 
      default: immext = 32'bx; // undefined
    endcase             
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule

module imem(input  logic [31:0] a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  initial
      $readmemh("riscvtest.txt",RAM);

  assign rd = RAM[a[31:2]]; // word aligned
endmodule

module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule

module alu(input  logic [31:0] a, b,
           input  logic [4:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  logic [31:0] condinvb, sum;
  logic        v;              // overflow
  logic        isAddSub;       // true when is add or subtract operation

  wire signed [31:0] signed_a = a;
  wire signed [31:0] signed_b = b;

  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];
  assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                    ~alucontrol[1] & alucontrol[0];
  logic [4:0] sh = b[4:0];
  always_comb
    case (alucontrol)
      5'b00000:  result = sum;                            // add
      5'b00001:  result = sum;                            // subtract
      5'b00010:  result = a & b;                          // and
      5'b00011:  result = a | b;                          // or
      5'b00100:  result = a ^ b;                          // xor
      5'b00101:  result = sum[31] ^ v;                    // slt
      5'b00110:  result = a << b[4:0];                    // sll
      5'b00111:  result = a >> b[4:0];                    // srl

      //RVX10 instructions

      5'b01000:  result = a & ~b;                                         // andn
      5'b01001:  result = a | ~b;                                         // orn
      5'b01010:  result = ~(a ^ b);                                       // xnor
      5'b01011:  result = (signed_a < signed_b) ? a : b;                  // min
      5'b01100:  result = (signed_a > signed_b) ? a : b;                  // max
      5'b01101:  result = (a < b) ? a : b;                                // minu
      5'b01110:  result = (a > b) ? a : b;                                // maxu
      5'b01111:  result = (sh == 0) ? a : ((a << sh) | (a >> (32 - sh))); // rol
      5'b10000:  result = (sh == 0) ? a : ((a >> sh) | (a << (32 - sh))); // ror
      5'b10001:  result = (signed_a >= 0) ? a : (0 - a);                  // abs

      default: result = 32'bx;
    endcase

  assign zero = (result == 32'b0);
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
  
endmodule
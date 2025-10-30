`timescale 1ns/1ps
// Full five-stage pipeline datapath with forwarding, hazard detection, and branch/jump control.

module datapath (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] PC,
    input  logic [31:0] InstrIF,
    output logic        MemWrite_out,
    output logic [31:0] DataAdr_out,
    output logic [31:0] WriteData_out,
    input  logic [31:0] ReadData
);

  // ------------------------------------------------------------
  // Performance counters
  // ------------------------------------------------------------
  logic [31:0] cycle_count;
  logic [31:0] instr_retired;
  logic [31:0] stall_count;
  logic [31:0] flush_count;
  logic [31:0] branch_count;

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      cycle_count   <= 32'd0;
      instr_retired <= 32'd0;
      stall_count   <= 32'd0;
      flush_count   <= 32'd0;
      branch_count  <= 32'd0;
    end else begin
      cycle_count   <= cycle_count + 32'd1;
      if (stallF || stallD) stall_count <= stall_count + 32'd1;
      if (flushE)            flush_count <= flush_count + 32'd1;
    end
  end

  // ------------------------------------------------------------
  // IF stage
  // ------------------------------------------------------------
  logic [31:0] PC_reg;
  logic [31:0] PC_next;
  logic [31:0] PC_plus4;

  assign PC        = PC_reg;
  assign PC_plus4  = PC_reg + 32'd4;

  // IF/ID pipeline registers
  logic [31:0] IFID_PC;
  logic [31:0] IFID_Instr;

  // global control flags
  logic stallF, stallD, flushE, flushD;

  // Branch/Jump control
  logic        PCSrc;
  logic [31:0] PCTarget;

  assign PC_next = PCSrc ? PCTarget : PC_plus4;

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      PC_reg <= 32'd0;
    end else if (!stallF) begin
      PC_reg <= PC_next;
    end
  end

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      IFID_PC    <= 32'd0;
      IFID_Instr <= 32'h0000_0013; // NOP
    end else begin
      if (flushD) begin
        IFID_PC    <= 32'd0;
        IFID_Instr <= 32'h0000_0013; // NOP
      end else if (!stallD) begin
        IFID_PC    <= PC_reg;
        IFID_Instr <= InstrIF;
      end
    end
  end

  // ------------------------------------------------------------
  // ID stage
  // ------------------------------------------------------------
  logic [31:0] RegFile [0:31];

  integer i;
  initial begin
    for (i = 0; i < 32; i++) RegFile[i] = 32'd0;
  end

  logic [31:0] InstrD;
  logic [4:0]  Rs1D;
  logic [4:0]  Rs2D;
  logic [4:0]  RdD;

  assign InstrD = IFID_Instr;
  assign Rs1D   = InstrD[19:15];
  assign Rs2D   = InstrD[24:20];
  assign RdD    = InstrD[11:7];

  logic [31:0] ReadData1D;
  logic [31:0] ReadData2D;

  assign ReadData1D = (Rs1D != 5'd0) ? RegFile[Rs1D] : 32'd0;
  assign ReadData2D = (Rs2D != 5'd0) ? RegFile[Rs2D] : 32'd0;

  // control decode
  logic       RegWriteD, MemWriteD, MemToRegD, ALUSrcD, BranchD, JumpD;
  logic [1:0] ALUOpD, ImmSrcD, ResultSrcD;

  controller ctrl (
    .opcode    (InstrD[6:0]),
    .RegWrite  (RegWriteD),
    .MemWrite  (MemWriteD),
    .MemToReg  (MemToRegD),
    .ALUSrc    (ALUSrcD),
    .Branch    (BranchD),
    .Jump      (JumpD),
    .ALUOp     (ALUOpD),
    .ImmSrc    (ImmSrcD),
    .ResultSrc (ResultSrcD)
  );

  // immediates
  logic [11:0] immI, immS;
  logic [12:0] immB;
  logic [20:0] immJ;

  assign immI = InstrD[31:20];
  assign immS = {InstrD[31:25], InstrD[11:7]};
  assign immB = {InstrD[31], InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0};
  assign immJ = {InstrD[31], InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0};

  logic [31:0] ImmExtD;

  always_comb begin
    unique case (ImmSrcD)
      2'b00: ImmExtD = {{20{immI[11]}}, immI};
      2'b01: ImmExtD = {{20{immS[11]}}, immS};
      2'b10: ImmExtD = {{19{immB[12]}}, immB};
      2'b11: ImmExtD = {{11{immJ[20]}}, immJ};
      default: ImmExtD = 32'd0;
    endcase
  end

  // ID/EX pipeline registers
  logic [31:0] IDEX_ReadData1, IDEX_ReadData2, IDEX_Imm, IDEX_PC;
  logic [4:0]  IDEX_Rs1, IDEX_Rs2, IDEX_Rd;
  logic        IDEX_RegWrite, IDEX_MemWrite, IDEX_MemToReg, IDEX_ALUSrc, IDEX_Branch, IDEX_Jump;
  logic [1:0]  IDEX_ALUOp, IDEX_ResultSrc;
  logic [2:0]  IDEX_funct3;
  logic [6:0]  IDEX_funct7, IDEX_opcode;

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      IDEX_ReadData1  <= 32'd0;
      IDEX_ReadData2  <= 32'd0;
      IDEX_Imm        <= 32'd0;
      IDEX_PC         <= 32'd0;
      IDEX_Rs1        <= 5'd0;
      IDEX_Rs2        <= 5'd0;
      IDEX_Rd         <= 5'd0;
      IDEX_RegWrite   <= 1'b0;
      IDEX_MemWrite   <= 1'b0;
      IDEX_MemToReg   <= 1'b0;
      IDEX_ALUSrc     <= 1'b0;
      IDEX_Branch     <= 1'b0;
      IDEX_Jump       <= 1'b0;
      IDEX_ALUOp      <= 2'd0;
      IDEX_ResultSrc  <= 2'd0;
      IDEX_funct3     <= 3'd0;
      IDEX_funct7     <= 7'd0;
      IDEX_opcode     <= 7'd0;
    end else begin
      if (flushE) begin
        // bubble
        IDEX_ReadData1  <= 32'd0;
        IDEX_ReadData2  <= 32'd0;
        IDEX_Imm        <= 32'd0;
        IDEX_PC         <= 32'd0;
        IDEX_Rs1        <= 5'd0;
        IDEX_Rs2        <= 5'd0;
        IDEX_Rd         <= 5'd0;
        IDEX_RegWrite   <= 1'b0;
        IDEX_MemWrite   <= 1'b0;
        IDEX_MemToReg   <= 1'b0;
        IDEX_ALUSrc     <= 1'b0;
        IDEX_Branch     <= 1'b0;
        IDEX_Jump       <= 1'b0;
        IDEX_ALUOp      <= 2'd0;
        IDEX_ResultSrc  <= 2'd0;
        IDEX_funct3     <= 3'd0;
        IDEX_funct7     <= 7'd0;
        IDEX_opcode     <= 7'b0010011; // NOP-like
      end else if (!stallD) begin
        IDEX_ReadData1  <= ReadData1D;
        IDEX_ReadData2  <= ReadData2D;
        IDEX_Imm        <= ImmExtD;
        IDEX_PC         <= IFID_PC;
        IDEX_Rs1        <= Rs1D;
        IDEX_Rs2        <= Rs2D;
        IDEX_Rd         <= RdD;
        IDEX_RegWrite   <= RegWriteD;
        IDEX_MemWrite   <= MemWriteD;
        IDEX_MemToReg   <= MemToRegD;
        IDEX_ALUSrc     <= ALUSrcD;
        IDEX_Branch     <= BranchD;
        IDEX_Jump       <= JumpD;
        IDEX_ALUOp      <= ALUOpD;
        IDEX_ResultSrc  <= ResultSrcD;
        IDEX_funct3     <= InstrD[14:12];
        IDEX_funct7     <= InstrD[31:25];
        IDEX_opcode     <= InstrD[6:0];
      end
    end
  end

  // ------------------------------------------------------------
  // EX stage
  // ------------------------------------------------------------
  localparam logic [4:0]
    ALU_ADD  = 5'b00000,
    ALU_SUB  = 5'b00001,
    ALU_AND  = 5'b00010,
    ALU_OR   = 5'b00011,
    ALU_XOR  = 5'b00100,
    ALU_SLT  = 5'b00101,
    ALU_SLL  = 5'b00110,
    ALU_SRL  = 5'b00111,
    ALU_ANDN = 5'b01000,
    ALU_ORN  = 5'b01001,
    ALU_XNOR = 5'b01010,
    ALU_MIN  = 5'b01011,
    ALU_MAX  = 5'b01100,
    ALU_MINU = 5'b01101,
    ALU_MAXU = 5'b01110,
    ALU_ROL  = 5'b01111,
    ALU_ROR  = 5'b10000,
    ALU_ABS  = 5'b10001;

  function automatic logic [4:0] aluctrl (
      input logic [1:0] ALUOp,
      input logic [2:0] f3,
      input logic [6:0] f7,
      input logic [6:0] opcode
  );
    aluctrl = ALU_ADD;
    if (opcode == 7'b0001011) begin
      unique case ({f7, f3})
        {7'b0000000,3'b000}: aluctrl = ALU_ANDN;
        {7'b0000000,3'b001}: aluctrl = ALU_ORN;
        {7'b0000000,3'b010}: aluctrl = ALU_XNOR;
        {7'b0000001,3'b000}: aluctrl = ALU_MIN;
        {7'b0000001,3'b001}: aluctrl = ALU_MAX;
        {7'b0000001,3'b010}: aluctrl = ALU_MINU;
        {7'b0000001,3'b011}: aluctrl = ALU_MAXU;
        {7'b0000010,3'b000}: aluctrl = ALU_ROL;
        {7'b0000010,3'b001}: aluctrl = ALU_ROR;
        {7'b0000011,3'b000}: aluctrl = ALU_ABS;
        default:             aluctrl = ALU_ADD;
      endcase
    end else begin
      if (ALUOp == 2'b00)      aluctrl = ALU_ADD;
      else if (ALUOp == 2'b01) aluctrl = ALU_SUB;
      else begin
        unique case (f3)
          3'b000: aluctrl = (f7[5]) ? ALU_SUB : ALU_ADD;
          3'b010: aluctrl = ALU_SLT;
          3'b110: aluctrl = ALU_OR;
          3'b111: aluctrl = ALU_AND;
          default: aluctrl = ALU_ADD;
        endcase
      end
    end
  endfunction

  // EX/MEM and MEM/WB early declarations (for forwarding)
  logic [31:0] EXMEM_aluOut, EXMEM_writeData;
  logic [4:0]  EXMEM_rd;
  logic        EXMEM_RegWrite_local, EXMEM_MemWrite_local, EXMEM_MemToReg_local;

  logic [31:0] MEMWB_aluOut, MEMWB_readData;
  logic [4:0]  MEMWB_rd;
  logic        MEMWB_RegWrite_local, MEMWB_MemToReg_local;

  // Forwarding
  logic [1:0] ForwardA, ForwardB;
  logic [4:0] EX_Rs1, EX_Rs2;

  assign EX_Rs1 = IDEX_Rs1;
  assign EX_Rs2 = IDEX_Rs2;

  logic [4:0]  EXMEM_Rd, MEMWB_Rd;
  logic        EXMEM_RegWrite, MEMWB_RegWrite;
  logic [31:0] EXMEM_ALUOut,  MEMWB_Result;

  assign EXMEM_ALUOut   = EXMEM_aluOut;
  assign EXMEM_Rd       = EXMEM_rd;
  assign EXMEM_RegWrite = EXMEM_RegWrite_local;
  assign MEMWB_Rd       = MEMWB_rd;
  assign MEMWB_RegWrite = MEMWB_RegWrite_local;

  // ALU operand muxes and forwarding application
  logic [31:0] ALU_srcA, ALU_srcB;
  logic [31:0] ALU_input_A, ALU_input_B;

  assign ALU_srcA = IDEX_ReadData1;
  assign ALU_srcB = IDEX_ALUSrc ? IDEX_Imm : IDEX_ReadData2;

  always_comb begin
    ALU_input_A = ALU_srcA;
    ALU_input_B = ALU_srcB;

    if (IDEX_Rs1 != 5'd0) begin
      if (ForwardA == 2'b01)      ALU_input_A = EXMEM_ALUOut;
      else if (ForwardA == 2'b10) ALU_input_A = MEMWB_Result;
    end

    if (IDEX_Rs2 != 5'd0 && !IDEX_ALUSrc) begin
      if (ForwardB == 2'b01)      ALU_input_B = EXMEM_ALUOut;
      else if (ForwardB == 2'b10) ALU_input_B = MEMWB_Result;
    end
  end
  //230102112
  function automatic logic [31:0] alu_core (
      input logic [31:0] a,
      input logic [31:0] b,
      input logic [4:0]  ctrl
  );
    logic [31:0] add_res, sub_res;
    add_res = a + b;
    sub_res = a - b;

    unique case (ctrl)
      ALU_ADD:   alu_core = add_res;
      ALU_SUB:   alu_core = sub_res;
      ALU_AND:   alu_core = a & b;
      ALU_OR:    alu_core = a | b;
      ALU_XOR:   alu_core = a ^ b;
      ALU_SLT:   alu_core = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
      ALU_SLL:   alu_core = a << b[4:0];
      ALU_SRL:   alu_core = a >> b[4:0];
      ALU_ANDN:  alu_core = a & ~b;
      ALU_ORN:   alu_core = a | ~b;
      ALU_XNOR:  alu_core = ~(a ^ b);
      ALU_MIN:   alu_core = ($signed(a) < $signed(b)) ? a : b;
      ALU_MAX:   alu_core = ($signed(a) > $signed(b)) ? a : b;
      ALU_MINU:  alu_core = (a < b) ? a : b;
      ALU_MAXU:  alu_core = (a > b) ? a : b;
      ALU_ROL:   alu_core = (b[4:0] == 5'd0) ? a : ((a << b[4:0]) | (a >> (6'd32 - b[4:0])));
      ALU_ROR:   alu_core = (b[4:0] == 5'd0) ? a : ((a >> b[4:0]) | (a << (6'd32 - b[4:0])));
      ALU_ABS:   alu_core = ($signed(a) >= 0) ? a : (32'b0 - a);
      default:   alu_core = 32'd0;
    endcase
  endfunction

  logic [4:0]  ALUControlE;
  logic [31:0] ALU_resultE;
  logic        ZeroE;

  always_comb begin
    ALUControlE = aluctrl(IDEX_ALUOp, IDEX_funct3, IDEX_funct7, IDEX_opcode);
  end

  assign ALU_resultE = alu_core(ALU_input_A, ALU_input_B, ALUControlE);
  assign ZeroE       = (ALU_resultE == 32'd0);

  // Branch/Jump
  logic BranchTaken;

  always_comb begin
    BranchTaken = 1'b0;
    if (IDEX_Branch) begin
      unique case (IDEX_funct3)
        3'b000: BranchTaken =  ZeroE;         // beq
        3'b001: BranchTaken = ~ZeroE;         // bne
        3'b100: BranchTaken =  ALU_resultE[0];// blt  (encoded via ALU compare)
        3'b101: BranchTaken = ~ALU_resultE[0];// bge
        3'b110: BranchTaken =  ALU_resultE[0];// bltu
        3'b111: BranchTaken = ~ALU_resultE[0];// bgeu
        default: BranchTaken = 1'b0;
      endcase
    end
  end

  assign PCTarget = IDEX_PC + IDEX_Imm;
  assign PCSrc    = (BranchTaken && IDEX_Branch) || IDEX_Jump;
  assign flushD   = PCSrc;

  // Store-data forwarding
  logic [31:0] ForwardedStoreData;

  always_comb begin
    ForwardedStoreData = IDEX_ReadData2;
    if (IDEX_Rs2 != 5'd0) begin
      if (EXMEM_RegWrite_local && (EXMEM_rd != 5'd0) && (EXMEM_rd == IDEX_Rs2))
        ForwardedStoreData = EXMEM_aluOut;
      else if (MEMWB_RegWrite_local && (MEMWB_rd != 5'd0) && (MEMWB_rd == IDEX_Rs2))
        ForwardedStoreData = MEMWB_Result;
    end
  end

  // EX/MEM
  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      EXMEM_aluOut          <= 32'd0;
      EXMEM_writeData       <= 32'd0;
      EXMEM_rd              <= 5'd0;
      EXMEM_RegWrite_local  <= 1'b0;
      EXMEM_MemWrite_local  <= 1'b0;
      EXMEM_MemToReg_local  <= 1'b0;
    end else begin
      EXMEM_aluOut          <= ALU_resultE;
      EXMEM_writeData       <= ForwardedStoreData;
      EXMEM_rd              <= IDEX_Rd;
      EXMEM_RegWrite_local  <= IDEX_RegWrite;
      EXMEM_MemWrite_local  <= IDEX_MemWrite;
      EXMEM_MemToReg_local  <= IDEX_MemToReg;
    end
  end

  // MEM/WB
  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      MEMWB_aluOut          <= 32'd0;
      MEMWB_readData        <= 32'd0;
      MEMWB_rd              <= 5'd0;
      MEMWB_RegWrite_local  <= 1'b0;
      MEMWB_MemToReg_local  <= 1'b0;
    end else begin
      MEMWB_aluOut          <= EXMEM_aluOut;
      MEMWB_readData        <= ReadData;
      MEMWB_rd              <= EXMEM_rd;
      MEMWB_RegWrite_local  <= EXMEM_RegWrite_local;
      MEMWB_MemToReg_local  <= EXMEM_MemToReg_local;
    end
  end

  // Forwarding unit
  forwarding_unit fwd (
    .Rs1E      (EX_Rs1),
    .Rs2E      (EX_Rs2),
    .RdM       (EXMEM_Rd),
    .RdW       (MEMWB_Rd),
    .RegWriteM (EXMEM_RegWrite),
    .RegWriteW (MEMWB_RegWrite),
    .ForwardA  (ForwardA),
    .ForwardB  (ForwardB)
  );

  // MEM
  assign MemWrite_out = EXMEM_MemWrite_local;
  assign DataAdr_out  = EXMEM_aluOut;
  assign WriteData_out= EXMEM_writeData;

  // Write Back
  logic [31:0] WB_value;
  assign WB_value    = MEMWB_MemToReg_local ? MEMWB_readData : MEMWB_aluOut;
  assign MEMWB_Result= WB_value;

  always_ff @(posedge clk) begin
    if (MEMWB_RegWrite_local && (MEMWB_rd != 5'd0)) begin
      RegFile[MEMWB_rd] <= WB_value;
      instr_retired     <= instr_retired + 32'd1;
    end
  end

  // Hazard detection
  logic MemReadE;
  assign MemReadE = (IDEX_opcode == 7'b0000011);

  hazard_unit hunit (
    .MemReadE (MemReadE),
    .RdE      (IDEX_Rd),
    .Rs1D     (Rs1D),
    .Rs2D     (Rs2D),
    .stallF   (stallF),
    .stallD   (stallD),
    .flushE   (flushE)
  );
endmodule

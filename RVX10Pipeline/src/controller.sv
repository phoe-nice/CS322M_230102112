// controller.sv
// Simple combinational decode used in ID stage.
// Produces the main control signals for ID/EX.

module controller (
    input  logic [6:0] opcode,
    output logic       RegWrite,
    output logic       MemWrite,
    output logic       MemToReg,
    output logic       ALUSrc,
    output logic       Branch,
    output logic       Jump,
    output logic [1:0] ALUOp,
    output logic [1:0] ImmSrc,
    output logic [1:0] ResultSrc
);

  always_comb begin
    // defaults
    RegWrite  = 1'b0;
    MemWrite  = 1'b0;
    MemToReg  = 1'b0;
    ALUSrc    = 1'b0;
    Branch    = 1'b0;
    Jump      = 1'b0;
    ALUOp     = 2'b00;
    ImmSrc    = 2'b00;
    ResultSrc = 2'b00;

    unique case (opcode)
      7'b0000011: begin // lw
        RegWrite  = 1'b1;
        ALUSrc    = 1'b1;
        MemToReg  = 1'b1;
        ResultSrc = 2'b01;
        ImmSrc    = 2'b00;
        ALUOp     = 2'b00;
      end
      7'b0100011: begin // sw
        MemWrite  = 1'b1;
        ALUSrc    = 1'b1;
        ImmSrc    = 2'b01;
        ALUOp     = 2'b00;
      end
      7'b0110011: begin // R-type
        RegWrite  = 1'b1;
        ALUSrc    = 1'b0;
        ALUOp     = 2'b10;
        ImmSrc    = 2'b00;
        ResultSrc = 2'b00;
      end
      7'b0010011: begin // I-type ALU
        RegWrite  = 1'b1;
        ALUSrc    = 1'b1;
        ALUOp     = 2'b10;
        ImmSrc    = 2'b00;
        ResultSrc = 2'b00;
      end  //Roll No .230102112
      7'b1100011: begin // Branch
        Branch    = 1'b1;
        ALUOp     = 2'b01;
        ImmSrc    = 2'b10;
      end
      7'b1101111: begin // jal
        RegWrite  = 1'b1;
        Jump      = 1'b1;
        ResultSrc = 2'b10;
        ImmSrc    = 2'b11;
      end
      7'b1100111: begin // jalr
        RegWrite  = 1'b1;
        Jump      = 1'b1;
        ALUSrc    = 1'b1;
        ResultSrc = 2'b10;
        ImmSrc    = 2'b00;
        ALUOp     = 2'b00;
      end
      7'b0001011: begin // CUSTOM-0 (treat as R-type ALU)
        RegWrite  = 1'b1;
        ALUSrc    = 1'b0;
        ALUOp     = 2'b10;
        ImmSrc    = 2'b00;
      end
      default: begin end
    endcase
  end

endmodule
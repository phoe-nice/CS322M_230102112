// hazard_unit.sv
module hazard_unit (
    input  logic       MemReadE,
    input  logic [4:0] RdE,
    input  logic [4:0] Rs1D,
    input  logic [4:0] Rs2D,
    output logic       stallF,
    output logic       stallD,
    output logic       flushE
);
  // Load-use hazard detection
  always_comb begin
    stallF = 1'b0;
    stallD = 1'b0;
    flushE = 1'b0;

    if (MemReadE && (RdE != 5'd0) &&
       ((RdE == Rs1D) || (RdE == Rs2D))) begin
      stallF = 1'b1;
      stallD = 1'b1;
      flushE = 1'b1;
    end
  end
endmodule
// forwarding_unit.sv
module forwarding_unit (
    input  logic [4:0] Rs1E,
    input  logic [4:0] Rs2E,
    input  logic [4:0] RdM,
    input  logic [4:0] RdW,
    input  logic       RegWriteM,
    input  logic       RegWriteW,
    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB
);
  always_comb begin
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E)) ForwardA = 2'b01;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E)) ForwardA = 2'b10;

    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E)) ForwardB = 2'b01;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E)) ForwardB = 2'b10;
  end
endmodule

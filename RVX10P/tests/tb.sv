// tb_pipeline.sv
`timescale 1ns/1ps

module tb_pipeline;

  logic        clk;
  logic        reset;
  logic [31:0] WriteData;
  logic [31:0] DataAdr;
  logic        MemWrite;

  top_pipeline dut (
    .clk       (clk),
    .reset     (reset),
    .WriteData (WriteData),
    .DataAdr   (DataAdr),
    .MemWrite  (MemWrite)
  );

  initial begin
    $dumpfile("pipeline_tb.vcd");
    $dumpvars(0, tb_pipeline);
    reset = 1'b1; #22;
    reset = 1'b0;
  end
  //230102112
  always begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
  end

  always @(negedge clk) begin
    if (MemWrite) begin
      if ((DataAdr === 32'd100) && (WriteData === 32'd25)) begin
        $display("Simulation succeeded");
        $finish;
      end else if (DataAdr !== 32'd96) begin
        $display("Simulation failed");
        $finish;
      end
    end
  end
endmodule

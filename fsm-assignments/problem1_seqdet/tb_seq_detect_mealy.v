`timescale 1ns/1ps

module tb_seq_detect_mealy;
  reg clk, rst, din;
  wire y;

  seq_detect_mealy dut (
    .clk(clk),
    .rst(rst),
    .din(din),
    .y(y)
  );

  //Clock generation: 100 MHz → 10 ns period
  initial clk = 0;
  always #5 clk = ~clk;   // toggle every 5ns → 10ns period

  //Apply stimulus
  reg [19:0] bitstream = 20'b00110011011010011010;  // test input sequence
  integer i;

  initial begin
    $dumpfile("seq_detect_mealy.vcd");
    $dumpvars();

    // Keep reset de-asserted (always 0)
    rst = 0;

    // Start din at 0 before first bit
    din = 0;

    // Wait a little before driving data
    #10;

    //Giving bitstream to fsm, one bit per clock
    for (i = 19; i >= 0; i = i - 1) begin
      @(posedge clk);        // change din in the middle of the cycle
      din = bitstream[i];    // so it is stable at the next posedge
    end

    #50;
    $finish;
  end
endmodule
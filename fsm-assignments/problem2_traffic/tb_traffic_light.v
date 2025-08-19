`timescale 1ns/1ps

module tb_traffic_light;
  reg clk, rst;
  wire tick;
  wire ns_g, ns_y, ns_r, ew_g, ew_y, ew_r;

  // Instantiate fake prescaler for simulation
  reg [4:0] cyc;
  reg tick_reg;
  assign tick = tick_reg;

  always @(posedge clk) begin
      cyc <= cyc + 1;
      tick_reg <= (cyc % 5 == 0); // 1 tick every 20 cycles
  end

  traffic_light dut(
      .clk(clk), .rst(rst), .tick(tick),
      .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
      .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
  ); //DUT

  // Clock: 10ns period (100 MHz)
  always #5 clk = ~clk;

  initial begin
    $dumpfile("traffic_light.vcd");
    $dumpvars(0, tb_traffic_light);

    clk  = 0;
    rst  = 1;
    cyc  = 0;
    tick_reg = 0;

    // Reset
    repeat (2) @(posedge clk);
    rst = 0;

    // Run for ~60 ticks (~4 full cycles)
    repeat (1200) @(posedge clk);

    $stop;
  end
endmodule
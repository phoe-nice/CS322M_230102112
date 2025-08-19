`timescale 1ms/1ps

module tb_vending_mealy;
  reg clk, rst;
  reg [1:0] coin;
  wire dispense, chg5;

  // Instantiate DUT
  vending_mealy dut(
    .clk(clk),
    .rst(rst),
    .coin(coin),
    .dispense(dispense),
    .chg5(chg5)
  );

  // Clock generation (10 ns period)
  always #5 clk = ~clk;

  initial begin
    $dumpfile("vending_mealy_wave.vcd");
    $dumpvars(0, tb_vending_mealy);

    // Initialize signals
    clk = 0;
    rst = 1;
    coin = 2'b00;

    // Apply reset
    #10;
    rst = 0;

    // Insert 5 -> total = 5
    #10 coin = 2'b01;
    #10 coin = 2'b00;

    // Insert 10 -> total = 15
    #10 coin = 2'b10;
    #10 coin = 2'b00;

    // Insert 5 -> total = 20 -> dispense
    #10 coin = 2'b01;
    #10 coin = 2'b00;

    // Insert 10 -> total = 10
    #10 coin = 2'b10;
    #10 coin = 2'b00;

    // Insert 10 -> total = 20 -> dispense
    #10 coin = 2'b10;
    #10 coin = 2'b00;

    // Insert 15 path: 10 + 10 + 5 = 25 -> dispense + chg5
    #10 coin = 2'b10;   // total = 10
    #10 coin = 2'b00;
    #10 coin = 2'b10;   // total = 20 -> dispense
    #10 coin = 2'b00;

    // Insert sequence 15 + 10 = 25 case
    #10 coin = 2'b10;   // total = 10
    #10 coin = 2'b00;
    #10 coin = 2'b10;   // total = 20 -> dispense
    #10 coin = 2'b00;
    #10 coin = 2'b01;   // start again: 5
    #10 coin = 2'b00;
    #10 coin = 2'b10;   // total = 15
    #10 coin = 2'b00;
    #10 coin = 2'b10;   // total = 25 -> dispense + chg5
    #10 coin = 2'b00;

    // Finish simulation
    #50 $finish;
  end

endmodule

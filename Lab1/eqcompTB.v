`timescale 1ns/1ns
`include "eqcomparator4bit.v"

module tb();

  reg a,b; //inputs are a and b
  wire c; //outputs are c

  eqcomparator4bit dut(
    .A(a),
    .B(b),
    .C(c)
  );

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    a = 4'b0001; b = 4'b0000; //A = 0001, B = 0000
    #10; //delay

    a = 4'b0100; b = 4'b0100; //A = 0100, B = 0100
    #10; //delay

    a = 4'b1011; b = 4'b1100; //A = 1111, B = 1111
    #10; //delay

    a = 4'b0101; b = 4'b1010; //A = 0101, B = 1010
    #10; //delay

    a = 4'b1110; b = 4'b1101; //A = 0101, B = 1010
    #10; //delay

    $display("Test is completed...");
  end

endmodule
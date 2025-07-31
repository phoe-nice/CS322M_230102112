`timescale 1ns/1ns
`include "mycomparator.v"

module tb();

  reg a,b; //inputs are a and b
  wire gt, eq, lt; //outputs are gt, eq and lt

  mycomparator dut(
    .A(a),
    .B(b),
    .o1(gt)
    .o2(eq),
    .o3(lt)
  );

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    a = 1'b0; b = 1'b0; //A = 0, B = 0
    #10; //delay

    a = 1'b0; b = 1'b1; //A = 0, B = 1
    #10; //delay

    a = 1'b1; b = 1'b0; //A = 1, B = 0
    #10; //delay

    a = 1'b1; b = 1'b1; //A = 1, B = 1
    #10; //delay

    $display("Test is completed...");
  end

endmodule
module 4biteqcomp(
  input [3:0] A;
  input [3:0] B;
  output C;
); //module instantiation
  wire [3:0] w1; //internal wire

  w1 = A ~^ B; //XNOR will give all bits of C 1 if the bits of A and B are same
  C = &w1; //Applying AND on all the bits of w1 to assign 1 to C when all bits are same

  //Can also be done behaviorally by writing C = (A==B) ? 1 : 0;

endmodule //end of module
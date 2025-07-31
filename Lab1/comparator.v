module (
  input A;
  input B;
  output o1;
  output o2;
  output o3;
); //module  instantiation

  o1 = A & ~B; //minterm corresponding to when A is 1 and B is 0, i.e., A > B
  o2 = A ~^ B; //XNOR will return one if both A and B are same
  o3 = ~A & B; //minterm corresponding to when A is 0 and B is 1, i.e., A < B

endmodule //end of module
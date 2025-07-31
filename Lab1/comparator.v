module comparator(
  input A,
  input B,
  output o1,
  output o2,
  output o3
);

  assign o1 = A & ~B; //minterm corresponding to when A is 1 and B is 0, i.e., A > B
  assign o2 = A ~^ B; //XNOR will return one if both A and B are same
  assign o3 = ~A & B; //minterm corresponding to when A is 0 and B is 1, i.e., A < B

endmodule
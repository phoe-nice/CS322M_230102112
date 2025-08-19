`timescale 1ns / 1ps

// Sequence detector (Mealy) for pattern 1101
module seq_detect_mealy(
  input  wire clk,
  input  wire rst,
  input  wire din,
  output wire y
);

  //State encoding
  parameter [1:0]
    S0 = 2'b00,    // No start of the sequence detected
    S1 = 2'b01,    // Saw '1'
    S2 = 2'b10,    // Saw "11"
    S3 = 2'b11;    // Saw "110"

  reg [1:0] state, next_state;

  //State register
  always @(posedge clk) begin
    if (rst)
      state <= S0;          // If Reset, go back to start state
    else
      state <= next_state;  // State update
  end

  //Next-state logic
  always @(*) begin
    case (state)
      S0:  next_state = (din) ? S1 : S0;  // If 1 go to S1 else go to S0 (seen 1 then S1)
      S1:  next_state = (din) ? S2 : S0;  // If 1 go to S2 else go to S0 (seen 11 then S2)
      S2:  next_state = (din) ? S2 : S3;  // If 1 stay in S2 or else go to S3 (seen 1"11" so stay in S2, if 0 seen 110 so go to S3)
      S3:  next_state = (din) ? S1 : S0;  // If 1 go to S1 as seen 1101, if 0 go to S0 as seen 1100
      default: next_state = S0;           // safety default
    endcase
  end

  //Mealy output
  // Output will be 1 when state is S3 and the current input is 1.
  assign y = (state == S3) & din;

endmodule
`timescale 1ms / 1ps

module vending_mealy(
  input wire clk,
  input wire rst,
  input wire [1:0] coin,
  output reg dispense,
  output reg chg5
);


  // State encoding using parameters
  parameter S0  = 2'b00;  // Total = 0
  parameter S5  = 2'b01;  // Total = 5
  parameter S10 = 2'b10;  // Total = 10
  parameter S15 = 2'b11;  // Total = 15

  reg [1:0] state, next_state;

  // Sequential state register
  always @(posedge clk) begin
    if (rst)
      state <= S0;
    else
      state <= next_state;
  end

  // Combinational next-state logic + outputs (Mealy)
  always @(*) begin
    //Defaults
    next_state = state;
    dispense   = 0;
    chg5       = 0;

    case (state)
      S0: begin
        if (coin == 2'b01)      next_state = S5;   // +5
        else if (coin == 2'b10) next_state = S10;  // +10
        else if (coin == 2'b00) next_state = S0;   //idle
      end

      S5: begin
        if (coin == 2'b01)      next_state = S10;  // +5
        else if (coin == 2'b10) next_state = S15;  // +10
        else if (coin == 2'b00) next_state = S5;   //idle
      end

      S10: begin
        if (coin == 2'b01)      next_state = S15;  // +5
        else if (coin == 2'b10) begin
          dispense   = 1;                      //Vend at 20
          next_state = S0;
        end
        else if (coin == 2'b00) next_state = S10; //idle
      end

      S15: begin
        if (coin == 2'b01) begin
          dispense   = 1;                      //Vend at 20
          next_state = S0;
        end
        else if (coin == 2'b10) begin
          dispense   = 1;                      //Vend at 25
          chg5       = 1;                      //Return 5
          next_state = S0;
        end
        else if (coin == 2'b00) next_state = S15; //idle
      end
    endcase
  end

endmodule

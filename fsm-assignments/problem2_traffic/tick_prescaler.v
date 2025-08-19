
module tick_prescaler #(
  parameter integer CLK_FREQ_HZ = 50_000_000, // fast system clock
  parameter integer TICK_HZ     = 1           // desired tick rate
)(
  input  wire clk,    // fast system clock
  input  wire rst,    // sync active-high reset
  output reg  tick    // 1-cycle pulse at TICK_HZ
);

  localparam integer DIVISOR = CLK_FREQ_HZ / TICK_HZ;
  reg [$clog2(DIVISOR)-1:0] counter;

  always @(posedge clk) begin
    if (rst) begin
      counter <= 0;
      tick    <= 0;
    end else if (counter == DIVISOR-1) begin
      counter <= 0;
      tick    <= 1;   // pulse for 1 cycle
    end else begin
      counter <= counter + 1;
      tick    <= 0;
    end
  end

endmodule
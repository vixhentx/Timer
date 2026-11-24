// 时钟节拍发生器: 产生 1Hz 单周期使能信号和数码管闪烁信号.
module tick_generator #(
    parameter integer CLK_FREQ = 50000000,       // 输入时钟频率(Hz)
    parameter integer BLINK_HALF_PERIOD = 500   // 闪烁半周期(ms)
) (
    input clk,                            // 系统时钟
    output reg tick_1hz = 1'b0,           // 每秒一个系统时钟周期的使能脉冲
    output reg blink = 1'b0               // 低频闪烁方波
);

  reg [31:0] second_count = 32'd0;
  reg [31:0] blink_count = 32'd0;

  always @(posedge clk) begin
    tick_1hz <= 1'b0;
    if (second_count >= CLK_FREQ - 1) begin
      second_count <= 32'd0;
      tick_1hz <= 1'b1;
    end else begin
      second_count <= second_count + 1'b1;
    end

    if (blink_count >= (CLK_FREQ * BLINK_HALF_PERIOD) - 1) begin
      blink_count <= 32'd0;
      blink <= ~blink;
    end else begin
      blink_count <= blink_count + 1'b1;
    end
  end

endmodule

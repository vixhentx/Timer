// 按钮处理模块, 进行消抖, 长按检测等等.
// 采用响应式 debounce 语义: 输入改变时重置计数, 信号稳定达到阈值后产生事件脉冲.
module button #(
    parameter integer CLK_FREQ = 50000000,       // 时钟频率(Hz)
    parameter integer DEBOUNCE_MS = 20,           // 消抖时间(ms)
    parameter integer LONG_PRESS_MS = 1000,       // 长按判定时间(ms)
    parameter integer WIDTH = 32                  // 计数器位宽
) (
    output reg pressed = 1'b0,       // 按下事件脉冲(一个时钟周期)
    output reg released = 1'b0,      // 松开事件脉冲(一个时钟周期)
    output reg long_pressed = 1'b0,  // 长按事件脉冲(一个时钟周期)
    input clk,                       // 系统时钟
    input n_pressing                 // 低电平有效的原始按键输入
);

  localparam integer DebounceCycles = (CLK_FREQ / 1000) * DEBOUNCE_MS;
  localparam integer LongPressCycles = (CLK_FREQ / 1000) * LONG_PRESS_MS;

  reg [WIDTH-1:0] debounce_count = {WIDTH{1'b0}};
  reg [WIDTH-1:0] hold_count = {WIDTH{1'b0}};
  reg stable_pressed = 1'b0;
  reg long_press_sent = 1'b0;
  reg sync_1 = 1'b1;
  reg sync_2 = 1'b1;

  always @(posedge clk) begin
    sync_1 <= n_pressing;
    sync_2 <= sync_1;
    pressed <= 1'b0;
    released <= 1'b0;
    long_pressed <= 1'b0;

    if ((!sync_2) == stable_pressed) begin
      debounce_count <= {WIDTH{1'b0}};
    end else if (debounce_count >= DebounceCycles - 1) begin
      debounce_count <= {WIDTH{1'b0}};
      stable_pressed <= !sync_2;
      if (!sync_2) begin
        pressed <= 1'b1;
        hold_count <= {WIDTH{1'b0}};
        long_press_sent <= 1'b0;
      end else begin
        released <= 1'b1;
        hold_count <= {WIDTH{1'b0}};
        long_press_sent <= 1'b0;
      end
    end else begin
      debounce_count <= debounce_count + 1'b1;
    end

    if (stable_pressed && !long_press_sent) begin
      if (hold_count >= LongPressCycles - 1) begin
        long_pressed <= 1'b1;
        long_press_sent <= 1'b1;
      end else begin
        hold_count <= hold_count + 1'b1;
      end
    end
  end

endmodule

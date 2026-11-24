// 按钮处理模块, 进行消抖, 长按检测等等.
// 采用响应式debounce语义. 当信号改变时重置计数, 未改变时计数. 计数达到阈值时触发信号.
module button #(
    parameter integer CLK_FREQ = 1000,  //时钟频率(Hz)
    parameter integer DEBOUNCE_TH = 50,  // 消抖阈值(count)
    parameter integer WIDTH = 16  // 位宽
) (
    output reg pressed,  // 按下信号脉冲
    output reg released, // 松手信号脉冲

    input clk,  // 时钟
    input n_pressing  // 低电平有效的原始输入
);
  assign pressing = !n_pressing;
  assign trig = consist_cnt >= DEBOUNCE_TH;  // 触发信号

  reg [WIDTH-1:0] consist_cnt = 0;  // 信号未改变时的计数
  reg last_pressing = 0;

  always @(posedge clk) begin
    if (last_pressing != pressing) consist_cnt <= 0;
    else if (!trig) consist_cnt <= consist_cnt + 1;

    pressed <= trig && pressing && !last_pressing;
    released <= trig && !pressing && last_pressing;

    last_pressing <= pressing;
  end

endmodule

// 定时器顶层模块: 连接按键、控制器、计时器和六位数码管显示.
module timer_top #(
    parameter integer CLK_FREQ = 50000000,           // 板载时钟频率(Hz)
    parameter integer BUTTON_DEBOUNCE_MS = 20,        // 按键消抖时间(ms)
    parameter integer BUTTON_LONG_PRESS_MS = 1000,    // 长按判定时间(ms)
    parameter integer DISPLAY_REFRESH_HZ = 1000       // 数码管每位刷新频率(Hz)
) (
    input clk,                  // 板载时钟
    input [3:0] buttons_n,      // BTN0~BTN3, 低电平有效
    output [6:0] seg,           // 数码管段选输出
    output [5:0] an             // 六位数码管位选输出, 低电平有效
);

  wire tick_1hz;
  wire blink;
  wire confirm_pressed, cancel_pressed, cancel_released, cancel_long_pressed;
  wire add_pressed, sub_pressed;
  wire [3:0] state;
  wire down, put, clear, run;
  wire [2:0] preset_sel;
  wire [3:0] preset;
  wire [3:0] sec_l, sec_h, min_l, min_h, hour_l, hour_h;
  wire countdown_done;

  assign countdown_done = down &&
      (sec_l == 4'd0) && (sec_h == 4'd0) &&
      (min_l == 4'd0) && (min_h == 4'd0) &&
      (hour_l == 4'd0) && (hour_h == 4'd0);

  tick_generator #(.CLK_FREQ(CLK_FREQ)) CLOCKS(
      .clk(clk), .tick_1hz(tick_1hz), .blink(blink)
  );

  button #(
      .CLK_FREQ(CLK_FREQ), .DEBOUNCE_MS(BUTTON_DEBOUNCE_MS),
      .LONG_PRESS_MS(BUTTON_LONG_PRESS_MS)
  ) BTN_CONFIRM(
      .pressed(confirm_pressed), .released(), .long_pressed(),
      .clk(clk), .n_pressing(buttons_n[0])
  );

  button #(
      .CLK_FREQ(CLK_FREQ), .DEBOUNCE_MS(BUTTON_DEBOUNCE_MS),
      .LONG_PRESS_MS(BUTTON_LONG_PRESS_MS)
  ) BTN_CANCEL(
      .pressed(cancel_pressed), .released(cancel_released),
      .long_pressed(cancel_long_pressed), .clk(clk), .n_pressing(buttons_n[1])
  );

  button #(
      .CLK_FREQ(CLK_FREQ), .DEBOUNCE_MS(BUTTON_DEBOUNCE_MS),
      .LONG_PRESS_MS(BUTTON_LONG_PRESS_MS)
  ) BTN_ADD(
      .pressed(add_pressed), .released(), .long_pressed(),
      .clk(clk), .n_pressing(buttons_n[2])
  );

  button #(
      .CLK_FREQ(CLK_FREQ), .DEBOUNCE_MS(BUTTON_DEBOUNCE_MS),
      .LONG_PRESS_MS(BUTTON_LONG_PRESS_MS)
  ) BTN_SUB(
      .pressed(sub_pressed), .released(), .long_pressed(),
      .clk(clk), .n_pressing(buttons_n[3])
  );

  controller CONTROL(
      .state(state), .down(down), .preset_sel(preset_sel), .preset(preset),
      .put(put), .clear(clear), .run(run), .clk(clk), .tick_1hz(tick_1hz),
      .confirm_pressed(confirm_pressed), .cancel_pressed(cancel_pressed),
      .cancel_long_pressed(cancel_long_pressed), .add_pressed(add_pressed),
      .sub_pressed(sub_pressed), .countdown_done(countdown_done),
      .sec_l(sec_l), .sec_h(sec_h), .min_l(min_l), .min_h(min_h),
      .hour_l(hour_l), .hour_h(hour_h)
  );

  full_timer TIMER(
      .sec_l(sec_l), .sec_h(sec_h), .min_l(min_l), .min_h(min_h),
      .hour_l(hour_l), .hour_h(hour_h), .clk(clk), .cin(run), .down(down),
      .rst(clear), .put(put), .preset_sel(preset_sel), .preset(preset)
  );

  timer_display #(
      .CLK_FREQ(CLK_FREQ), .REFRESH_HZ(DISPLAY_REFRESH_HZ)
  ) DISPLAY(
      .clk(clk), .state(state), .blink(blink), .sec_l(sec_l), .sec_h(sec_h),
      .min_l(min_l), .min_h(min_h), .hour_l(hour_l), .hour_h(hour_h),
      .seg(seg), .an(an)
  );

endmodule

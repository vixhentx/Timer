// 用户交互控制器. 处理按键事件、用户界面状态和计时器控制信号.
module controller (
    output reg [3:0] state = 4'd0, // 当前状态: 0 初始, 1 设置, 2 计时中, 3 结束
    output reg down = 1'b0,         // 计时方向: 0 正计时, 1 倒计时
    output reg [2:0] preset_sel = 3'd0, // 预置位选择(0~5)
    output reg [3:0] preset = 4'd0, // 当前预置的数值
    output reg put = 1'b0,          // 计时器预置写入脉冲
    output reg clear = 1'b0,        // 计时器清零脉冲
    output run,                     // 计时器计数使能(1Hz 单周期脉冲)

    input clk,                      // 系统时钟
    input tick_1hz,                 // 1Hz 计时节拍
    input confirm_pressed,          // BTN0 按下
    input cancel_pressed,           // BTN1 按下/切换
    input cancel_long_pressed,      // BTN1 长按
    input add_pressed,              // BTN2 按下
    input sub_pressed,              // BTN3 按下
    input countdown_done,           // 倒计时归零
    input [3:0] sec_l,              // 秒低位
    input [3:0] sec_h,              // 秒高位
    input [3:0] min_l,              // 分低位
    input [3:0] min_h,              // 分高位
    input [3:0] hour_l,             // 小时低位
    input [3:0] hour_h              // 小时高位
);

  localparam logic [3:0] INITIAL = 4'd0;
  localparam logic [3:0] TIMESETTING = 4'd1;
  localparam logic [3:0] COUNTING = 4'd2;
  localparam logic [3:0] DONE = 4'd3;

  reg [3:0] selected_value;
  reg [3:0] selected_max;
  reg any_button_pressed;

  assign run = (state == COUNTING) && tick_1hz;

  always_comb begin
    case (preset_sel)
      3'd0: begin selected_value = sec_l; selected_max = 4'd9; end
      3'd1: begin selected_value = sec_h; selected_max = 4'd5; end
      3'd2: begin selected_value = min_l; selected_max = 4'd9; end
      3'd3: begin selected_value = min_h; selected_max = 4'd5; end
      3'd4: begin selected_value = hour_l; selected_max = 4'd9; end
      default: begin selected_value = hour_h; selected_max = 4'd9; end
    endcase
  end

  always_comb begin
    any_button_pressed = confirm_pressed || cancel_pressed || add_pressed || sub_pressed;
  end

  always @(posedge clk) begin
    put <= 1'b0;
    clear <= 1'b0;

    case (state)
      INITIAL: begin
        if (confirm_pressed) begin
          down <= 1'b0;
          state <= COUNTING;
        end else if (cancel_pressed) begin
          down <= 1'b1;
          preset_sel <= 3'd0;
          state <= TIMESETTING;
        end
      end

      TIMESETTING: begin
        if (confirm_pressed) begin
          state <= COUNTING;
        end else if (cancel_pressed) begin
          preset_sel <= (preset_sel == 3'd5) ? 3'd0 : preset_sel + 1'b1;
        end else if (add_pressed || sub_pressed) begin
          if (add_pressed)
            preset <= (selected_value >= selected_max) ? 4'd0 : selected_value + 1'b1;
          else
            preset <= (selected_value == 4'd0) ? selected_max : selected_value - 1'b1;
          put <= 1'b1;
        end
      end

      COUNTING: begin
        if (cancel_long_pressed) begin
          state <= INITIAL;
          clear <= 1'b1;
        end else if (down && countdown_done) begin
          state <= DONE;
        end
      end

      DONE: begin
        if (any_button_pressed) begin
          state <= INITIAL;
          clear <= 1'b1;
          down <= 1'b0;
        end
      end

      default: begin
        state <= INITIAL;
        clear <= 1'b1;
      end
    endcase
  end

endmodule

`timescale 1ns/1ps

module tb_controller;
  localparam logic [3:0] INITIAL = 4'd0;
  localparam logic [3:0] TIMESETTING = 4'd1;
  localparam logic [3:0] COUNTING = 4'd2;
  localparam logic [3:0] DONE = 4'd3;

  reg clk = 1'b0;
  reg tick_1hz = 1'b0;
  reg confirm_pressed = 1'b0;
  reg cancel_pressed = 1'b0;
  reg cancel_long_pressed = 1'b0;
  reg add_pressed = 1'b0;
  reg sub_pressed = 1'b0;
  reg countdown_done = 1'b0;
  reg [3:0] sec_l = 4'd0;
  reg [3:0] sec_h = 4'd0;
  reg [3:0] min_l = 4'd0;
  reg [3:0] min_h = 4'd0;
  reg [3:0] hour_l = 4'd0;
  reg [3:0] hour_h = 4'd0;
  wire [3:0] state;
  wire down;
  wire [2:0] preset_sel;
  wire [3:0] preset;
  wire put;
  wire clear;
  wire run;

  controller dut (
      .state(state), .down(down), .preset_sel(preset_sel), .preset(preset),
      .put(put), .clear(clear), .run(run), .clk(clk), .tick_1hz(tick_1hz),
      .confirm_pressed(confirm_pressed), .cancel_pressed(cancel_pressed),
      .cancel_long_pressed(cancel_long_pressed), .add_pressed(add_pressed),
      .sub_pressed(sub_pressed), .countdown_done(countdown_done),
      .sec_l(sec_l), .sec_h(sec_h), .min_l(min_l), .min_h(min_h),
      .hour_l(hour_l), .hour_h(hour_h)
  );

  always #5 clk = ~clk;

  task automatic cycle;
    begin
      @(posedge clk);
      #1;
    end
  endtask

  task automatic check_state(input logic [3:0] expected, input string label_text);
    begin
      if (state !== expected) begin
        $display("FAIL (%0s): expected state %0d, got %0d", label_text, expected, state);
        $fatal(1);
      end
    end
  endtask

  initial begin
    check_state(INITIAL, "initial state");
    if (run !== 1'b0 || down !== 1'b0) begin
      $display("FAIL (initial controls): run=%b down=%b", run, down);
      $fatal(1);
    end

    // BTN0 starts count-up; run is gated by both COUNTING and the 1 Hz tick.
    @(negedge clk); confirm_pressed = 1'b1;
    cycle;
    confirm_pressed = 1'b0;
    check_state(COUNTING, "start count-up");
    if (run !== 1'b0) begin $display("FAIL (run without tick)"); $fatal(1); end
    tick_1hz = 1'b1;
    #1;
    if (run !== 1'b1) begin $display("FAIL (run with tick)"); $fatal(1); end
    tick_1hz = 1'b0;
    #1;
    if (run !== 1'b0) begin $display("FAIL (run tick gate)"); $fatal(1); end

    // 长按取消正计时并产生单周期清零脉冲.
    @(negedge clk); cancel_long_pressed = 1'b1;
    cycle;
    cancel_long_pressed = 1'b0;
    check_state(INITIAL, "long-press cancel");
    if (clear !== 1'b1) begin $display("FAIL (cancel clear pulse)"); $fatal(1); end
    cycle;
    if (clear !== 1'b0) begin $display("FAIL (clear pulse width)"); $fatal(1); end

    // BTN1 进入倒计时设置; 按 BTN1 轮换六个字段并回到字段 0.
    @(negedge clk); cancel_pressed = 1'b1;
    cycle;
    cancel_pressed = 1'b0;
    check_state(TIMESETTING, "enter time setting");
    if (down !== 1'b1 || preset_sel !== 3'd0) begin
      $display("FAIL (enter setting controls)"); $fatal(1);
    end
    repeat (6) begin
      @(negedge clk); cancel_pressed = 1'b1;
      cycle;
      cancel_pressed = 1'b0;
      @(negedge clk); cycle;
    end
    if (preset_sel !== 3'd0) begin
      $display("FAIL (preset select wrap): got %0d", preset_sel);
      $fatal(1);
    end

    // 秒低位加法在 9 后回绕到 0, 减法在 0 前回绕到 9.
    sec_l = 4'd9;
    @(negedge clk); add_pressed = 1'b1;
    cycle;
    add_pressed = 1'b0;
    if (put !== 1'b1 || preset !== 4'd0) begin
      $display("FAIL (digit increment wrap): put=%b preset=%0d", put, preset);
      $fatal(1);
    end
    cycle;
    if (put !== 1'b0) begin $display("FAIL (put pulse width)"); $fatal(1); end

    sec_l = 4'd0;
    @(negedge clk); sub_pressed = 1'b1;
    cycle;
    sub_pressed = 1'b0;
    if (put !== 1'b1 || preset !== 4'd9) begin
      $display("FAIL (digit decrement wrap): put=%b preset=%0d", put, preset);
      $fatal(1);
    end
    cycle;

    // BTN0 开始倒计时; 归零信号进入 DONE, 任意按键返回 INITIAL 并清零.
    @(negedge clk); confirm_pressed = 1'b1;
    cycle;
    confirm_pressed = 1'b0;
    check_state(COUNTING, "start countdown");
    if (down !== 1'b1) begin $display("FAIL (countdown direction)"); $fatal(1); end
    countdown_done = 1'b1;
    cycle;
    countdown_done = 1'b0;
    check_state(DONE, "countdown done");
    @(negedge clk); sub_pressed = 1'b1;
    cycle;
    sub_pressed = 1'b0;
    check_state(INITIAL, "leave done");
    if (clear !== 1'b1 || down !== 1'b0) begin
      $display("FAIL (done exit controls): clear=%b down=%b", clear, down);
      $fatal(1);
    end

    $display("PASS: controller unit tests passed");
    $finish;
  end
endmodule

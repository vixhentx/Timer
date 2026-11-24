`timescale 1ns/1ps

module tb_button;
  reg clk = 1'b0;
  reg n_pressing = 1'b1;
  wire pressed;
  wire released;
  wire long_pressed;
  integer press_pulses = 0;
  integer release_pulses = 0;
  integer long_pulses = 0;

  button #(
      .CLK_FREQ(1000),
      .DEBOUNCE_MS(3),
      .LONG_PRESS_MS(12),
      .WIDTH(8)
  ) dut (
      .pressed(pressed), .released(released), .long_pressed(long_pressed),
      .clk(clk), .n_pressing(n_pressing)
  );

  always #5 clk = ~clk;

  always @(posedge clk) begin
    #1;
    if (pressed) press_pulses = press_pulses + 1;
    if (released) release_pulses = release_pulses + 1;
    if (long_pressed) long_pulses = long_pulses + 1;
  end

  task automatic wait_cycles(input integer cycles);
    integer i;
    begin
      for (i = 0; i < cycles; i = i + 1)
        @(posedge clk);
      #2;
    end
  endtask

  initial begin
    // 短于消抖时间的毛刺不得产生任何事件.
    @(negedge clk);
    n_pressing = 1'b0;
    wait_cycles(2);
    @(negedge clk);
    n_pressing = 1'b1;
    wait_cycles(8);
    if (press_pulses != 0 || release_pulses != 0 || long_pulses != 0) begin
      $display("FAIL (bounce rejection): unexpected button event");
      $fatal(1);
    end

    // 稳定按下只产生一个 pressed 脉冲, 长按阈值只触发一次.
    @(negedge clk);
    n_pressing = 1'b0;
    wait_cycles(8);
    if (press_pulses != 1 || release_pulses != 0) begin
      $display("FAIL (debounced press): press=%0d release=%0d", press_pulses, release_pulses);
      $fatal(1);
    end
    wait_cycles(20);
    if (long_pulses != 1) begin
      $display("FAIL (long press one-shot): expected 1, got %0d", long_pulses);
      $fatal(1);
    end

    // 松开产生一个 released 脉冲, 持续松开不得重复触发.
    @(negedge clk);
    n_pressing = 1'b1;
    wait_cycles(8);
    if (release_pulses != 1 || press_pulses != 1) begin
      $display("FAIL (debounced release): press=%0d release=%0d", press_pulses, release_pulses);
      $fatal(1);
    end
    wait_cycles(8);
    if (release_pulses != 1 || long_pulses != 1) begin
      $display("FAIL (idle stability): release=%0d long=%0d", release_pulses, long_pulses);
      $fatal(1);
    end

    $display("PASS: button unit tests passed");
    $finish;
  end
endmodule

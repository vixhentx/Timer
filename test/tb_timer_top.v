`timescale 1ns/1ps

// 顶层集成测试: 子模块行为由各自的单元 testbench 覆盖, 此处验证模块连接.
module tb_timer_top;
  localparam logic [3:0] INITIAL = 4'd0;
  localparam logic [3:0] COUNTING = 4'd2;

  reg clk = 1'b0;
  reg [3:0] buttons_n = 4'b1111;
  wire [6:0] seg0, seg1, seg2, seg3, seg4, seg5;

  timer_top #(
      .CLK_FREQ(1000),
      .BUTTON_DEBOUNCE_MS(2),
      .BUTTON_LONG_PRESS_MS(10),
      .DISPLAY_REFRESH_HZ(100)
  ) dut (
      .clk(clk), .buttons_n(buttons_n), .seg0(seg0), .seg1(seg1), .seg2(seg2),
      .seg3(seg3), .seg4(seg4), .seg5(seg5)
  );

  always #5 clk = ~clk;

  task automatic wait_cycles(input integer cycles);
    integer i;
    begin
      for (i = 0; i < cycles; i = i + 1)
        @(posedge clk);
      #1;
    end
  endtask

  initial begin
    wait_cycles(4);
    if (dut.state !== INITIAL ||
        {seg5, seg4, seg3, seg2, seg1, seg0} !== {6{7'b0000010}}) begin
      $display("FAIL (top initialization/display connection)");
      $fatal(1);
    end

    // 验证按键输入、Controller 控制信号和计时器时钟使能已正确连接.
    @(negedge clk);
    buttons_n[0] = 1'b0;
    wait_cycles(6);
    @(negedge clk);
    buttons_n[0] = 1'b1;
    wait_cycles(6);
    if (dut.state !== COUNTING || dut.down !== 1'b0) begin
      $display("FAIL (top start-count-up connection): state=%0d down=%b", dut.state, dut.down);
      $fatal(1);
    end

    wait_cycles(1100);
    if ({dut.sec_h, dut.sec_l} !== 8'h01) begin
      $display("FAIL (top tick-to-timer connection): seconds=%0d%0d",
               dut.sec_h, dut.sec_l);
      $fatal(1);
    end

    // 长按取消控制信号应到达 Controller, 并让计时器清零.
    @(negedge clk);
    buttons_n[1] = 1'b0;
    wait_cycles(20);
    if (dut.state !== INITIAL) begin
      $display("FAIL (top cancel connection): expected initial state, got %0d", dut.state);
      $fatal(1);
    end
    @(negedge clk);
    buttons_n[1] = 1'b1;
    wait_cycles(6);
    if ({dut.hour_h, dut.hour_l, dut.min_h, dut.min_l, dut.sec_h, dut.sec_l} !== 24'd0) begin
      $display("FAIL (top clear-to-timer connection)");
      $fatal(1);
    end

    $display("PASS: timer_top integration test passed");
    $finish;
  end
endmodule

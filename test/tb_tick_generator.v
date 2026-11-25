`timescale 1ns/1ps

module tb_tick_generator;
  reg clk = 1'b0;
  wire tick_1hz;
  wire blink;

  tick_generator #(
      .CLK_FREQ(1000),
      .BLINK_HALF_PERIOD(3)
  ) dut (
      .clk(clk), .tick_1hz(tick_1hz), .blink(blink)
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
    wait_cycles(2);
    if (blink !== 1'b0 || tick_1hz !== 1'b0) begin
      $display("FAIL: outputs changed before their periods elapsed");
      $fatal(1);
    end

    wait_cycles(1);
    if (blink !== 1'b1 || tick_1hz !== 1'b0) begin
      $display("FAIL: blink did not toggle after 3 cycles");
      $fatal(1);
    end

    wait_cycles(3);
    if (blink !== 1'b0 || tick_1hz !== 1'b0) begin
      $display("FAIL: blink did not toggle back after another 3 cycles");
      $fatal(1);
    end

    wait_cycles(994);
    if (tick_1hz !== 1'b1 || blink !== 1'b1) begin
      $display("FAIL: expected 1Hz pulse and third blink toggle at cycle 1000");
      $fatal(1);
    end

    @(posedge clk);
    #1;
    if (tick_1hz !== 1'b0) begin
      $display("FAIL: tick_1hz was not a one-cycle pulse");
      $fatal(1);
    end

    $display("PASS: tick_generator timing test passed");
    $finish;
  end
endmodule

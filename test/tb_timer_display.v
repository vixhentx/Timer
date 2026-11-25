`timescale 1ns/1ps

module tb_timer_display;
  localparam logic [3:0] INITIAL = 4'd0;
  localparam logic [3:0] COUNTING = 4'd2;
  localparam logic [3:0] DONE = 4'd3;

  reg clk = 1'b0;
  reg [3:0] state = INITIAL;
  reg blink = 1'b0;
  reg [3:0] sec_l = 4'd1;
  reg [3:0] sec_h = 4'd2;
  reg [3:0] min_l = 4'd3;
  reg [3:0] min_h = 4'd4;
  reg [3:0] hour_l = 4'd5;
  reg [3:0] hour_h = 4'd6;
  wire [6:0] seg0, seg1, seg2, seg3, seg4, seg5;

  timer_display #(.CLK_FREQ(600), .REFRESH_HZ(100)) dut (
      .clk(clk), .state(state), .blink(blink),
      .sec_l(sec_l), .sec_h(sec_h), .min_l(min_l), .min_h(min_h),
      .hour_l(hour_l), .hour_h(hour_h), .seg0(seg0), .seg1(seg1), .seg2(seg2),
      .seg3(seg3), .seg4(seg4), .seg5(seg5)
  );

  always #5 clk = ~clk;

  function automatic [6:0] decode(input logic [3:0] value);
    case (value)
      4'd1: decode = 7'b0110000;
      4'd2: decode = 7'b1101101;
      4'd3: decode = 7'b1111001;
      4'd4: decode = 7'b0110011;
      4'd5: decode = 7'b1011011;
      4'd6: decode = 7'b1011111;
      default: decode = 7'bxxxxxxx;
    endcase
  endfunction

  initial begin
    #1;
    if ({seg5, seg4, seg3, seg2, seg1, seg0} !== {6{7'b0000010}}) begin
      $display("FAIL (initial state should show dashes on all six digits)");
      $fatal(1);
    end

    // DONE 且 blink=1 显示横线; blink=0 显示时间.
    state = DONE;
    blink = 1'b1;
    #1;
    if ({seg5, seg4, seg3, seg2, seg1, seg0} !== {6{7'b0000010}}) begin
      $display("FAIL (done blink should show dashes on all six digits)");
      $fatal(1);
    end

    blink = 1'b0;
    state = COUNTING;
    #1;
    if ({seg5, seg4, seg3, seg2, seg1, seg0} !==
        {decode(hour_h), decode(hour_l), decode(min_h), decode(min_l), decode(sec_h), decode(sec_l)}) begin
      $display("FAIL (parallel digit decoding): actual=%b expected=%b",
               {seg5, seg4, seg3, seg2, seg1, seg0},
               {decode(hour_h), decode(hour_l), decode(min_h), decode(min_l), decode(sec_h), decode(sec_l)});
      $fatal(1);
    end

    $display("PASS: timer_display unit tests passed");
    $finish;
  end
endmodule

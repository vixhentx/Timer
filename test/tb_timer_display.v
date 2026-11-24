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
  wire [6:0] seg;
  wire [5:0] an;
  integer i;

  timer_display #(.CLK_FREQ(600), .REFRESH_HZ(100)) dut (
      .clk(clk), .state(state), .blink(blink),
      .sec_l(sec_l), .sec_h(sec_h), .min_l(min_l), .min_h(min_h),
      .hour_l(hour_l), .hour_h(hour_h), .seg(seg), .an(an)
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

  task automatic check_digit(input integer index, input logic [6:0] expected_seg);
    logic [5:0] expected_an;
    begin
      expected_an = ~(6'b000001 << index);
      @(posedge clk);
      #1;
      if (an !== expected_an || seg !== expected_seg) begin
        $display("FAIL (display digit %0d): an=%b seg=%b expected an=%b seg=%b",
                 index, an, seg, expected_an, expected_seg);
        $fatal(1);
      end
    end
  endtask

  initial begin
    // 初始状态六位均显示横线, 位选仍按顺序扫描.
    for (i = 0; i < 6; i = i + 1)
      check_digit(i, 7'b0000010);

    // DONE 且 blink=1 显示横线; blink=0 显示时间.
    state = DONE;
    blink = 1'b1;
    for (i = 0; i < 6; i = i + 1)
      check_digit(i, 7'b0000010);

    blink = 1'b0;
    state = COUNTING;
    check_digit(0, decode(sec_l));
    check_digit(1, decode(sec_h));
    check_digit(2, decode(min_l));
    check_digit(3, decode(min_h));
    check_digit(4, decode(hour_l));
    check_digit(5, decode(hour_h));
    check_digit(0, decode(sec_l));

    $display("PASS: timer_display unit tests passed");
    $finish;
  end
endmodule

// 六位数码管并行显示. 段选高电平点亮.
module timer_display #(
    parameter integer CLK_FREQ = 50000000,       // 系统时钟频率(Hz)
    parameter integer REFRESH_HZ = 1000          // 每一位的刷新频率(Hz)
) (
    input clk,                    // 系统时钟
    input [3:0] state,            // Controller 当前状态
    input blink,                  // 闪烁控制信号
    input [3:0] sec_l,            // 秒低位
    input [3:0] sec_h,            // 秒高位
    input [3:0] min_l,            // 分低位
    input [3:0] min_h,            // 分高位
    input [3:0] hour_l,           // 小时低位
    input [3:0] hour_h,           // 小时高位
    output [6:0] seg0, // 秒低位
    output [6:0] seg1, // 秒高位
    output [6:0] seg2, // 分低位
    output [6:0] seg3, // 分高位
    output [6:0] seg4, // 小时低位
    output [6:0] seg5  // 小时高位
);

  localparam logic [3:0] INITIAL = 4'd0;
  localparam logic [3:0] DONE = 4'd3;

  wire dash_mode = (state == INITIAL) || ((state == DONE) && blink);
  wire [6:0] decoded_seg0, decoded_seg1, decoded_seg2;
  wire [6:0] decoded_seg3, decoded_seg4, decoded_seg5;

  segment SEGMENT0(.out(decoded_seg0), .in(sec_l));
  segment SEGMENT1(.out(decoded_seg1), .in(sec_h));
  segment SEGMENT2(.out(decoded_seg2), .in(min_l));
  segment SEGMENT3(.out(decoded_seg3), .in(min_h));
  segment SEGMENT4(.out(decoded_seg4), .in(hour_l));
  segment SEGMENT5(.out(decoded_seg5), .in(hour_h));

  assign seg0 = dash_mode ? 7'b0000010 : decoded_seg0;
  assign seg1 = dash_mode ? 7'b0000010 : decoded_seg1;
  assign seg2 = dash_mode ? 7'b0000010 : decoded_seg2;
  assign seg3 = dash_mode ? 7'b0000010 : decoded_seg3;
  assign seg4 = dash_mode ? 7'b0000010 : decoded_seg4;
  assign seg5 = dash_mode ? 7'b0000010 : decoded_seg5;

endmodule

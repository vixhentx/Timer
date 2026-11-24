// 六位数码管动态扫描显示. 段选高电平点亮, 位选低电平有效.
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
    output reg [6:0] seg = 7'b0000000, // 七段数码管段选
    output reg [5:0] an = 6'b111111    // 六位数码管位选(低有效)
);

  localparam integer RefreshDiv = CLK_FREQ / (REFRESH_HZ * 6);
  localparam logic [3:0] INITIAL = 4'd0;
  localparam logic [3:0] DONE = 4'd3;

  reg [31:0] refresh_count = 32'd0;
  reg [2:0] digit = 3'd0;
  reg [3:0] digit_value;
  reg dash_mode;
  wire [6:0] decoded_seg;

  segment SEGMENT_DECODER(.out(decoded_seg), .in(digit_value));

  always_comb begin
    case (digit)
      3'd0: digit_value = sec_l;
      3'd1: digit_value = sec_h;
      3'd2: digit_value = min_l;
      3'd3: digit_value = min_h;
      3'd4: digit_value = hour_l;
      default: digit_value = hour_h;
    endcase

    dash_mode = (state == INITIAL) || ((state == DONE) && blink);
  end

  always @(posedge clk) begin
    if (refresh_count >= RefreshDiv - 1) begin
      refresh_count <= 32'd0;
      digit <= (digit == 3'd5) ? 3'd0 : digit + 1'b1;
    end else begin
      refresh_count <= refresh_count + 1'b1;
    end

    an <= ~(6'b000001 << digit);
    if (dash_mode)
      seg <= 7'b0000010;
    else
      seg <= decoded_seg;
  end

endmodule

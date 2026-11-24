module full_timer(
    // 秒低位、高位
    sec_l, sec_h,
    // 分低位、高位
    min_l, min_h,
    // 时低位、高位
    hour_l, hour_h,

    clk, cin, rst,
    put,        // 统一置位脉冲
    preset_sel, // 选择要预置的位 (0~5)
    preset      // 预置值
);

output [3:0] sec_l, sec_h, min_l, min_h, hour_l, hour_h;
input        clk, cin, rst, put;
input [2:0]  preset_sel;
input [3:0]  preset;

wire sl_cout, sh_cout, ml_cout, mh_cout, hl_cout, hh_cout;

wire put_sl = put && (preset_sel == 3'd0);
wire put_sh = put && (preset_sel == 3'd1);
wire put_ml = put && (preset_sel == 3'd2);
wire put_mh = put && (preset_sel == 3'd3);
wire put_hl = put && (preset_sel == 3'd4);
wire put_hh = put && (preset_sel == 3'd5);

timer#(.MOD(10)) TIM_SL(
    .cnt(sec_l), .cout(sl_cout), .clk(clk),
    .cin(cin), .rst(rst), .put(put_sl), .preset(preset)
);

timer#(.MOD(6)) TIM_SH(
    .cnt(sec_h), .cout(sh_cout), .clk(clk),
    .cin(sl_cout), .rst(rst), .put(put_sh), .preset(preset)
);

timer#(.MOD(10)) TIM_ML(
    .cnt(min_l), .cout(ml_cout), .clk(clk),
    .cin(sh_cout), .rst(rst), .put(put_ml), .preset(preset)
);

timer#(.MOD(6)) TIM_MH(
    .cnt(min_h), .cout(mh_cout), .clk(clk),
    .cin(ml_cout), .rst(rst), .put(put_mh), .preset(preset)
);

timer#(.MOD(10)) TIM_HL(
    .cnt(hour_l), .cout(hl_cout), .clk(clk),
    .cin(mh_cout), .rst(rst), .put(put_hl), .preset(preset)
);

timer#(.MOD(10)) TIM_HH(
    .cnt(hour_h), .cout(hh_cout), .clk(clk),
    .cin(hl_cout), .rst(rst), .put(put_hh), .preset(preset)
);

endmodule

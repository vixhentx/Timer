// Single modulo counter digit. cout pulses when this digit wraps.
module bit_timer#(
    parameter integer MOD = 10
)(
    cnt, //  当前计数输出
    cout, // 进位输出

    clk, //同步时钟
    cin, // 计数使能
    down, // 1: count down, 0: count up
    rst, // 复位
    put, // 触发置位
    preset // 预置位
);

output reg [3:0] cnt = 0;
output cout;

input clk;
input rst;
input put;
input cin;
input down;
input[3:0] preset;

always @(posedge clk) begin
    if (rst)
        cnt <= 4'd0;
    else if (put) begin
        if (preset < MOD)
            cnt <= preset;
    end else if (cin) begin
        if (down)
            cnt <= (cnt == 0) ? MOD - 1 : cnt - 1'b1;
        else
            cnt <= (cnt == MOD - 1) ? 4'd0 : cnt + 1'b1;
    end
end

assign cout = cin && (down ? (cnt == 0) : (cnt == MOD - 1));

endmodule

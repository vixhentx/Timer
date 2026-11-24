// 0~10 计数器
module timer#(
	MOD = 10
)(
	cnt, //  计数器
	cout, // 进位输出
	clk, //同步时钟
	cin, // 计数信号输入
	rst,
	put, // 触发置位
	preset // 预置位
);

output reg [3:0] cnt = 0;
output cout;

input clk;
input rst;
input put;
input cin;
input[3:0] preset;

always @(posedge clk)
begin
	if(rst)
		cnt <= 0;
	else if(put)
		cnt <= preset;
	else if(cin)
		cnt <= (cnt + 1 >= MOD) ? 4'd0 : cnt + 1;
end

assign cout = cin && (cnt + 1 >= MOD);

endmodule

module devider#(
	HALF,
	WIDTH=32
)(
	out,
	in
);

output out;
input in;

reg[WIDTH-1: 0] cnt;
reg out;

initial
begin
	cnt = 0;
	out = 0;
end

always @(posedge in)
begin
	if(cnt + 1 > HALF)
	begin
		cnt <= 0;
		out <= ~out;
	end
	else cnt <= cnt + 1;
end

endmodule

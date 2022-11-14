module adder(
	input a,
	input b,
	input c_in,
	output sum,
	output c_out
	);
	
	assign sum = a ^ b ^ c_in;
	assign c_out = (a & b) | (a & c_in) | (b & c_in);
	
endmodule

module adder_param #(
	parameter Width = 10
)(
	input [Width-1:0] a,
	input [Width-1:0] b,
	input c_in,
	output [Width-1:0] sum,
	output c_out
	);
	
	wire [Width-2:0] temp_c_in;
	genvar i;
	
	generate
	for(i = 1; i < Width - 1; i = i + 1) begin : adder_generate
		adder adder_inst(
			.a(a[i]),
			.b(b[i]),
			.c_in(temp_c_in[i-1]),
			.sum(sum[i]),
			.c_out(temp_c_in[i])
		);
	end
	endgenerate
	
	adder adder_first(
		.a(a[0]),
		.b(b[0]),
		.c_in(c_in),
		.sum(sum[0]),
		.c_out(temp_c_in[0])
	);
	
	adder adder_last(
		.a(a[Width-1]),
		.b(b[Width-1]),
		.c_in(temp_c_in[Width-2]),
		.sum(sum[Width-1]),
		.c_out(c_out)
	);
	
endmodule
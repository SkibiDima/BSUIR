`include "rough_estimate.v"

`timescale 1ns/1ps

module rough_estimate_testbench;

	reg clk;
	
	wire in_sign;
	wire [7:0] in_exponent;
	wire [22:0] in_mantissa;
	
	wire out_sign;
	wire [7:0] out_exponent;
	wire [22:0] out_mantissa;
	wire incorrect;
	
	wire [31:0] out;
	reg [31:0] in;
	
	assign out = {out_sign, out_exponent, out_mantissa};
	assign in_sign = in[31];
	assign in_exponent = in[30:23];
	assign in_mantissa = in[22:00];
	
	rough_estimate dut(
		.clk(clk),
		.in_sign(in_sign),
		.in_exponent(in_exponent),
		.in_mantissa(in_mantissa),
		.out_sign(out_sign),
		.out_exponent(out_exponent),
		.out_mantissa(out_mantissa),
		.incorrect(incorrect)
	);

	always #5 clk = ~clk;
	
	integer i;
	initial begin
	
	$dumpfile("rough_estimate_testbench.vcd");
   $dumpvars;
	
	{clk, in} = 0;
	
	#10 
	
	in = 32'h0000_0000; // 0
	
	#10 
	
	in = 32'h7F80_0000; // inf
	
	#10
	
	in = 32'hFF80_0000; // -inf
	
	#10
	
	in = 32'h7FA6_ED6A; // NaN (random)
	
	#15
	
	in = 32'h4280_0000; // 64
	
	#10
	
	in = 32'h4745_C100; // 50625
	
	#10
	
	in = 32'h3D80_0000; // 0.0625 
	
	#10
	
	$stop;
	$finish;
	
	end
	
endmodule
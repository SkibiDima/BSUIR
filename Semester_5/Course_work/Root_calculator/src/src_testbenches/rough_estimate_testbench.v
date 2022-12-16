`include "rough_estimate.v"

`timescale 1ns/1ps

module rough_estimate_testbench;

	reg clk;
	
	wire incorrect;
	
	wire [31:0] out;
	reg [31:0] in;
	
	
	rough_estimate dut(
		.clk(clk),
		.in(in),
		.out(out),
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
	
	in = 32'h00800000; // 1.1754943e-38 minimum
	
	#10
	
	in = 32'h7F7FFFFF; // 3.4028234e+38 maximum
	
	#10
	
	$stop;
	$finish;
	
	end
	
endmodule
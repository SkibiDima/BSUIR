`include "recip_first_stage.v"

`timescale 1ns/1ps

module recip_first_stage_testbench;

	reg clk;
	reg [31:0] in;
	wire [23:0] out_D_mantissa;
	wire [23:0] out_x_mantissa;
	wire [7:0] out_exponent;
	
	recip_first_stage dut(
		.clk(clk),
		.in(in),
		.out_D_mantissa(out_D_mantissa),
		.out_x_mantissa(out_x_mantissa),
		.out_exponent(out_exponent)
	);

	always #5 clk = ~clk;
	
	initial begin
	
	$dumpfile("recip_first_stage_testbench.vcd");
   $dumpvars;
	
	{clk, in} = 0;
	
	#10 
	
	in = 32'h474B4000; // 52032
	
	#10 
	
	in = 32'h3E4B4000; // 0.19848633
	
	#10 
	
	in = 32'h31EC1F53; // 6.872065e-9
	
	#10
	
	in = 32'h41F80000; // 31
	
	#10 
	
	in = 32'h40800000; // 4
	
	#10 
	
	in = 32'h41051EB8; // 8.32
	
	#25 
	
	$stop;
	$finish;
	
	end
	
endmodule
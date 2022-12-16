`include "../src_logic/all_arithm.v"

`timescale 1ns/1ps

module all_arithm_testbench;

	reg clk;
	reg [31:0] in_s;
	wire [31:0] sqrt;
	
	all_arithm dut(
		.clk(clk),
		.in_s(in_s),
		.sqrt(sqrt)
	);

	always #5 clk = ~clk;
	
	initial begin
	
	$dumpfile("all_arithm_testbench.vcd");
   $dumpvars;
	
	{clk, in_s} = 0;
	
	#10 
	
	in_s = 32'h42800000; // 64
	
	#10 
	
	in_s = 32'h57F8A43C; // 546768529915904
	
	#10 
	
	in_s = 32'h2EC47772; // 8.934266e-11
	
	#60 
	
	$stop;
	$finish;
	
	end
	
endmodule
`include "rough_estimate.v"
`include "recip_first_stage.v"
`include "recip_second_stage.v"
`include "newthon_vavilon_s_x.v"

module all_arithm (
	input clk,
	input [31:0] in_s,
	output [31:0] sqrt
	);
	
	wire [31:0] real_sqrt;
	wire [31:0] rough_sqrt;
	wire incorrect;
	
	reg [31:0] in_s_shift [2:0];
	reg [31:0] rough_shift [1:0];
	
	wire [23:0] out_D_mantissa;
	wire [23:0] out_x_mantissa;
	wire [7:0] out_exponent;
	wire sign;
	wire [31:0] recip;
	
	rough_estimate sqrt_estimate(
		.clk(clk),
		.in(in_s),
		.out(rough_sqrt),
		.incorrect(incorrect)
	);
	
	recip_first_stage first_recip(
		.clk(clk),
		.in(rough_sqrt),
		.out_D_mantissa(out_D_mantissa),
		.out_x_mantissa(out_x_mantissa),
		.out_exponent(out_exponent),
		.sign(sign)
	);
	
	recip_second_stage second_recip(
		.clk(clk),
		.sign(sign),
		.in_D_mantissa(out_D_mantissa),
		.in_x_mantissa(out_x_mantissa),
		.in_exponent(out_exponent),
		.recip(recip)
	);

	newthon_vavilon_s_x vavilon(
		.clk(clk),
		.recip(recip),
		.in_s(in_s_shift[2][31:0]),
		.rough_x(rough_shift[1][31:0]),
		.sqrt(real_sqrt)
	);
	
	
	
	always @ (posedge clk) begin
		
		in_s_shift[0] <= in_s;
		in_s_shift[1] <= in_s_shift[0];
		in_s_shift[2] <= in_s_shift[1];
		
		rough_shift[0] <= rough_sqrt;
		rough_shift[1] <= rough_shift[0];
	end
	
	assign sqrt = real_sqrt;
	
	endmodule 
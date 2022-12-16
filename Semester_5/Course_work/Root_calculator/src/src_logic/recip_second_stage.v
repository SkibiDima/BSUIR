module recip_second_stage(
	input clk,
	input sign,
	input [23:0] in_x_mantissa,
	input [23:0] in_D_mantissa,
	input [7:0] in_exponent,
	output reg [31:0] recip
	);
	
	
	wire [47:0] mult_result_D;
	wire [47:0] mult_result_2;
	wire [23:0] sub_result_2;
	wire [22:0] out_mantissa_2;
	
	wire [23:0] r2; 
	assign r2 = 24'h800000;
	
	// SECOND STAGE X*(2-X*D)
	assign mult_result_D = in_x_mantissa * in_D_mantissa;
	
	assign sub_result_2 = r2 - (mult_result_D[47:24] >> 1);
	
	assign mult_result_2 = in_x_mantissa * sub_result_2;
	
	assign out_mantissa_2 = mult_result_2[44:22];
	// SECOND STAGE END
	
	always @ (posedge clk) begin
		
		recip <= {sign, in_exponent, out_mantissa_2}; 
		
	end
	
endmodule
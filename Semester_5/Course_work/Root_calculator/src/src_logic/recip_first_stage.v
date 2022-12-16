module recip_first_stage(
	input clk,
	input [31:0] in,
	output reg sign,
	output reg [23:0] out_D_mantissa,
	output reg [23:0] out_x_mantissa,
	output reg [7:0] out_exponent
	);
	
	wire [23:0] r3217;
	assign r3217 = 24'hF0F0F1;
	
	wire [23:0] r4817;
	assign r4817 = 24'hB4B4B5;
	
	
	wire [23:0] in_mantissa;
	assign in_mantissa = {1'b1, in[22:0]}; 
	 
	wire [7:0] exponent;
	wire [22:0] out_mantissa_1;
	wire [47:0] mult_result_3217;
	wire [23:0] sub_result_4817;
	
	assign exponent = (in[30:23] - 8'b01111110) ^ 8'b01111111;
	
	// FIRST STAGE 48/17 - 32/17*D
	assign mult_result_3217 = r3217 * in_mantissa;
	
	assign sub_result_4817 = r4817 - (mult_result_3217[47:24] >> 1); 
	
	assign out_mantissa_1 = sub_result_4817[22:0];
	
	// FIRST STAGE END
	
	always @ (posedge clk) begin
	
		out_exponent <= exponent;
		out_D_mantissa <= {1'b1, in[22:0]};
		out_x_mantissa <= {out_mantissa_1, 1'b1};
		sign <= in[31];
		
	end
	
	endmodule
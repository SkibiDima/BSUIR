module newthon_vavilon_s_x (
	input clk,
	input [31:0] recip,
	input [31:0] in_s,
	input [31:0] rough_x,
	output reg [31:0] sqrt
	);
	
	wire [47:0] mult_s_recip;
	wire [23:0] add_rough;	
	
	wire [23:0] in_s_mantissa;
	assign in_s_mantissa = {1'b1, in_s[22:0]}; 
	
	wire [23:0] rough_x_mantissa;
	assign rough_x_mantissa = {1'b1, rough_x[22:0]}; 
	
	wire [23:0] recip_mantissa;
	assign recip_mantissa = {1'b1, recip[22:0]}; 
	
	
	assign mult_s_recip = recip_mantissa * in_s_mantissa;
	
	assign add_rough = rough_x_mantissa + mult_s_recip[47:24];
	
	
	always @ (posedge clk) begin
	
		sqrt <= {rough_x[31], rough_x[30:23], add_rough[23:1]};
	
	end
	
	
	endmodule
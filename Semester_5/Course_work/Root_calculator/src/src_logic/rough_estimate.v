module rough_estimate(
	input clk,
	
	input in_sign,
	input [7:0] in_exponent,
	input [22:0] in_mantissa,
	
	output out_sign,
	output [7:0] out_exponent,
	output [22:0] out_mantissa,
	
	output reg incorrect
	);
	//15 14-10 9-0 
	
	reg sqrt_sign;
	reg[7:0] sqrt_exponent;
	reg[22:0] sqrt_mantissa;
	reg[22:0] trunc_mantissa;
	reg[7:0] trunc_exponent;
	
	always @(posedge clk) begin
		if(in_exponent == 8'hFF) begin // +-infinity | NaN 
			
			incorrect <= 1'b1;
			
			sqrt_sign <= in_sign;
			sqrt_exponent <= in_exponent;
			sqrt_mantissa <= in_mantissa;
			
		end
		else if(in_exponent == 8'h00) begin
			if(in_mantissa == 23'h0) begin // zero
				
				incorrect <= 1'b0;
				
				sqrt_sign <= 1'b0;
				sqrt_exponent <= 8'd0;
				sqrt_mantissa <= 23'd0;
				
			end
			else begin							 // denormalized
				
				incorrect <= 1'b1;
				
				sqrt_sign <= in_sign;
				sqrt_exponent <= in_exponent;
				sqrt_mantissa <= in_mantissa;
				
			end
		end
		else begin 								 // normal number
		if(in_exponent[0] == 1'b1) begin  // even exponent
		
			incorrect <= 1'b0;
			
			sqrt_sign <= in_sign;
			trunc_exponent = in_exponent[6:0] >> 1;
			sqrt_exponent <= {in_exponent[7], ~in_exponent[7], 
							  trunc_exponent[5:0]};
			sqrt_mantissa <= {in_mantissa[22:0] >> 1};
			
			end 
		else begin								 // uneven exponent
			
			incorrect <= 1'b0;
			
			sqrt_sign <= in_sign;
			if(in_exponent == 8'h80) begin // 10000000
				sqrt_exponent <= 8'h7F; // 01111111
			end
			else begin 
				trunc_exponent = in_exponent[6:0] >> 1;
				sqrt_exponent <= {in_exponent[7], ~in_exponent[7], 
								 {trunc_exponent[5:0] - 1'b1}};
			end
			trunc_mantissa[22:0] = in_mantissa[22:0] >> 1;
			sqrt_mantissa <= {1'b1, trunc_mantissa[21:0]};
			
		end
		end
	end
	
	assign out_sign = sqrt_sign;
	assign out_exponent = sqrt_exponent;
	assign out_mantissa = sqrt_mantissa;
	
endmodule

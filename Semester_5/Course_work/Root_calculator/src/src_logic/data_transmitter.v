module data_transmitter(
    input clk,
    input [31:0] in_data,
    input in_data_ready,
	 input data_request,
    output reg [7:0] out_data,
    output reg out_data_ready
);

    reg [1:0] byte_counter;
	 reg [31:0] in_data_reg;
	 
    initial begin
        byte_counter = 0;
		  out_data = 0;
		  out_data_ready = 0;
    end

    always @(posedge clk) begin
		  if(out_data_ready == 1'b1)
			out_data_ready <= 1'b0;
        if(data_request == 1'b1) begin
            case (byte_counter)
                2'b00: begin
                    out_data <= in_data_reg[31:24];
                    byte_counter = byte_counter + 1'b1;
                    out_data_ready <= 1'b1;
                end 
                2'b01: begin
                    out_data <= in_data_reg[23:16];
                    byte_counter = byte_counter + 1'b1;
						  out_data_ready <= 1'b1;
                end 
                2'b10: begin
                    out_data <= in_data_reg[15:8];
                    byte_counter = byte_counter + 1'b1;
						  out_data_ready <= 1'b1;
                end 
                2'b11: begin
                    out_data <= in_data_reg[7:0];
                    byte_counter = byte_counter + 1'b1;
                    out_data_ready <= 1'b1;
                end
            endcase
        end
		  if(in_data_ready == 1'b1) begin
			  in_data_reg <= in_data;
		  end
    end
	 
endmodule
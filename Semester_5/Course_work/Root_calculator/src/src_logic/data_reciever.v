module data_reciever(
    input clk,
    input [7:0] in_data,
    input in_data_ready,
    output reg [31:0] out_data,
    output reg out_data_ready
);

    reg [1:0] byte_counter;

    initial begin
        byte_counter = 0;
		  out_data = 0;
		  out_data_ready = 0;
    end

    always @(posedge clk) begin
		  if(out_data_ready == 1'b1)
				out_data_ready <= 1'b0;
        if(in_data_ready == 1'b1) begin
            case (byte_counter)
                2'b00: begin
                    out_data[31:24] <= in_data;
                    byte_counter = byte_counter + 1'b1;
                    out_data_ready <= 1'b0;
                end 
                2'b01: begin
                    out_data[23:16] <= in_data;
                    byte_counter = byte_counter + 1'b1;
                end 
                2'b10: begin
                    out_data[15:8] <= in_data;
                    byte_counter = byte_counter + 1'b1;
                end 
                2'b11: begin
                    out_data[7:0] <= in_data;
                    byte_counter = byte_counter + 1'b1;
                    out_data_ready <= 1'b1;
                end
            endcase
        end
    end
	 
endmodule


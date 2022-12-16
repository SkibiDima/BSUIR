`include "../src_logic/RS232_reciever.v"
`include "../src_logic/RS232_transmitter.v"
`include "../src_logic/data_reciever.v"
`include "../src_logic/data_transmitter.v"
`include "../src_logic/all_arithm.v"

module root_main (
	input clk,
	input rx,
	output tx
	);
	
	wire [7:0] rs_reciever_data;
	wire  rs_reciever_error;
	wire  rs_reciever_data_ready;
	
	RS232_reciever rs_reciever (
		.clk(clk),
		.rx(rx),
		.data(rs_reciever_data),
		.error(rs_reciever_error),
		.data_ready(rs_reciever_data_ready)
	);
	
	wire [31:0] data_reciev_out;
	wire start_root_calculate;
	
	data_reciever data_reciev (
		.clk(clk),
		.in_data(rs_reciever_data),
		.in_data_ready(rs_reciever_data_ready),
      .out_data(data_reciev_out),
      .out_data_ready(start_root_calculate)
	);
	
	reg start_shift [3:0];
	always @ (posedge clk) begin
		start_shift[0] <= start_root_calculate;
		start_shift[1] <= start_shift[0];
		start_shift[2] <= start_shift[1];
		start_shift[3] <= start_shift[2];
	end
	
	wire [31:0] out_sqrt;
	
	all_arithm root_calculator(
		.clk(clk),
		.in_s(data_reciev_out),
		.sqrt(out_sqrt)
	);
	
	wire [7:0] data_transmit;
	wire rts;
	wire out_data_trans_ready;
	
	data_transmitter data_trans (
		.clk(clk),
		.in_data(out_sqrt),
		.in_data_ready(start_shift[3]),
		.data_request(rts),
		.out_data(data_transmit),
		.out_data_ready(out_data_trans_ready)
	);
	
	
	RS232_transmitter rs_transmitter(
		.clk(clk),
		.data(data_transmit),
		.data_ready(out_data_trans_ready),
		.tx(tx),
		.rts(rts)
	);
	
	endmodule 
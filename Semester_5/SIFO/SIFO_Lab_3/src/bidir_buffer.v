module bidir_buffer(
    input [2:0] data,
    input a_out,
	 inout reg [2:0] out
);

assign out = a_out ? data : 'hZ;

endmodule
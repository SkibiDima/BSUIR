module wire_hz 
#(
    parameter DATA_WIDTH = 8
)
(
    input [DATA_WIDTH-1:0] in_data,
    input out_is_active,
    output tri [DATA_WIDTH-1:0] out_data
);
tri [DATA_WIDTH-1:0] temp_out;

assign temp_out = out_is_active ? in_data : 'bz;
assign out_data = temp_out;

endmodule
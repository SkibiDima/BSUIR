module slave #(
    parameter [1:0] Number = 2'd0
) (
    input [4:0] data,
    output [2:0] slave_data
);

    assign slave_data = (data[1:0] == Number) ? data[4:2] : 3'h0;

endmodule
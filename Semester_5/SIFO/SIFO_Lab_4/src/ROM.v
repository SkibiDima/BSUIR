module ROM #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input [ADDRESS_WIDTH-1:0] address,
    output [DATA_WIDTH-1:0] out_data
);

localparam DATA_DEPTH = 2 ** ADDRESS_WIDTH;

reg [DATA_WIDTH-1:0] memory [DATA_DEPTH-1:0];

integer i;

initial begin
    for (i = 0; i < DATA_DEPTH; i = i + 1) begin
        memory[i] = 1'b0;
    end
end

assign out_data = memory[address];

endmodule
module register_file #(
    ADDRESS_REGISTERS = 4
    DATA_WIDTH = 8
) 
(
    input clk,
    input [ADDRESS_REGISTERS-1:0] address,
    input [DATA_WIDTH-1:0] in_data,
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
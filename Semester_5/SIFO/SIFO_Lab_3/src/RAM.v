module RAM #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input [ADDRESS_WIDTH-1:0] address,
    input [DATA_WIDTH-1:0] in_data,
    output [DATA_WIDTH-1:0] out_data,
    input write_enable
);

localparam  DATA_DEPTH = 2 ** ADDRESS_WIDTH;

reg [DATA_WIDTH-1:0] memory [DATA_DEPTH-1:0];

integer i;
initial begin
    for(i = 0; i < DATA_DEPTH; i = i + 1) begin
        memory[i] = 3;
    end
    memory[21] = 10;
end

always @(posedge clk) begin
    if(write_enable)  
        memory[address] <= in_data;
end

assign out_data = memory[address];

endmodule
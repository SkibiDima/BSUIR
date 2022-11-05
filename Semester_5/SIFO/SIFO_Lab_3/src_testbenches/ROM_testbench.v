`include "../src/ROM.v"
`timescale 1ns/1ps
module ROM_testbench;

parameter ADDRESS_WIDTH = 5;
parameter DATA_WIDTH = 8;
localparam DATA_DEPTH = 2 ** ADDRESS_WIDTH;

reg clk;
reg [ADDRESS_WIDTH-1:0] address;
wire [DATA_WIDTH-1:0] out_data;

integer i;

ROM dut (
    .clk(clk),
    .address(address),
    .out_data(out_data)
);

always #5 clk = ~clk;

initial begin : main

    integer fd;
    fd = $fopen("ROM_contains.txt", "w");

    $dumpfile("ROM_testbench.vcd");
    $dumpvars;

    {clk, address} = 0;

    repeat (2) @(posedge clk);

    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        $fwrite(fd, "[%d]", dut.memory[i]);
        if((i+1) % 8 == 0) begin
            $fwrite(fd, "\n");
        end
    end
    $fclose(fd);

    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        repeat (1) @(posedge clk) begin
            address = i;
        end
    end

    #20
	$stop;
    $finish;
end

endmodule
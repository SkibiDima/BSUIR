`include "../src/RAM.v"
`timescale 1ns/1ps
module RAM_testbench;

parameter ADDRESS_WIDTH = 5;
parameter DATA_WIDTH = 8;
parameter DATA_DEPTH = 2 ** ADDRESS_WIDTH;

reg clk;
reg write_enable;
reg [ADDRESS_WIDTH-1:0] address;
reg [DATA_WIDTH-1:0] in_data;
wire [DATA_WIDTH-1:0] out_data;

integer i;

RAM #(.ADDRESS_WIDTH(ADDRESS_WIDTH)) dut (
    .clk(clk),
    .address(address),
    .in_data(in_data),
    .out_data(out_data),
    .write_enable(write_enable)
);

always #5 clk = ~clk;

initial begin : main

    integer fd;
    fd = $fopen("RAM_contains_que.txt", "w");

    $dumpfile("RAM_testbench.vcd");
    $dumpvars;

    {clk, write_enable, in_data, address, i} = 0;

    #20 write_enable = 1;

    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        repeat(1) @(posedge clk) begin
            address = address + 1;
            in_data = i * 3;
        end
    end

    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        $fwrite(fd, "[%d]", dut.memory[i]);
        if((i + 1) % 8 == 0) begin
            $fwrite(fd, "\n");
        end
    end
    $fclose(fd);
    
    i = 0;
    write_enable = 0;
    repeat (2) @(posedge clk);

    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        repeat (1) @(posedge clk) begin
            address = address + 1;
        end
    end

    #20
	$stop;
    $finish;
end

endmodule
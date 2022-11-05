`include "../src/buffer.v"
`timescale 1ns/1ps
module buffer_testbench;

parameter DATA_WIDTH = 8;
parameter BUFFER_LENGTH = 5;

reg clk;
reg [DATA_WIDTH-1:0] in_data;
wire [DATA_WIDTH-1:0] out_data;
reg do_shift;

integer i;

buffer #(.DATA_WIDTH(DATA_WIDTH), .BUFFER_LENGTH(BUFFER_LENGTH)) dut (
    .clk(clk),
    .in_data(in_data),
    .out_data(out_data),
    .do_shift(do_shift)
);

always #5 clk = ~clk;

initial begin : main
    
    integer fd;
    fd = $fopen("buffer_contains.txt", "w");

    $dumpfile("buffer_testbench.vcd");
    $dumpvars;

    {clk, do_shift} = 0;
    in_data = 'hz;

    repeat(2) @(posedge clk);
    do_shift = #5 1;

    for (i = 0; i < BUFFER_LENGTH; i = i + 1) begin
        repeat(1) @(posedge clk) begin
            in_data = i * 3;
        end
    end

    repeat(1) @(posedge clk);
    in_data = 'hz;
	do_shift = 0;

    for(i = 0; i < BUFFER_LENGTH; i = i + 1) begin
        $fwrite(fd, "[%d]", dut.shifter[i]);
        if((i + 1) % 8 == 0) begin
            $fwrite(fd, "\n");
        end
    end
    $fclose(fd);

    repeat(2) @(posedge clk);
    do_shift = 1;

    repeat(BUFFER_LENGTH) @(posedge clk);
    #20

    $finish;
end
    
endmodule
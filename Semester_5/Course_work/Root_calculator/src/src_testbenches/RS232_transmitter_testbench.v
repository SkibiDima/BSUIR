`include "../src_logic/RS232_transmitter.v"

`timescale 1ns/1ps
module RS232_transmitter_testbench;

reg clk;
reg data_ready;
reg [7:0] data;

wire rts;
wire tx;

RS232_transmitter dut (
    .clk(clk),
    .data_ready(data_ready),
    .data(data),
    .rts(rts),
    .tx(tx)
);

always #5 clk = ~clk;

initial begin
    {clk, data, data_ready} = 0;
end

initial begin

    
    $dumpfile("RS232_transmitter_testbench.vcd");
    $dumpvars;

    #200

    data = 8'b01101010;
    data_ready = 1'b1;

    #10

    data_ready = 1'b0;

	#1000000;
	 
    $stop;
    $finish;
end

endmodule
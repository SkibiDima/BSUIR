`include "../src_logic/RS232_reciever.v"

`timescale 1ns/1ps

module RS232_reciever_testbench;

    reg clk;
    reg rx;

    wire data_ready;
    wire error;
    wire [7:0] data;

    reg [7:0] in_data;

    integer i;

    RS232_reciever dut (
        .clk(clk),
        .rx(rx),
        .error(error),
        .data_ready(data_ready),
        .data(data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rx = 1;
        in_data = 8'b01101010;
        i = 0;
    end

    initial begin

        $dumpfile("RS232_reciever_testbench.vcd");
        $dumpvars;

        #200;

        rx = 0; // start bit

        #52080;  // data byte 01101010

        for(i = 0; i < 8; i = i + 1) begin
            rx = in_data[i];
            #52080;
        end 

        rx = 1; // stop bit

        #52080

        $stop;
        $finish;
    end

endmodule
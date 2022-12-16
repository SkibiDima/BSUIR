`include "../src_logic/data_reciever.v"

`timescale 1ns/1ps

module data_reciever_testbench;

    reg clk;
    reg [7:0] in_data;
    reg in_data_ready;
    wire [31:0] out_data;
    wire out_data_ready;

    data_reciever dut(
        .clk(clk),
        .in_data(in_data),
        .in_data_ready(in_data_ready),
        .out_data(out_data),
        .out_data_ready(out_data_ready)
    );

    initial begin
        {clk, in_data, in_data_ready} = 0;
    end

    always #5 clk = ~clk;

    initial begin
        
        $dumpfile("data_reciever_testbench.vcd");
        $dumpvars;

        #20 
        in_data = 8'd10;
        in_data_ready = 1;
        
        #10
        in_data_ready = 0;

        #20
        in_data = 8'd20;
        in_data_ready = 1;

        #10
        in_data_ready = 0;

        #20
        in_data = 8'd88;
        in_data_ready = 1;

        #10
        in_data_ready = 0;

        #20
        in_data = 8'd54;
        in_data_ready = 1;

        #10
        in_data_ready = 0;

        #20
        in_data = 8'd100;
        in_data_ready = 1;

        #20

        $stop;
        $finish;

    end

endmodule
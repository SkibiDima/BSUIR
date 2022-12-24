`include "../src_logic/slave.v"

`timescale 1ns/1ps

module slave_tb;

    reg [4:0] data;
    wire [2:0] slave_data;

    slave #(2) dut (
        .*
    );

    initial begin

        $dumpfile("slave_tb.vcd");
        $dumpvars;

        data = 5'b101_10;

        #30

        data = 5'b101_11;

        #30

        $stop;
        $finish;
    end 
    
endmodule
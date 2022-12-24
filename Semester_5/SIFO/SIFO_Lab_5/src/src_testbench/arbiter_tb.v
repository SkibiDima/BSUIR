`include "../src_logic/arbiter.v"

`timescale 1ns/1ps

module arbiter_tb;

    reg clk;
    reg [2:0] in_request;
    wire [2:0] grant;

    arbiter dut (
        .*
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("arbiter_tb.vcd");
        $dumpvars;

        clk = 0;
        in_request = 3'b100;

        #10

        in_request = 3'b010;

        #50
      

        $stop;
        $finish;
    end 
    
endmodule
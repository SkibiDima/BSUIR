`include "../src_logic/arbiter.v"
`include "../src_logic/slave.v"
`include "../src_logic/master.v"

`timescale 1ns/1ps

module all_blocks_tb;
    
    reg clk;

    all_blocks dut(
        .clk(clk)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("all_blocks_tb.vcd");
        $dumpvars;

        clk = 0;
        
        #200

        $stop;
        $finish;
    end 

endmodule
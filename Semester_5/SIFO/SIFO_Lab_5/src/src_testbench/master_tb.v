`include "../src_logic/master.v"

`timescale 1ns/1ps

module master_tb;

    reg clk;
    reg [2:0] grant;
    reg [1:0] in_request;

    wire [4:0] data;
    wire [1:0] out_request;

    always #5 clk = ~clk;

    localparam Number = 2;

    master #(Number) dut(
        .clk(clk),
        .grant(grant),
        .data(data),
        .in_request(in_request),
        .out_request(out_request)
    );

    integer i;
    initial begin
        
        $dumpfile("master_tb.vcd");
        $dumpvars;

        {clk, grant, in_request} = 0;

        for(i = 0; i < 3; i = i + 1) begin
            in_request = i;
            wait (dut.own_request == 1);
            repeat (1 + i) @(posedge clk);
            grant = Number;

            repeat (3) @(posedge clk);
            
            grant = 0;
        end

        $stop;
        $finish;
    end


endmodule


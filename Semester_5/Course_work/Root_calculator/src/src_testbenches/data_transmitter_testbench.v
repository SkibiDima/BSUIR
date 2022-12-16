`include "../src_logic/data_transmitter.v"

`timescale 1ns/1ps

module data_transmitter_testbench;

    reg clk;
    reg [31:0] in_data;
    reg in_data_ready;
	 reg data_request;
    wire [7:0] out_data;
    wire out_data_ready;

    data_transmitter dut(
        .clk(clk),
        .in_data(in_data),
		  .data_request(data_request),
        .in_data_ready(in_data_ready),
        .out_data(out_data),
        .out_data_ready(out_data_ready)
    );

    initial begin
        {clk, in_data, in_data_ready} = 0;
    end

    always #5 clk = ~clk;

    initial begin
        
        $dumpfile("data_transmitter_testbench.vcd");
        $dumpvars;

		  #15 
		  
		  in_data_ready = 1;
		  
        #5
        in_data = 32'd10208854;
       
        #15
		  
		  data_request = 1;
		  
		  #20
		  
		  data_request = 0;
		  
		  #35 
		  
		  data_request = 1;

		  #10
		  
		  data_request = 0;
		  
        #70

        $stop;
        $finish;

    end

endmodule
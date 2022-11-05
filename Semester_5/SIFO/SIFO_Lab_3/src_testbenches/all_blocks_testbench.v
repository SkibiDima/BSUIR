`include "../src/all_blocks.v"
`timescale 1ns/1ps
module all_blocks_testbench;

parameter ADDRESS_WIDTH = 5;
parameter DATA_WIDTH = 8;
parameter BUFFER_LENGTH = 5;
parameter DATA_DELAY = 3;

reg clk;
reg start;
reg [ADDRESS_WIDTH-1:0] address;
reg rom_nram;
wire [DATA_WIDTH-1:0] general_data_bus;

integer i;

all_blocks #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_DELAY(DATA_DELAY),
    .BUFFER_LENGTH(BUFFER_LENGTH)
) boje (
    .clk(clk),
    .address(address),
    .start(start),
    .out_data(general_data_bus),
    .rom_nram(rom_nram)
);

always #5 clk = ~clk;

integer fd_mem, fd_monitor;
initial begin : main

    
    fd_mem = $fopen("all_blocks_contains.txt", "w");
    fd_monitor = $fopen("all_blocks_monitor.txt", "w");
    $dumpfile("all_blocks_testbench.vcd");
    $dumpvars;

    $fwrite(fd_mem, "ROM initialization:\n");
    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        $fwrite(fd_mem, "[%d]", boje.ROM_1.memory[i]);
        if((i + 1) % 8 == 0) begin
            $fwrite(fd_mem, "\n");
        end
    end
    $fwrite(fd_mem, "RAM initialization:\n");
    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        $fwrite(fd_mem, "[%d]", boje.RAM_1.memory[i]);
        if((i + 1) % 8 == 0) begin
            $fwrite(fd_mem, "\n");
        end
    end

    {clk, start, address, rom_nram} = 0;

//ROM TO RAM START

    #33  
    start = 1;
    address = 0;
    rom_nram = 1;
    #5 start = 0;
	 
    #10 
    address = 16;
    
    #200  

    $fwrite(fd_mem, "\nRAM first time:\n");
    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        $fwrite(fd_mem, "[%d]", boje.RAM_1.memory[i]);
        if((i + 1) % 8 == 0) begin
            $fwrite(fd_mem, "\n");
        end
    end

//ROM TO RAM ENDS
//RAM TO RAM START

    #23  
    start = 1;
    address = 17;
    rom_nram = 0;
    #5 start = 0;
	 
    #10 
    address = 0;
    
    #200  

    $fwrite(fd_mem, "\nRAM first time:\n");
    for(i = 0; i < 2**ADDRESS_WIDTH; i = i + 1) begin
        $fwrite(fd_mem, "[%d]", boje.RAM_1.memory[i]);
        if((i + 1) % 8 == 0) begin
            $fwrite(fd_mem, "\n");
        end
    end

//RAM TO RAM ENDS

    $fclose(fd_mem);
    $fclose(fd_monitor);
    #20
    $stop;
    $finish;
end

always @(posedge clk) begin
    $fwrite(fd_monitor, "Time:%3d, addres_counter=%d, state=%d, rw_counter=%d, active=%b, do_shift=%d, buf=", 
    $time, boje.address_counter, boje.current_state, boje.read_write_counter, 
    boje.active_memory_decode, boje.do_shift);
    for(i = 0; i< BUFFER_LENGTH; i = i + 1) begin
        $fwrite(fd_monitor, "%d", boje.buffer_1.shifter[i]);
    end
    $fwrite(fd_monitor, "\n");
end

endmodule
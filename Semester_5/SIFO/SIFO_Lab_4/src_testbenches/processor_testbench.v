`include "../src/processor.v"
`timescale 1ns/1ps
module processor_testbench;

parameter ADDRESS_WIDTH = 4;
parameter DATA_WIDTH = 8;

reg clk;

integer i;

processor #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) boje (
    .clk(clk)
);

always #5 clk = ~clk;

integer fd_mem, fd_monitor;
initial begin : main

    
    fd_mem = $fopen("processor_contains.txt", "w");
    fd_monitor = $fopen("processor_monitor.txt", "w");
    $dumpfile("processor_testbench.vcd");
    $dumpvars;

    clk = 0;
    
    //mov M->R 00RR|RRAA||AAAA|AAAA      TODO  lw
    //js       0100|00AA||AAAA|AAAA      TODO  IP+DATA if sign bit 

    //mov ram[4] to reg[3]  0-1
    //js ip+5 sign yes      2-3
    //js ip+7 sign no       9-10
    //mov ram[2] to reg[2]  11-12

    boje.flags_reg = 8'b0000_0011;
    boje.proc_ram.memory[2] = 8'b00011110; // 30 
    boje.proc_ram.memory[4] = 8'b00000110; // 6 

    boje.proc_rom.memory[0] = 8'b00_0011_00; // mov ram[4] to reg[3]
    boje.proc_rom.memory[1] = 8'b00000100;

    boje.proc_rom.memory[2] = 8'b01_0000_00; // js ip+5
    boje.proc_rom.memory[3] = 8'b0000_0101; 
    
    

    boje.proc_rom.memory[9] = 8'b01_0000_00; // js ip+7
    boje.proc_rom.memory[10] = 8'b0000_0111;

    boje.proc_rom.memory[11] = 8'b00_0010_00; // mov ram[2] to reg[2]
    boje.proc_rom.memory[12] = 8'b00000010;

    #70 
    boje.flags_reg = 8'b0000_0000;

    #70

    $fclose(fd_mem);
    $fclose(fd_monitor);
    #20
    $stop;
    $finish;
end

endmodule
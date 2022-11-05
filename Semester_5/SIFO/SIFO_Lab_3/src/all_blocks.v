`include "../src/RAM.v"
`include "../src/ROM.v"
`include "../src/wire_hz.v"
`include "../src/buffer.v"

module all_blocks #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 8,
    parameter BUFFER_LENGTH = 5,
    parameter DATA_DELAY = 3
)(
    input clk,
    input start,
    input rom_nram,
    input [ADDRESS_WIDTH-1:0] address,
	output tri [DATA_WIDTH-1:0] out_data
);
tri [DATA_WIDTH-1:0] general_data_bus;
tri [DATA_WIDTH-1:0] out_ram, out_rom, out_buffer, in_ram, in_buffer;

reg do_shift;
reg [3:0] active_memory_wire;
reg [1:0] active_memory_decode; //00 - none, 01 - rom, 10 - buf, 11 - ram
reg [ADDRESS_WIDTH-1:0] address_counter;
reg [2:0] read_write_counter; 
reg [1:0] delay_counter;

localparam [2:0] start_st = 0, read_st = 1, delay_st = 2, write_st = 3, calm_st = 4;
reg [2:0] current_state;//, next_state;

initial begin
    {active_memory_decode, address_counter,
    read_write_counter, delay_counter, do_shift} = 'bx;
    current_state = calm_st;
end

buffer #(
    .BUFFER_LENGTH(BUFFER_LENGTH), 
    .DATA_WIDTH(DATA_WIDTH)
) buffer_1(
    .clk(clk),
    //.in_data(general_data_bus),
    //.out_data(general_data_bus),
    .in_data(in_buffer),
	.out_data(out_buffer),
    .do_shift(do_shift)
);

RAM #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) RAM_1(
    .clk(clk),
    .address(address_counter),
    //.in_data(general_data_bus),
    //.out_data(general_data_bus),
	.in_data(in_ram),
    .out_data(out_ram),
    .write_enable(active_memory_wire[2])
);

ROM #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) ROM_1(
    .clk(clk),
    .address(address_counter),
    //.out_data(general_data_bus)
	.out_data(out_rom)
);

wire_hz #(
    .DATA_WIDTH(DATA_WIDTH)
) wire_hz_out_buffer(
    .in_data(out_buffer),
    .out_data(general_data_bus),
    .out_is_active(active_memory_wire[2])
);

wire_hz #(
    .DATA_WIDTH(DATA_WIDTH)
) wire_hz_out_ram(
    .in_data(out_ram),
    .out_data(general_data_bus),
    .out_is_active(active_memory_wire[3])
);

wire_hz #(
    .DATA_WIDTH(DATA_WIDTH)
) wire_hz_out_rom(
    .in_data(out_rom),
    .out_data(general_data_bus),
    .out_is_active(active_memory_wire[1])
);

wire_hz #(
    .DATA_WIDTH(DATA_WIDTH)
) wire_hz_in_buffer(
    .in_data(general_data_bus),
    .out_data(in_buffer),
    .out_is_active(active_memory_wire[1] | active_memory_wire[3]) // buf input is active when rom/ram out is active
);

wire_hz #(
    .DATA_WIDTH(DATA_WIDTH)
) wire_hz_in_ram(
    .in_data(general_data_bus),
    .out_data(in_ram),
    .out_is_active(active_memory_wire[2]) // ram input is active when buf out is active
);

assign out_data = general_data_bus;

always @(*) begin
    case(active_memory_decode)
        2'b00: active_memory_wire = 4'b0001; // none
        2'b01: active_memory_wire = 4'b0010; // rom
        2'b10: active_memory_wire = 4'b0100; // buf
        2'b11: active_memory_wire = 4'b1000; // ram
    endcase
end

always @(posedge clk) begin

    case(current_state) 
    start_st: begin
        address_counter <= address;
        if(rom_nram)
            active_memory_decode <= 2'b01; // rom out is active
        else active_memory_decode <= 2'b11; // ram out it active
        do_shift <= 1;
        read_write_counter <= 0;
        delay_counter <= 0;
        current_state <= read_st;
    end
    read_st: begin
        do_shift <= 1;
        address_counter <= address_counter + 1'b1;
        read_write_counter <= read_write_counter + 1'b1;
        if(read_write_counter == BUFFER_LENGTH - 1) begin
            active_memory_decode <= 2'b00;
            do_shift <= 0;
            current_state <= delay_st;
            read_write_counter <= 0;
        end
    end
    delay_st: begin
        do_shift <= 0;
        delay_counter <= delay_counter + 1'b1;
        address_counter <= address;
        if(delay_counter == DATA_DELAY - 1) begin
            do_shift <= 1;
            current_state <= write_st;
            active_memory_decode <= 2'b10;
        end
    end
    write_st: begin
        do_shift <= 1;
        address_counter <= address_counter + 1'b1;
        read_write_counter <= read_write_counter + 1'b1;
        if(read_write_counter == BUFFER_LENGTH - 1) begin
            do_shift <= 0;
            current_state <= calm_st;
            active_memory_decode <= 2'b00;
        end
    end
    calm_st: begin
        if(start) current_state <= start_st;
        else current_state <= calm_st;
    end
    endcase
end

// always @(posedge clk) begin
//     current_state <= next_state;

//     case(current_state) 
//     start_st: begin
//         address_counter <= address;
//         if(rom_nram)
//             active_memory_decode <= 2'b01; // rom out is active
//         else active_memory_decode <= 2'b11; // ram out it active
//         do_shift <= 0;
//         read_write_counter <= 0;
//         delay_counter <= 0;
//         next_state <= read_st;
//     end
//     read_st: begin
//         do_shift <= 1;
//         address_counter <= address_counter + 1'b1;
//         read_write_counter <= read_write_counter + 1'b1;
//         if(read_write_counter == BUFFER_LENGTH) begin
//             do_shift <= 0;
//             next_state <= delay_st;
//             read_write_counter <= 0;
//             active_memory_decode <= 2'b10;
//         end
//     end
//     delay_st: begin
//         do_shift <= 0;
//         delay_counter <= delay_counter + 1'b1;
//         if(delay_counter + 1'b1 == DATA_DELAY) begin
//             next_state <= write_st;
//             address_counter <= address;
//         end
//     end
//     write_st: begin
//         do_shift <= 1;
//         address_counter <= address_counter + 1'b1;
//         read_write_counter <= read_write_counter + 1'b1;
//         if(read_write_counter == BUFFER_LENGTH) begin
//             next_state <= calm_st;
//             active_memory_decode <= 2'b00;
//         end
//     end
//     calm_st: begin
//         if(start) next_state <= start_st;
//         else next_state <= calm_st;
//     end
//     endcase
// end

endmodule

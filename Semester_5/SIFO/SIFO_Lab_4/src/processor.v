`include "ROM.v"
`include "RAM.v"
`include "wire_hz.v"

module processor #(
    parameter ADDRESS_WIDTH = 10,
    parameter ADDRESS_REGISTERS = 4,
    parameter DATA_WIDTH = 8
)(
    input clk
);

reg [ADDRESS_WIDTH-1:0] ip_reg;
reg [2*DATA_WIDTH-1:0] ir_reg;
reg [DATA_WIDTH-1:0] flags_reg;

wire [DATA_WIDTH-1:0] in_data_ram, out_data_ram;
wire [DATA_WIDTH-1:0] in_data_reg, out_data_reg;
wire [ADDRESS_WIDTH-1:0] in_addr_ram;
wire [ADDRESS_WIDTH-1:0] in_addr_reg;


wire [2*DATA_WIDTH-1:0] out_ir;
assign out_ir = ir_reg;
wire [DATA_WIDTH-1:0] out_rom;

tri [DATA_WIDTH-1:0] general_data_bus;
tri [ADDRESS_WIDTH-1:0] general_addr_bus;

reg [1:0] mux_data_in;
reg [1:0] mux_data_out;
reg [1:0] mux_addr_in;
reg [1:0] mux_addr_out;


ROM #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) proc_rom (
    .clk(clk),
    .address(ip_reg),
    .out_data(out_rom)
);

RAM #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) proc_ram (
    .clk(clk),
    .address(in_addr_ram),
	.in_data(in_data_ram),
    .out_data(out_data_ram),
    .write_enable(1'b0)
);

RAM #(
    .ADDRESS_WIDTH(ADDRESS_REGISTERS),
    .DATA_WIDTH(DATA_WIDTH)
) registers_file (
    .clk(clk),
    .address(in_addr_reg),
	.in_data(in_data_reg),
    .out_data(out_data_reg),
    .write_enable(mux_data_out == 2'b10)
);

localparam [1:0] Calm_st = 0, Command_st = 1, Write1_st = 2, Write2_st = 3;
reg [1:0] cur_state;
reg command_part;

reg [DATA_WIDTH-1:0] tempreg;
always @(posedge clk) begin
    tempreg <= general_data_bus;
end
// always @(*) begin
//     case (mux_data_in)
//         2'b00: general_data_bus = 'hz;
//         2'b01: general_data_bus = out_data_ram;
//         2'b10: general_data_bus = out_data_reg;
//         2'b11: general_data_bus = out_ir;
//     endcase
// end

wire_hz hz_data_out_tempreg(.in_data(tempreg), .out_data(general_data_bus), .out_is_active(mux_data_in == 2'b00));
wire_hz hz_data_out_ram(.in_data(out_data_ram), .out_data(general_data_bus), .out_is_active(mux_data_in == 2'b01));
wire_hz hz_data_out_reg(.in_data(out_data_reg), .out_data(general_data_bus), .out_is_active(mux_data_in == 2'b10));
wire_hz hz_data_out_ir(.in_data(out_ir), .out_data(general_data_bus), .out_is_active(mux_data_in == 2'b11));

// always @(*) begin
//     case (mux_data_out)
//         2'b00: ;
//         2'b01: in_data_ram = general_data_bus;
//         2'b10: in_data_reg = general_data_bus;
//         2'b11: ;
//     endcase
// end

wire_hz hz_data_in_ram(.in_data(general_data_bus), .out_data(in_data_ram), .out_is_active(mux_data_out == 2'b01));
wire_hz hz_data_in_reg(.in_data(general_data_bus), .out_data(in_data_reg), .out_is_active(mux_data_out == 2'b10));

// always @(*) begin
//     case (mux_addr_in)
//         2'b00: general_address_bus = 'hz;
//         2'b01: general_address_bus = out_data_ram;
//         2'b10: general_address_bus = out_data_reg;
//         2'b11: general_address_bus = out_ir;
//     endcase
// end

wire_hz #(10) hz_addr_out_ir_1310(.in_data({6'h0,out_ir[13:10]}), .out_data(general_addr_bus), .out_is_active(mux_addr_in == 2'b00));
wire_hz hz_addr_out_ram(.in_data(out_data_ram), .out_data(general_addr_bus), .out_is_active(mux_addr_in == 2'b01));
wire_hz hz_addr_out_reg(.in_data(out_data_reg), .out_data(general_addr_bus), .out_is_active(mux_addr_in == 2'b10));
wire_hz #(10) hz_addr_out_ir_90(.in_data(out_ir[9:0]), .out_data(general_addr_bus), .out_is_active(mux_addr_in == 2'b11));

// always @(*) begin
//     case (mux_addr_out)
//         2'b00: ;
//         2'b01: in_addr_ram = general_address_bus;
//         2'b10: in_addr_reg = general_address_bus;
//         2'b11: ;
//     endcase
// end

//!!!!!!!!!!!!!!!!!!!!!!!!!!
wire_hz hz_addr_in_ram(.in_data(general_addr_bus), .out_data(in_addr_ram), .out_is_active(mux_addr_out == 2'b01));
wire_hz hz_addr_in_reg(.in_data(general_addr_bus), .out_data(in_addr_reg), .out_is_active(mux_addr_out == 2'b10));

// 
//mov M->R 00RR|RRAA||AAAA|AAAA      TODO  lw
//js       0100|00AA||AAAA|AAAA      TODO  IP+DATA if sign bit   
//sub_c    1000|RRRR||RRRR|0000      TODO  RDATA-DATA +-1?
//xor      1100|RRRR||RRRR|0000      TODO
//         F  C|B  8||7  4|3  0
//flags    0000|00CS

always @(posedge clk) begin
    case(cur_state) 
        Command_st: begin
            case (ir_reg[2*DATA_WIDTH-1:2*DATA_WIDTH-2])
                2'b00: begin //mov M->R 
                    mux_addr_in  <= 2'b11; // addr from ir
                    mux_addr_out <= 2'b01; // addr goes to ram
                    mux_data_in  <= 2'b01; // data from ram
                    mux_data_out <= 2'b10; // data to reg
                    cur_state <= Write1_st;
                end
                2'b01: begin //js
                    if(flags_reg[0] == 1'b1) begin
                        ip_reg <= ip_reg + ir_reg[9:0];
                    end

                    cur_state <= Calm_st;
                end 
                2'b10: begin //sub_c
                    cur_state <= Calm_st;
                end
                2'b11: begin //xor
                    cur_state <= Calm_st;
                end 
            endcase
        end
        Write1_st: begin
            mux_addr_in <= 2'b00; // reg addr
            mux_data_in <= 2'b00; // write from temp reg
            mux_addr_out <= 2'b10; 
            cur_state <= Calm_st;
        end
        Write2_st: begin
            cur_state <= Calm_st;
        end
        Calm_st: begin
            
            mux_addr_in <= 2'bzz; 
            mux_addr_out <= 2'bzz; 
            mux_data_in <= 2'bzz; 
            mux_data_out <= 2'bzz; 

            ip_reg <= ip_reg + 1'b1;
            
            if(command_part == 1'b0) begin
                ir_reg[15:8] <= out_rom;
                command_part <= 1'b1;
                cur_state <= Calm_st;
            end
            else begin
                ir_reg[7:0] <= out_rom;
                command_part <= 1'b0;
                cur_state <= Command_st;
            end
        end
    endcase
end

initial begin 
    command_part = 1'b0;
    {ip_reg, flags_reg, tempreg} = 0;
    cur_state = Calm_st;
    {mux_data_in, mux_data_out, mux_addr_in, mux_addr_out} = 2'b00;
end

endmodule
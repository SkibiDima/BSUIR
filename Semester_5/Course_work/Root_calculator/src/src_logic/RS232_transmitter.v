module RS232_transmitter #(
    parameter CLK_DIVIDER = 5208 // 9600 baud
)(
    input clk,
    input [7:0] data,
    input data_ready,
    output reg tx,
    output reg rts
);

    localparam Wait_st = 2'b00;
    localparam Start_st = 2'b01;
    localparam Data_st = 2'b10;
    localparam Stop_st = 2'b11;

    reg [1:0] cur_state;
    reg [3:0] bit_count;
    reg [15:0] tick_count;

    initial begin
        cur_state = Wait_st;
        rts = 1'b1;
        bit_count = 4'b0000;
        tick_count = 16'h0000;
    end

    always @(posedge clk) begin

        case(cur_state)
            Wait_st: begin
                tx <= 1'b1;
                if(data_ready == 1'b1) begin
                    cur_state <= Start_st;
                    rts <= 1'b0;
                end
                else rts <= 1'b1;
            end
            Start_st: begin
                tx <= 1'b0;
                tick_count <= tick_count + 1'b1;
                if(tick_count == 5208) begin
                    tick_count <= 0;
                    cur_state <= Data_st;
                end
            end
            Data_st: begin
                tick_count <= tick_count + 1'b1;
                if(tick_count == 5208) begin
                    tick_count <= 0;
                    bit_count <= bit_count + 1'b1;
                end
                else begin 
                    tx <= data[bit_count];
                end
                if(bit_count == 4'b1000) begin
                    cur_state <= Stop_st;
                    tx <= 1'b1;
                    bit_count <= 4'b0000;
                end
            end
            Stop_st: begin
                tx <= 1'b1;
                rts <= 1'b1;
                tick_count <= tick_count + 1'b1;
                if(tick_count == 5208) begin
                    tick_count <= 0;
                    cur_state <= Wait_st;
                end
            end
            default: cur_state <= Wait_st;
        endcase
    end

endmodule

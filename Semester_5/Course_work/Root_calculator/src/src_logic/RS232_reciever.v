module RS232_reciever #(
    parameter CLK_DIVIDER = 5208 // 9600 baud
)(
    input clk,
    input rx,
    output reg [7:0] data,
    output reg error,
    output reg data_ready
);

    localparam Wait_st = 2'b00;
    localparam Start_st = 2'b01;
    localparam Data_st = 2'b10;
    localparam Stop_st = 2'b11;

    reg [1:0] cur_state, next_state;
    reg [3:0] bit_count;
    reg [15:0] tick_count;

    initial begin
        cur_state = Wait_st;
        next_state = Wait_st;
        error = 1'b0;
        data_ready = 1'b0;
        bit_count = 4'b0000;
        tick_count = 16'h0000;
    end

    always @(posedge clk) begin
        cur_state <= next_state;

        case(cur_state)
            Wait_st: begin
                data <= 0;
                error <= 1'b0;
                tick_count <= 16'h0000;
                bit_count <= 4'b0000;
                if(rx == 1'b0) begin
                    next_state <= Start_st;
                end
            end
            Start_st: begin
                tick_count <= tick_count + 1'b1;
                if(tick_count == CLK_DIVIDER/2) begin
                    if(rx == 1'b1) begin
                        error <= 1'b1;
                        next_state <= Wait_st;
                    end 
                    else begin
                        error <= 1'b0;
                    end
                    if(tick_count == CLK_DIVIDER) begin
                        tick_count <= 16'h0000;
                        next_state <= Data_st;
                    end
                end
            end
            Data_st: begin
                tick_count <= tick_count + 1'b1;
                if(tick_count == CLK_DIVIDER/2) begin
                    data <= rx;
                    bit_count <= bit_count + 1'b1;
                end 
                else begin
                    if(tick_count == CLK_DIVIDER) begin
                        tick_count <= 0;
                        if (bit_count == 4'b1000) begin
                            bit_count <= 4'b0000;
                            next_state <= Stop_st;
                        end
                        else begin
                            next_state <= Data_st;
                        end
                    end
                end
            end
            Stop_st: begin
                tick_count <= tick_count + 1'b1;
                if(tick_count == CLK_DIVIDER/2) begin
                    if(rx == 1'b1) begin
                        data_ready <= 1'b1;
                        error <= 1'b0;
                    end 
                    else begin
                        error <= 1'b1;
                        data_ready <= 0;
                        next_state <= Wait_st;
                    end
                end
                else begin
                    if(tick_count == CLK_DIVIDER) begin
                        tick_count <= 16'h0000;
                        data_ready <= 1'b0;
                        next_state <= Wait_st;
                    end
                end
            end
            default: next_state <= Wait_st;
        endcase
    end

endmodule
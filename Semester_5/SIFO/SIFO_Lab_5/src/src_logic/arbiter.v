module arbiter (
    input clk,
    input [2:0] in_request,
    output [2:0] grant
);
    
    localparam Calm_st = 1'b0, Grant_st = 1'b1;
    reg cur_state;
    initial cur_state = 1'b0;

    reg [1:0] grant_counter;
    initial grant_counter = 2'b00;

    reg [2:0] master_number;
    initial master_number = 3'b000;

    assign grant = master_number;

    always @(posedge clk) begin
        case(cur_state)
            Calm_st: begin
                master_number <= in_request;
                grant_counter <= 2'b00;
                if(in_request != 3'b000) begin
                    cur_state <= Grant_st;
                end
            end
            Grant_st: begin
                grant_counter <= grant_counter + 1'b1;
                if(grant_counter == 2'b11) begin
                    cur_state <= Calm_st;
                end
            end
        endcase
    end


endmodule
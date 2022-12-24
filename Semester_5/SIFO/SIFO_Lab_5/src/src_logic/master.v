module master #(
    parameter [2:0] Number = 3'd1
) (
    input clk,
    input [2:0] grant,
    input [2:0] in_request,
    output reg [2:0] out_request,
    output [4:0] data
);
    // out_request -- number of master; 000 -- no any request
    // data -- number, slave; slave with this number will repeat master's number
    wire [4:0] data_reg;

    reg [2:0] counter;
    initial counter = 3'b000;
    reg [1:0] chosen_slave;
    initial chosen_slave = Number[1:0];
    reg [2:0] own_request;
    initial own_request = 3'b000;

    localparam Calm_st = 0, Grant_st = 1; 

    reg [1:0] cur_state;
    initial cur_state = Calm_st;

    always @(*) begin
        if(in_request > own_request) begin
            out_request = in_request;
        end
        else begin
            out_request = own_request;
        end
    end

    assign data_reg[4:2] = Number;
    assign data_reg[1:0] = chosen_slave;
	assign data = (cur_state == Grant_st) ? data_reg : 5'hz; 

    always @(posedge clk) begin
        case (cur_state)
            Calm_st: begin
                if(own_request == 3'b000) begin
                    counter <= counter + 1'b1;
                end

                if(counter == Number + 1) begin
                    own_request <= Number;
                    chosen_slave <= chosen_slave + 1'b1;
                end

                if(grant == Number & own_request == Number) begin
                    cur_state <= Grant_st;   
                    own_request <= 3'b000;    
                end
            end
            Grant_st: begin     
                if(grant != Number) begin
                    cur_state <= Calm_st;
                end
            end
        endcase
    end

endmodule 
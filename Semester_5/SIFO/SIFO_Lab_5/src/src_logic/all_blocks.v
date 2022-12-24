`include "../src_logic/arbiter.v"
`include "../src_logic/slave.v"
`include "../src_logic/master.v"

module all_blocks (
    input clk
);

    tri [4:0] data_bus;
    wire [2:0] grant_bus;
    wire [2:0] out_requests[3:0];
    wire [2:0] slaves_data[3:0];

    master #(4) master_4(
        .clk(clk),
        .grant(grant_bus),
        .in_request(3'b000),
        .data(data_bus),
        .out_request(out_requests[0])
    );
																				
    master #(3) master_3(
        .clk(clk),																																																		
        .grant(grant_bus),												
        .in_request(out_requests[0]),
        .data(data_bus),																
        .out_request(out_requests[1])
    );

    master #(2) master_2(
        .clk(clk),
        .grant(grant_bus),
        .in_request(out_requests[1]),
        .data(data_bus),
        .out_request(out_requests[2])
    );

    master #(1) master_1(
        .clk(clk),
        .grant(grant_bus),
        .in_request(out_requests[2]),
        .data(data_bus),
        .out_request(out_requests[3])
    );

    arbiter arbiter(
        .clk(clk),
        .in_request(out_requests[3]),
        .grant(grant_bus)
    );

    generate
        genvar i;
        for(i = 0; i < 4; i = i + 1) begin : slave_generate
            slave #(i) slave_ (.data(data_bus), .slave_data(slaves_data[i]));
        end
    endgenerate

    
endmodule
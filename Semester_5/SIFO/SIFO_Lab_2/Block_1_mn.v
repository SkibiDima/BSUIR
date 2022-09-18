// Copyright (C) 2021  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 21.1.0 Build 842 10/21/2021 SJ Lite Edition"
// CREATED		"Sat Sep 17 21:55:19 2022"

module Block_1_mn(
	CLK_50hz,
	CLK2,
	CLK4,
	CLK8,
	CLK10T,
	N,
	M,
	CLK16
);


input wire	CLK_50hz;
output wire	CLK2;
output wire	CLK4;
output wire	CLK8;
output reg	CLK10T;
output wire	N;
output wire	M;
output wire	CLK16;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_3;
reg	SYNTHESIZED_WIRE_21;
reg	SYNTHESIZED_WIRE_22;
wire	SYNTHESIZED_WIRE_23;
wire	SYNTHESIZED_WIRE_24;
reg	TFF_T1;
reg	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_26;
wire	SYNTHESIZED_WIRE_27;

assign	CLK2 = SYNTHESIZED_WIRE_22;
assign	CLK4 = TFF_T1;
assign	CLK8 = SYNTHESIZED_WIRE_25;
assign	N = SYNTHESIZED_WIRE_3;
assign	M = SYNTHESIZED_WIRE_20;
assign	CLK16 = SYNTHESIZED_WIRE_21;
assign	SYNTHESIZED_WIRE_0 = 1;
assign	SYNTHESIZED_WIRE_27 = 1;




always@(posedge SYNTHESIZED_WIRE_1)
begin
	CLK10T <= CLK10T ^ SYNTHESIZED_WIRE_0;
end



assign	SYNTHESIZED_WIRE_1 = ~(SYNTHESIZED_WIRE_20 & SYNTHESIZED_WIRE_3);

assign	SYNTHESIZED_WIRE_20 = ~(SYNTHESIZED_WIRE_21 & SYNTHESIZED_WIRE_22 & SYNTHESIZED_WIRE_23 & SYNTHESIZED_WIRE_24);

assign	SYNTHESIZED_WIRE_26 =  ~SYNTHESIZED_WIRE_22;

assign	SYNTHESIZED_WIRE_24 =  ~TFF_T1;

assign	SYNTHESIZED_WIRE_23 =  ~SYNTHESIZED_WIRE_25;

assign	SYNTHESIZED_WIRE_6 =  ~SYNTHESIZED_WIRE_21;

assign	SYNTHESIZED_WIRE_3 = ~(SYNTHESIZED_WIRE_6 & SYNTHESIZED_WIRE_26 & SYNTHESIZED_WIRE_25 & SYNTHESIZED_WIRE_24);


always@(posedge CLK_50hz or negedge SYNTHESIZED_WIRE_20)
begin
if (!SYNTHESIZED_WIRE_20)
	begin
	SYNTHESIZED_WIRE_22 <= 0;
	end
else
	SYNTHESIZED_WIRE_22 <= SYNTHESIZED_WIRE_22 ^ SYNTHESIZED_WIRE_27;
end


always@(posedge SYNTHESIZED_WIRE_26 or negedge SYNTHESIZED_WIRE_20)
begin
if (!SYNTHESIZED_WIRE_20)
	begin
	TFF_T1 <= 0;
	end
else
	TFF_T1 <= TFF_T1 ^ SYNTHESIZED_WIRE_27;
end


always@(posedge SYNTHESIZED_WIRE_24 or negedge SYNTHESIZED_WIRE_20)
begin
if (!SYNTHESIZED_WIRE_20)
	begin
	SYNTHESIZED_WIRE_25 <= 0;
	end
else
	SYNTHESIZED_WIRE_25 <= SYNTHESIZED_WIRE_25 ^ SYNTHESIZED_WIRE_27;
end


always@(posedge SYNTHESIZED_WIRE_23 or negedge SYNTHESIZED_WIRE_20)
begin
if (!SYNTHESIZED_WIRE_20)
	begin
	SYNTHESIZED_WIRE_21 <= 0;
	end
else
	SYNTHESIZED_WIRE_21 <= SYNTHESIZED_WIRE_21 ^ SYNTHESIZED_WIRE_27;
end


endmodule

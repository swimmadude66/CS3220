module Ledr(reset, aBus, dBus, wrtEn, ledr);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 32'h0;
	
	input reset;
	input [ABUS_WIDTH-1:0] aBus;
	inout [DBUS_WIDTH-1:0] dBus;
	input wrtEn;
	output [9:0] ledr;
	
	wire[9:0] rledrOut;
	Register #(.BIT_WIDTH(10), .RESET_VALUE(0)) rledr (registerWrt, reset, registerWrt, dBus[9:0], rledrOut);
	wire registerWrt;
/*	
	always @(*) begin
		if (aBus == 32'hF0000004 && wrtEn) begin
			registerWrt <= 1'b1;
		end
		else
			registerWrt <= 1'b0;
	end
*/
	assign registerWrt = (aBus == 32'hF0000004 && wrtEn) ? 1'b1 : 1'b0;
	assign dBus = (aBus == 32'hF0000004 && !wrtEn) ? {22'b0,rledrOut} : 32'bz;
	assign ledr = rledrOut;
endmodule


module Ledg(reset, aBus, dBus, wrtEn, ledg);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 32'h0;
	
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	output [7:0] ledg;
	
	wire[7:0] rledgOut;
	Register #(.BIT_WIDTH(8), .RESET_VALUE(0)) rledg (registerWrt, reset, registerWrt, dBus[7:0], rledgOut);
	wire registerWrt;
	
	/*
	always @(*) begin
		if (aBus == 32'hF0000008 && wrtEn) begin
			registerWrt <= 1'b1;
		end
		else
			registerWrt <= 1'b0;
	end
	*/
	assign registerWrt = (aBus == 32'hF0000008 && wrtEn) ? 1'b1 : 1'b0;
	assign dBus = (aBus == 32'hF0000008 && !wrtEn) ? {24'b0,rledgOut} : 32'bz;
	assign ledg = rledgOut;
	
endmodule


module Hex(reset, aBus, dBus, wrtEn, hex0, hex1, hex2, hex3);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 32'h0;
	
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	
	output [6:0] hex0;
	output [6:0] hex1;
	output [6:0] hex2;
	output [6:0] hex3;
	wire[15:0] rhexOut;
	Register #(.BIT_WIDTH(16), .RESET_VALUE(0)) rhex (registerWrt, reset, registerWrt, dBus[15:0], rhexOut);
	wire registerWrt;
	/*
	always @(*) begin
		if (aBus == 32'hF0000000 && wrtEn) begin
			registerWrt <= 1'b1;
		end
		else
			registerWrt <= 1'b0;
	end
	*/
	assign registerWrt = (aBus == 32'hF0000000 && wrtEn) ? 1'b1 : 1'b0;
	assign dBus = (aBus == 32'hF0000000 && !wrtEn) ? {16'b0,rhexOut} : 32'bz;
	
	SevenSeg hex0Converter(rhexOut[3:0], hex0);
	SevenSeg hex1Converter(rhexOut[7:4], hex1);
	SevenSeg hex2Converter(rhexOut[11:8], hex2);
	SevenSeg hex3Converter(rhexOut[15:12], hex3);
endmodule

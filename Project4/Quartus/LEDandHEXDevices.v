module Ledr(reset, aBus, dBus, wrtEn, ledr);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 32'h0;
	
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	output [9:0] ledr;
	
	reg [DBUS_WIDTH -1: 0] rledr = RESET_VALUE;
	
	always @(*)begin
		if (reset == 1'b1) begin
			rledr = RESET_VALUE;
		end
		else begin
			if ((aBus == 32'hF0000004) && (wrtEn == 1'b1)) begin
				rledr <= dBus[9:0];
			end
		end
	end
	assign dBus = (aBus == 32'hF0000004 && !wrtEn) ? rledr : 32'bz;
	assign ledr = rledr[9:0];
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
	reg [DBUS_WIDTH -1: 0] rledg = RESET_VALUE;
	
	always @(*) begin
		if (reset == 1'b1) begin
			rledg = RESET_VALUE;
		end
		else begin
			if (aBus == 32'hF0000008 && wrtEn) begin
				rledg <= dBus[7:0];
			end
		end
	end
	
	assign dBus = (aBus == 32'hF0000008 && !wrtEn) ? rledg : 32'bz;
	assign ledg = rledg[7:0];
	
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
	Register rhex () (registerWrt, reset, registerWrt, DBUS[15:0], rhexOut);
	reg registerWrt;
	
	always @(*)begin
		if (aBus == 32'hF0000000 && wrtEn) begin
			registerWrt <= 1'b1;
		end
		else
			registerWrt <= 1'b0;
		end
	end
	
	assign dBus = (registerWrt) ? {16'b0,rhexOut} : 32'bz;
	
	SevenSeg hex0Converter(rhex[3:0], hex0);
	SevenSeg hex1Converter(rhex[7:4], hex1);
	SevenSeg hex2Converter(rhex[11:8], hex2);
	SevenSeg hex3Converter(rhex[15:12], hex3);
endmodule

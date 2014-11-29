module Ledr(clk, reset, aBus, dBus, wrtEn, ledr);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 10'b0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH-1:0] aBus;
	inout [DBUS_WIDTH-1:0] dBus;
	input wrtEn;
	output [9:0] ledr;

	//reg [9:0] rledrValue = 10'b0;
	reg [9:0] rledrOut = RESET_VALUE; 
	//Register #(.BIT_WIDTH(10), .RESET_VALUE(0)) rledr (registerWrt, reset, registerWrt, dBus[9:0], rledrOut);
	//wire registerWrt;
	//assign rledrOut = (aBus == 32'hF0000004 && wrtEn) ? dBus[9:0] : rledrValue;

	always @(posedge clk) begin
		if (reset) begin
			rledrOut <= RESET_VALUE;
		end
		else begin
			rledrOut <= (aBus == 32'hF0000004 && wrtEn) ? dBus[9:0] : rledrOut;//rledrValue;
			//rledrValue = rledrOut;
		end
	end
	
	//assign registerWrt = (aBus == 32'hF0000004 && wrtEn) ? 1'b1 : 1'b0;
	assign dBus = (aBus == 32'hF0000004 && !wrtEn) ? {22'b0,rledrOut} : 32'bz;
	assign ledr = rledrOut;
endmodule


module Ledg(clk, reset, aBus, dBus, wrtEn, ledg);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 8'b0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH-1:0] aBus;
	inout [DBUS_WIDTH-1:0] dBus;
	input wrtEn;
	output [7:0] ledg;
	
	//reg [7:0] rledgValue = 8'b0;
	reg [7:0] rledgOut = RESET_VALUE;
	//Register #(.BIT_WIDTH(8), .RESET_VALUE(0)) rledg (registerWrt, reset, wrtEn, dBus[7:0], rledgOut);
	//reg registerWrt = 1'b0;
	//assign rledgOut = (aBus == 32'hF0000008 && wrtEn) ? dBus[7:0] : rledgValue;
	
	always @(posedge clk) begin
		if (reset) begin
			rledgOut <= RESET_VALUE;
		end
		else begin
			rledgOut <= (aBus == 32'hF0000008 && wrtEn) ? dBus[7:0] : rledgOut;//rledgValue;
			//rledgValue = rledgOut;
		end
	end
	
	
	//assign registerWrt = (aBus == 32'hF0000008 && wrtEn) ? 1'b1 : 1'b0;
	assign dBus = (aBus == 32'hF0000008 && !wrtEn) ? {24'b0,rledgOut} : 32'bz;
	assign ledg = rledgOut;
	
endmodule


module Hex(clk, reset, aBus, dBus, wrtEn, hex0, hex1, hex2, hex3);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 16'b0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	
	output [6:0] hex0;
	output [6:0] hex1;
	output [6:0] hex2;
	output [6:0] hex3;
	
	//reg [15:0] rhexValue = 16'b0;
	reg [15:0] rhexOut = RESET_VALUE;
	
	//Register #(.BIT_WIDTH(16), .RESET_VALUE(0)) rhex (registerWrt, reset, registerWrt, dBus[15:0], rhexOut);
	//wire registerWrt;
	//assign rhexOut = (aBus == 32'hF0000000 && wrtEn) ? dBus[15:0] : rhexValue;
	
	always @(posedge clk) begin
		if (reset) begin
			rhexOut = RESET_VALUE;
		end
		else begin
			rhexOut <= (aBus == 32'hF0000000 && wrtEn) ? dBus[15:0] : rhexOut;//rhexValue;
			//rhexValue = rhexOut;
		end
	end
	
	//assign registerWrt = (aBus == 32'hF0000000 && wrtEn) ? 1'b1 : 1'b0;
	assign dBus = (aBus == 32'hF0000000 && !wrtEn) ? {16'b0,rhexOut} : 32'bz;
	
	SevenSeg hex0Converter(rhexOut[3:0], hex0);
	SevenSeg hex1Converter(rhexOut[7:4], hex1);
	SevenSeg hex2Converter(rhexOut[11:8], hex2);
	SevenSeg hex3Converter(rhexOut[15:12], hex3);
endmodule

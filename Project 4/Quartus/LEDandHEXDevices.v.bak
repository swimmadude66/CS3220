module LEDandHEXDevices(reset, aBus, dBus, wrtEn, ledr, ledg, hex0, hex1, hex2, hex3);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 32'h0;
	
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	output [9:0] ledr;
	output [7:0] ledg;
	output [6:0] hex0;
	output [6:0] hex1;
	output [6:0] hex2;
	output [6:0] hex3;
	
	reg [DBUS_WIDTH -1: 0] dBus;
	reg [DBUS_WIDTH -1: 0] rledr = RESET_VALUE;
	reg [DBUS_WIDTH -1: 0] rledg = RESET_VALUE;
	reg [DBUS_WIDTH -1: 0] rhex = RESET_VALUE;
	
	always @(*) begin
		if (reset == 1'b1) begin
			rledr = RESET_VALUE;
			rledg = RESET_VALUE;
			rhex = RESET_VALUE;
		end
		else begin
			if (aBus == 32'hF0000000) begin
				if (wrtEn == 1'b0) begin
					dBus <= rhex;
				end
				else begin
					rhex <= dBus[15:0];
					dBus <= 32'bz;
				end
			end
			else if (aBus == 32'hF0000004) begin
				if (wrtEn == 1'b0) begin
					dBus <= rledr;
				end
				else begin
					rledr <= dBus[9:0];
					dBus <= 32'bz;
				end
			end
			else if (aBus == 32'hF0000008) begin
				if (wrtEn == 1'b0) begin
					dBus <= rledg;
				end
				else begin
					rledg <= dBus[7:0];
					dBus <= 32'bz;
				end
			end
			else begin
				dBus <= 32'bz;
			end
		end
	end
	
	assign ledr = rledr;
	assign ledg = rledg;
	SevenSeg hex0Converter(rhex[3:0], HEX0);
	SevenSeg hex1Converter(rhex[7:4], HEX1);
	SevenSeg hex2Converter(rhex[11:8], HEX2);
	SevenSeg hex3Converter(rhex[15:12], HEX3);
endmodule
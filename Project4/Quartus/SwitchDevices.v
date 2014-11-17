module SwitchDevices(clk, reset, aBus, dBus, wrtEn, switches);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter KDATA_RESET_VALUE = 4'h0;
	parameter KCTRL_RESET_VALUE = 8'h0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	
	Register #(.BIT_WIDTH(10), .RESET_VALUE(KDATA_RESET_VALUE)) swdata (clk, reset, 1'b1, swdataIn, swdataOut);
	Register #(.BIT_WIDTH(9), .RESET_VALUE(KCTRL_RESET_VALUE)) swctrl (clk, reset, 1'b1, swctrlIn, swctrlOut);
	
	reg oneTimeSwInit = 1'b1;
	input[9:0] switches;
	reg [9:0] swdebounce;
	reg [9:0] swdataIn;
	reg [20:0] swcounter = 21'b0;
	wire [3:0] swdataOut;
	wire [8:0] swctrlIn;
	wire [8:0] swctrlOut;
	
	always @(*) begin
		if (aBus == 32'hF0000014 && !wrtEn)	//Read from Keys
			swctrl[0] = 1'b0;
		else if (aBus == 32'hF0000114 && wrtEn) begin
			if (dBus[2] == 0) begin
				swctrl[2] = 1'b0;
			end
			swctrl[8] = dBus[8];
		end	
		else if(swdataIn != swdataOut) begin				//Keys has changed
		   swctrl[2] = 1'b1&swctrl[0];
			swctrl[0] = 1'b1;
		end
	end
	
	always @(posedge clk) begin
		if (oneTimeSwInit) begin
			swdataIn <= switches;
			swdebounce <= switches;
		end
		else if (switches != swdebounce) begin
			swdebounce <= switches;
			swcounter <= 20'b0;
		end
		else if (swcounter >= 499999) begin
			swdataIn <= swdebounce;
		end
		else begin
			swcounter <= swcounter + 21'd1;
		end
	end
	
	assign dBus = 	(aBus == 32'hF0000014 && !wrtEn) ? {22'b0, swdataOut} :
						(aBus == 32'hF0000114 && !wrtEn) ? {23'b0, swctrlOut} :
						32'bz;
	
endmodule

//module SwitchDevices(clk, reset, aBus, dBus, wrtEn, switches);
//	parameter ABUS_WIDTH = 32;
//	parameter DBUS_WIDTH = 32;
//	parameter SWDATA_RESET_VALUE = 10'h0;
//	parameter SWCTRL_RESET_VALUE = 8'h0;
//	
//	input clk;
//	input reset;
//	input [ABUS_WIDTH -1:0] aBus;
//	inout [DBUS_WIDTH -1:0] dBus;
//	input wrtEn;
//	
//	//Register #(.BIT_WIDTH(10), .RESET_VALUE(SWDATA_RESET_VALUE)) swdata (clk, reset, , switches, swdataOut);
//	//Register #(.BIT_WIDTH(9), .RESET_VALUE(SWCTRL_RESET_VALUE)) swctrl (clk, reset, 1'b1, swctrlIn, swctrlOut);
//	
//	input[9:0] switches;
//	wire [9:0] swdataOut;
//	reg [9:0] swstblzr;
//	reg [19:0] swcounter = 20'b0;
//	reg [9:0] swdata;
//	reg [9:0] swctrl;
//	//wire [9:0] swctrlOut;
//	
//	always @(posedge clk) begin
//		if (aBus == 32'hF0000014 && !wrtEn)	//Read from Keys
//			swctrl[0] <= 1'b0;
//		else if (aBus == 32'hF0000114 && wrtEn) begin
//			if (dBus[2] == 0) begin
//				swctrl[2] <= 1'b0;
//			end
//			swctrl[8] <= dBus[8];
//		end	
//		else if (swcounter >= 499999) begin
//			if (swdata != swstblzr) begin
//				swdata <= swstblzr;
//				swctrl[2] <= 1'b1&swctrl[0];
//				swctrl[0] <= 1'b1;
//			end
//			else begin
//				swcounter <= 20'b0;
//			end
//		end
//		
//		if (switches != swstblzr) begin
//			swcounter <= 20'b0;
//			swstblzr <= switches;
//		end
//		else begin
//			swcounter <= swcounter + 1;
//		end
//	end
//	
//	assign dBus = 	(aBus == 32'hF0000014 && !wrtEn) ? {22'b0, swdata} :
//						(aBus == 32'hF0000114 && !wrtEn) ? {23'b0, swctrl} :
//						32'bz;
//	
//endmodule

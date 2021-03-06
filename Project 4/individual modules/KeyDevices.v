module KeyDevices(CLOCK_50, KEY, SW, LEDR, LEDG);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter KDATA_RESET_VALUE = 4'b0;
	parameter KCTRL_RESET_VALUE = 8'h0;
	
	output [9:0] LEDR;
	output [7:0] LEDG;
	input [3:0] KEY;
	input [9:0] SW;
	
	input CLOCK_50;
	wire reset;
	assign reset = SW[6];
	wire readData;
	assign readData = SW[8];
	wire writeCtrl;
	assign writeCtrl = SW[9];

	reg oneTimeKInit = 1'b1;
	reg [3:0] kdata;
	reg [7:0] kctrl = KCTRL_RESET_VALUE;
	
	always @(posedge CLOCK_50) begin
		if (reset == 1'b1) begin
			kdata <= KDATA_RESET_VALUE;
			kctrl <= KCTRL_RESET_VALUE;
			oneTimeKInit <= 1'b1;
		end
		else if (oneTimeKInit == 1'b1) begin
			kdata <= KEY;
			oneTimeKInit <= 1'b0;
		end
		else begin
			//for ready bit
			if (readData == 1'b1) begin
				kctrl[0] <= 1'b0;
			end
			else if (KEY != kdata) begin
				kctrl[0] <= 1'b1;
			end
			
			//for overflow bit
			if (writeCtrl == 1'b1) begin
				if (SW[2] == 1'b0) begin
					kctrl[2] <= SW[2];
				end
			end
			else if (KEY != kdata && kctrl[0] == 1'b1) begin
				kctrl[2] <= 1'b1;
			end
			
			//for interrupt enable
			if (writeCtrl == 1'b1) begin
				kctrl[7] <= SW[7];
			end
			
			kdata <= KEY;
			oneTimeKInit <= 1'b0;
		end
	end
	
	assign LEDR = kdata;
	assign LEDG = kctrl;
endmodule




//module KeyDevices(clk, reset, aBus, dBus, wrtEn, keys);
//	parameter ABUS_WIDTH = 32;
//	parameter DBUS_WIDTH = 32;
//	parameter KDATA_RESET_VALUE = 4'h0;
//	parameter KCTRL_RESET_VALUE = 8'h0;
//	
//	input clk;
//	input reset;
//	input [ABUS_WIDTH -1:0] aBus;
//	inout [DBUS_WIDTH -1:0] dBus;
//	input wrtEn;
//	
//	Register #(.BIT_WIDTH(4), .RESET_VALUE(KDATA_RESET_VALUE)) kdata (clk, reset, 1'b1, keys, kdataOut);
//	Register #(.BIT_WIDTH(9), .RESET_VALUE(KCTRL_RESET_VALUE)) kctrl (clk, reset, 1'b1, kctrlIn, kctrlOut);
//	
//	input [3:0] keys;
//	wire [3:0] kdataOut;
//	wire [8:0] kctrlIn;
//	wire [8:0] kctrlOut;
//	
//	always @(*) begin
//		if (aBus == 32'hF0000010 && !wrtEn)	//Read from Keys
//			kctrl[0] = 1'b0;
//		else if (aBus == 32'hF0000110 && wrtEn) begin
//			if (dBus[2] == 0) begin
//				kctrl[2] = 1'b0;
//			end
//			kctrl[8] = dBus[8];
//		end	
//		else if(keys != kdataOut) begin				//Keys has changed
//		   kctrl[2] = 1'b1&kctrl[0];
//			kctrl[0] = 1'b1;
//		end
//	end
//	
//	assign dBus = 	(aBus == 32'hF0000010 && !wrtEn) ? {28'b0,kdataOut} :
//						(aBus == 32'hF0000110 && !wrtEn) ? {23'b0,kctrlOut} :
//						32'bz;
//	
//endmodule
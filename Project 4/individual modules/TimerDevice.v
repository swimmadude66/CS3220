module TimerDevice(CLOCK_50, KEY, SW, LEDR, LEDG);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;

	parameter TCTRL_RESET_VALUE = 8'h0;
	parameter CNT_RESET_VALUE = 32'b0;
	
	output [9:0] LEDR;
	output [7:0] LEDG;
	input [3:0] KEY;
	input [9:0] SW;
	
	input CLOCK_50;
	wire reset;
	assign reset = KEY[1];
	wire writeLim;
	assign writeLim = KEY[0];
	wire writeCtrl;
	assign writeCtrl = KEY[2];
	wire timerIncrement;
	assign timerIncrement = ((tcnt == tlim - 1) && (tlim != 32'b0) && (internalcnt == 50000000));

	reg [31:0] tcnt = CNT_RESET_VALUE;
	reg [31:0] tlim = 32'b1000;
	reg [7:0] tctrl = TCTRL_RESET_VALUE;
	reg [32:0] internalcnt = CNT_RESET_VALUE;
	
	always @(posedge CLOCK_50) begin
		if (reset == 1'b0) begin
			tcnt <= CNT_RESET_VALUE;
			tlim <= CNT_RESET_VALUE;
			tctrl <= TCTRL_RESET_VALUE;
			internalcnt <= CNT_RESET_VALUE;
		end
		else begin
			//for ready bit
			if (writeCtrl == 1'b0) begin
				if (SW[0] == 1'b0) begin
					tctrl[0] <= SW[0];
				end
			end
			else if (timerIncrement) begin
				tctrl[0] <= 1'b1;
			end
			
			//for overflow bit
			if (writeCtrl == 1'b0) begin
				if (SW[0] == 1'b0) begin
					tctrl[2] <= SW[2];
				end
			end
			else if (timerIncrement && tctrl[0] == 1'b1) begin
				tctrl[2] <= 1'b1;
			end
			
			//for interrupt enable
			if (writeCtrl == 1'b0) begin
				tctrl[7] <= SW[7];
			end
			
			if (writeLim == 1'b0) begin
				tlim = {22'b0, SW};
			end
			
			if (internalcnt == 50000000) begin
				if (timerIncrement) begin
					tcnt <= CNT_RESET_VALUE;
				end
				else begin
					tcnt <= tcnt + 32'b1;
				end
				internalcnt <= CNT_RESET_VALUE;
			end
			else begin
				tcnt <= tcnt;
				internalcnt <= internalcnt + 32'b1;
			end
		end
	end
	
	assign LEDR = tcnt;
	assign LEDG = tctrl;
endmodule



//module Timer(clk, reset, aBus, dBus, wrtEn);
//	parameter ABUS_WIDTH = 32;
//	parameter DBUS_WIDTH = 32;
//	parameter RESET_VALUE = 32'h0;
//	parameter INTERNAL_RESET_VALUE = 20'h0;
//	parameter TCTRL_RESET_VALUE = 9'h0;
//	
//	input clk;
//	input reset;
//	input [ABUS_WIDTH -1:0] aBus;
//	inout [DBUS_WIDTH -1:0] dBus;
//	input wrtEn;
//	
//	Register #(.BIT_WIDTH(32), .RESET_VALUE(RESET_VALUE)) tcnt (clk, reset, 1'b1, tcntIn, tcntOut);
//	Register #(.BIT_WIDTH(32), .RESET_VALUE(RESET_VALUE)) tlim (clk, reset, 1'b1, tlimIn, tlimOut);
//	Register #(.BIT_WIDTH(9), .RESET_VALUE(TCTRL_RESET_VALUE)) tctrl (clk, reset, 1'b1, tctrlIn, tctrlOut);
//	
//	reg ready = 1'b0;
//	reg [19:0] internalcnt = INTERNAL_RESET_VALUE;
//	reg [31:0] tcntIn = RESET_VALUE;
//	wire [31:0] tcntOut;
//	reg [31:0] tlimIn;
//	wire [31:0] tlimOut;
//	wire [8:0] tctrlIn;
//	wire [8:0] tctrlOut;
//	
//	always @(*) begin
//		if (aBus == 32'hF0000020 && !wrtEn)	//Read from Keys
//			tctrl[0] = 1'b0;
//		else if (aBus == 32'hF0000120 && wrtEn) begin
//			if (dBus[0] == 0) begin
//				tctrl[0] = 1'b0;
//			end
//			if (dBus[2] == 0) begin
//				tctrl[2] = 1'b0;
//			end
//			tctrl[8] = tctrl[8];
//		end	
//		else if(ready) begin				//Keys has changed
//			tctrl[2] = 1'b1&tctrl[0];
//			tctrl[0] = 1'b1;
//		end
//	end
//	
//	always @(posedge clk) begin
//		if (reset) begin
//			internalcnt <= INTERNAL_RESET_VALUE;
//			tcntIn <= RESET_VALUE;
//			tlimIn <= RESET_VALUE;
//			ready <= 1'b0;
//		end
//		else begin
//			if (aBus == 32'hF0000020 && wrtEn) begin
//				internalcnt <= INTERNAL_RESET_VALUE;
//				tcntIn <= dBus;
//			end
//			else if (internalcnt == 500000) begin
//				internalcnt <= INTERNAL_RESET_VALUE;
//				if ((tcntOut == (tlimOut - 1)) && (tlimOut != 32'b0)) begin
//					tcntIn <= RESET_VALUE;
//					ready <= 1'b1;
//				end
//				else begin
//					tcntIn <= tcntIn + 32'h1;
//				end
//			end
//			else begin
//				internalcnt <= internalcnt + 20'h1;
//			end
//			
//			if (aBus == 32'hF0000024 && wrtEn) begin
//				tlimIn <= dBus;
//			end
//			
//			if (ready) begin
//				ready <= 1'b0;
//			end
//		end
//	end
//	
//	assign dBus = 	(aBus == 32'hF0000020 && !wrtEn) ? tcntOut :
//						(aBus == 32'hF0000024 && !wrtEn) ? tlimOut :
//						(aBus == 32'hF0000120 && !wrtEn) ? {23'b0, tctrlOut} :
//						32'bz;
//	
//endmodule
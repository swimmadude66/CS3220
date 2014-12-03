module SwitchDevices(clk, reset, aBus, dBus, wrtEn, switches, IRQ);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter SWDATA_RESET_VALUE = 10'h0;
	parameter SWCTRL_RESET_VALUE = 9'h0;
	parameter INTERNAL_CNT_RESET_VALUE = 32'b0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH - 1:0] aBus;
	inout [DBUS_WIDTH - 1:0] dBus;
	input wrtEn;
	input [9:0] switches;
	output IRQ;
	
	wire readData;
	assign readData = (aBus == 32'hF0000014 && !wrtEn);
	wire writeCtrl;
	assign writeCtrl = (aBus == 32'hF0000114 && wrtEn);
	
	reg oneTimeSwInit = 1'b1;
	reg [9:0] swdebounce;
	reg [9:0] swdata;
	reg [8:0] swctrl = SWCTRL_RESET_VALUE;
	reg [31:0] swcounter = INTERNAL_CNT_RESET_VALUE;
	
	always @(posedge clk) begin
		if (reset == 1'b1) begin
			swctrl <= SWCTRL_RESET_VALUE;
			swcounter <= INTERNAL_CNT_RESET_VALUE;
			oneTimeSwInit <= 1'b1;
		end
			else begin
			//for ready bit
			if (readData == 1'b1) begin
				swctrl[0] <= 1'b0;
			end
			else if ((swcounter == 50000) && (swdebounce != swdata)) begin
				swctrl[0] <= 1'b1;
			end
			
			//for overflow bit
			if (writeCtrl == 1'b1) begin
				if (dBus[2] == 1'b0) begin
					swctrl[2] <= dBus[2];
				end;
			end
			else if ((swcounter == 50000) && (swdebounce != swdata) && swctrl[0] == 1'b1) begin
				swctrl[2] <= 1'b1;
			end
			
			//for interrupt enable
			if (writeCtrl == 1'b1) begin
				swctrl[8] <= dBus[8];
			end
		
			if (oneTimeSwInit == 1'b1) begin
				swdata <= switches;
				swdebounce <= switches;
				swcounter <= INTERNAL_CNT_RESET_VALUE;
			end
			else if (switches != swdebounce) begin
				swdata <= swdata;
				swdebounce <= switches;
				swcounter <= INTERNAL_CNT_RESET_VALUE;
			end
			else if (swcounter == 50000) begin
				if (swdebounce != swdata) begin
					swdata <= swdebounce;
				end
				else begin
					swdata <= swdata;
				end
				swdebounce <= swdebounce;
				swcounter <= INTERNAL_CNT_RESET_VALUE;
			end
			else begin
				swdata <= swdata;
				swdebounce <= swdebounce;
				swcounter <= swcounter + 32'b1;
				
			end
			oneTimeSwInit <= 1'b0;
		end
	end
	
	assign dBus = 	(aBus == 32'hF0000014 && !wrtEn) ? {22'b0, swdata} :
						(aBus == 32'hF0000114 && !wrtEn) ? {23'b0, swctrl} :
						32'bz;
	assign IRQ = (swctrl[0]);
endmodule



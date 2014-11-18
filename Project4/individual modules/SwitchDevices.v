module SwitchDevices(CLOCK_50, KEY, SW, LEDR, LEDG);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter SWDATA_RESET_VALUE = 10'h0;
	parameter SWCTRL_RESET_VALUE = 8'h0;
	parameter INTERNAL_CNT_RESET_VALUE = 32'b0;
	
	output [9:0] LEDR;
	output [7:0] LEDG;
	input [3:0] KEY;
	input [9:0] SW;
	
	input CLOCK_50;
	wire reset;
	assign reset = KEY[1];
	wire readData;
	assign readData = KEY[0];
	wire writeCtrl;
	assign writeCtrl = KEY[2];

	reg oneTimeSwInit = 1'b1;
	reg [9:0] swdebounce;
	reg [9:0] swdata;
	reg [7:0] swctrl = SWCTRL_RESET_VALUE;
	reg [32:0] swcounter = INTERNAL_CNT_RESET_VALUE;
	
	always @(posedge CLOCK_50) begin
		if (reset == 1'b0) begin
			swctrl <= SWCTRL_RESET_VALUE;
			swdata <= SWDATA_RESET_VALUE;
			swcounter <= INTERNAL_CNT_RESET_VALUE;
			oneTimeSwInit <= 1'b1;
		end
			else begin
			//for ready bit
			if (readData == 1'b0) begin
				swctrl[0] <= 1'b0;
			end
			else if ((swcounter == 50000) && (swdebounce != swdata)) begin
				swctrl[0] <= 1'b1;
			end
			
			//for overflow bit
			if (writeCtrl == 1'b0) begin
				if (swctrl == 1'b0) begin
					swctrl[2] <= 1'b0;
				end
			end
			else if ((swcounter == 50000) && (swdebounce != swdata) && swctrl[0] == 1'b1) begin
				swctrl[2] <= 1'b1;
			end
			
			//for interrupt enable
			if (writeCtrl == 1'b0) begin
				swctrl[7] <= ~swctrl[7];
			end
		
			if (oneTimeSwInit == 1'b1) begin
				swdata <= SW;
				swdebounce <= SW;
				swcounter <= INTERNAL_CNT_RESET_VALUE;
			end
			else if (SW != swdebounce) begin
				swdata <= swdata;
				swdebounce <= SW;
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
	
	assign LEDR = swdata;
	assign LEDG = swctrl;
endmodule
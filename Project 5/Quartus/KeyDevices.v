module KeyDevices(clk, reset, aBus, dBus, wrtEn, IE, keys, IRQ);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter KDATA_RESET_VALUE = 4'b0;
	parameter KCTRL_RESET_VALUE = 9'h0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH - 1:0] aBus;
	inout [DBUS_WIDTH - 1:0] dBus;
	input wrtEn, IE;
	input [3:0] keys;
	output IRQ;
	
	wire readData;
	assign readData = (aBus == 32'hF0000010 && !wrtEn);
	wire writeCtrl;
	assign writeCtrl = (aBus == 32'hF0000110 && wrtEn);

	reg oneTimeKInit = 1'b1;
	reg [3:0] kdata;
	reg [8:0] kctrl = KCTRL_RESET_VALUE;
	
	always @(posedge clk) begin
		if (reset == 1'b1) begin
			kdata <= KDATA_RESET_VALUE;
			kctrl <= KCTRL_RESET_VALUE;
			oneTimeKInit <= 1'b1;
		end
		else if (oneTimeKInit == 1'b1) begin
			kdata <= keys;
			oneTimeKInit <= 1'b0;
		end
		else begin
			//for ready bit
			if (readData == 1'b1) begin
				kctrl[0] <= 1'b0;
			end
			else if (keys != kdata) begin
				kctrl[0] <= 1'b1;
			end
			
			//for overflow bit
			if (writeCtrl == 1'b1) begin
				if (dBus[2] == 1'b0) begin
					kctrl[2] <= dBus[2];
				end
			end
			else if (keys != kdata && kctrl[0] == 1'b1) begin
				kctrl[2] <= 1'b1;
			end
			
			//for interrupt enable
			if (writeCtrl == 1'b1) begin
				kctrl[8] <= dBus[8];
			end
			
			kdata <= keys;
			oneTimeKInit <= 1'b0;
		end
	end
	
	assign dBus = 	(aBus == 32'hF0000010 && !wrtEn) ? {28'b0,kdata} :
						(aBus == 32'hF0000110 && !wrtEn) ? {23'b0,kctrl} :
						32'bz;
	assign IRQ = (IE&kctrl[0]);
endmodule
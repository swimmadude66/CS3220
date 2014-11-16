module KeyDevices(clk, reset, aBus, dBus, wrtEn, keys);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter KDATA_RESET_VALUE = 4'h0;
	parameter KCTRL_RESET_VALUE = 8'h0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	
	Register #(.BIT_WIDTH(4), .RESET_VALUE(KDATA_RESET_VALUE)) kdata (clk, reset, 1'b1, keys, kdataOut);
	Register #(.BIT_WIDTH(9), .RESET_VALUE(KCTRL_RESET_VALUE)) kctrl (clk, reset, 1'b1, kctrlIn, kctrlOut);
	
	input [3:0] keys;
	wire [3:0] kdataOut;
	wire [8:0] kctrlIn;
	wire [8:0] kctrlOut;
	
	always @(*) begin
		if (aBus == 32'hF0000010 && !wrtEn)	//Read from Keys
			kctrl[0] = 1'b0;
		else if (aBus == 32'hF0000110 && wrtEn) begin
			if (dBus[2] == 0) begin
				kctrl[2] = 1'b0;
			end
			kctrl[8] = dBus[8];
		end	
		else if(keys != kdataOut) begin				//Keys has changed
		   kctrl[2] = 1'b1&kctrl[0];
			kctrl[0] = 1'b1;
		end
	end
	
	assign dBus = 	(aBus == 32'hF0000010 && !wrtEn) ? {28'b0,kdataOut} :
						(aBus == 32'hF0000110 && !wrtEn) ? {23'b0,kctrlOut} :
						32'bz;
	
endmodule
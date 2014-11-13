module KeyDevices(reset, aBus, dBus, wrtEn, keys);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter KDATA_RESET_VALUE = 32'h0;
	parameter KCTRL_RESET_VALUE = 32'h0;
	
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	input [3:0] keys;
	
	reg [DBUS_WIDTH -1: 0] kdata = KDATA_RESET_VALUE;
	reg [DBUS_WIDTH -1: 0] kctrl = KCTRL_RESET_VALUE;
	reg [DBUS_WIDTH -1: 0] dBus;
	
	always @(*) begin
		if (reset == 1'b1) begin
			kdata = KDATA_RESET_VALUE;
			kctrl = KCTRL_RESET_VALUE;
		end
		else begin
			if (aBus == 32'hF0000010) begin
				if (wrtEn == 1'b0) begin
					dBus <= kdata;
					kctrl[0] <= 1'b0;
				end
				else begin
					dBus <= 32'bz;
				end
			end
			else if (aBus == 32'hF0000110) begin	
				if (wrtEn == 1'b0) begin
					dBus <= kctrl;
				end
				else begin
					if (dBus[2] == 1'b0) begin
						kctrl[2] <=  1'b0;
					end 
					kctrl[8] <= dBus[8];
					dBus <= 32'bz;
				end
			end
			else begin 
				dBus <= 32'bz;
			end
			if(keys)begin
				kdata = keys;
				if (kctrl[0] == 1'b0) begin
					kctrl[0] <= 1'b1;
				end
				else begin
					kctrl[2] <= 1'b1;
				end
			end
		end
	end
endmodule
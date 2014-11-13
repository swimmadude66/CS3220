module KeyDevices(aBus, dBus, wrtEn, keys);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	input [3:0] keys;
	
	reg [DBUS_WIDTH -1: 0] kdata = 32'h0;
	reg [DBUS_WIDTH -1: 0] kctrl = 32'h0;
	reg [DBUS_WIDTH -1: 0] dBus;
	
	always @(*) begin
		if (aBus == 32'hF0000010) begin
			if (wrtEn == 1'b0) begin
				dBus <= kdata;
				kctrl[0] <= 1'b0;
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
			end
		end
		if(keys)begin
			kdata = keys;
			if (kctrl[0] == 1'b0)
				kctrl[0] <= 1'b1;
			else
				kctrl[2] <= 1'b1;
		end
	end
endmodule
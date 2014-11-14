module KeyDevices(reset, aBus, dBus, wrtEn, keys);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter KDATA_RESET_VALUE = 4'h0;
	parameter KCTRL_RESET_VALUE = 8'h0;
	
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	
	reg registerClk, registerreset;
	
	Register #(.BIT_WIDTH(4), .RESET_VALUE(KDATA_RESET_VALUE)) kdata (registerClk, reset, 1'b1, keys, kdataOut);
	Register #(.BIT_WIDTH(8), .RESET_VALUE(KCTRL_RESET_VALUE)) kctrl (registerClk, registerreset, 1'b1, kctrlIn, kctrlOut);
	
	input [3:0] keys;
	wire [3:0] kdataOut;
	wire [7:0] kctrlIn;
	wire [7:0] kctrlOut;
	
	always @(*) begin
		if (aBus == 32'hF0000010 && !wrtEn)	//Read from Keys
			registerreset <= 1'b1;
		else
			registerreset <= reset;

		if(keys != kdataOut) begin				//Keys has changed
		   kctrl[2] = 1'b1&kctrl[0];
			kctrl[0] = 1'b1;			
			registerClk <= 1'b1;
		end
		else
			registerClk <= 1'b0;
	end
	
	assign dBus = 	(aBus == 32'hF0000010 && !wrtEn) ? {28'b0,kdataOut} :
						(aBus == 32'hF0000110 && !wrtEn) ? {24'b0,kctrlOut} :
						32'bz;
	
endmodule
module SwitchDevices(reset, aBus, dBus, wrtEn, switches);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter SWDATA_RESET_VALUE = 10'h0;
	parameter SWCTRL_RESET_VALUE = 8'h0;
	
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	
	reg registerClk, registerreset;
	
	Register #(.BIT_WIDTH(10), .RESET_VALUE(SWDATA_RESET_VALUE)) swdata (registerClk, reset, 1'b1, switches, swdataOut);
	Register #(.BIT_WIDTH(8), .RESET_VALUE(SWCTRL_RESET_VALUE)) swctrl (registerClk, registerreset, 1'b1, swctrlIn, swctrlOut);
	
	input[9:0] switches;
	wire [9:0] swdataOut;
	reg [7:0] swctrlIn;
	wire [7:0] swctrlOut;
	
	always @(*) begin
		if (aBus == 32'hF0000014 && !wrtEn)begin	//Read from Switches
			registerreset <= 1'b1;
			swctrlIn = 8'b0;
		end
		else begin
			swctrlIn = 8'b0;
			registerreset <= reset;
		end
			
		if(switches != swdataOut) begin		//Switches have changed
		   swctrlIn[2] = 1'b1&swctrlOut[0];
			swctrlIn[0] = 1'b1;			
			registerClk <= 1'b1;
		end
		else begin
			swctrlIn = 8'b0;
			registerClk <= 1'b0;
		end
	end
	
	assign dBus = 	(aBus == 32'hF0000014 && !wrtEn) ? {22'b0, swdataOut} :
						(aBus == 32'hF0000114 && !wrtEn) ? {24'b0, swctrlOut} :
						32'bz;
	
endmodule

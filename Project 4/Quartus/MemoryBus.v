module MemoryBus(clk, rst, ABUS, DBUS, we, SW, KEY, LEDR, LEDG, HEX0, HEX1, HEX2, HEX3);
	parameter ADDR_BIT_WIDTH = 11;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_WORDS = (1 << ADDR_BIT_WIDTH);
	
	input clk, rst, we;
	input[31:0] ABUS;
	inout tri [31:0] DBUS;
	
	input[9:0] SW;
	input[3:0] KEY;
	output[9:0] LEDR;
	output[7:0] LEDG;
	output[6:0] HEX0, HEX1, HEX2, HEX3;
	

	//Memory
	DataMemory #(11, 32) dataMem (.clk(clk), .ABUS(ABUS), .dataWrtEn(we), .DBUS(DBUS));
	
	//Devices
	KeyDevices key(rst, ABUS, DBUS, we, KEY);
	SwitchDevices switches(rst, ABUS, DBUS, we, SW);
	Ledr ledR(rst, ABUS, DBUS, we, LEDR);
	Ledg ledG(rst, ABUS, DBUS, we, LEDG);
	Hex heX(rst, ABUS, DBUS, we, HEX0, HEX1, HEX2, HEX3);
	//Timer timer(clk, rst, ABUS, DBUS, we);
	
	
endmodule

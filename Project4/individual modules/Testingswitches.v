module Testingswitches (CLOCK_50, KEY, SW ,LEDR);
	input CLOCK_50;
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	
	tri [31:0] DBUS;
	
	SwitchDevices switches(CLOCK_50, KEY[0], 32'hF0000014, DBUS, KEY[1], SW);
	
	assign LEDR = DBUS[9:0];
	
endmodule
module DataMemory(clk, ABUS, dataWrtEn, DBUS);
	parameter ADDR_BIT_WIDTH = 11;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_WORDS = (1 << ADDR_BIT_WIDTH);
	
	input clk;
	input [31:0] ABUS;
	input dataWrtEn;
	inout [31:0] DBUS;
	
	reg[DATA_BIT_WIDTH - 1: 0] data[0: N_WORDS - 1];
	wire IOAddr = (ABUS[31:28] == 4'hf);
	
	always @ (posedge clk) begin
		if (dataWrtEn&&!IOAddr) 
			data[ABUS[ADDR_BIT_WIDTH-1:0]] <= DBUS;
	end
	
	assign DBUS = (!IOAddr) ? data[ABUS[ADDR_BIT_WIDTH-1:0]] : 32'bz;
	
endmodule

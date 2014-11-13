module DataMemory(clk, ABUS, dataWrtEn, DBUS);
	parameter ADDR_BIT_WIDTH = 11;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_WORDS = (1 << ADDR_BIT_WIDTH);
	
	input clk;
	input[DATA_BIT_WIDTH-1:0] ABUS;
	input dataWrtEn;
	inout[DATA_BIT_WIDTH - 1: 0] DBUS;
	
	reg[DATA_BIT_WIDTH - 1: 0] data[0: N_WORDS - 1];
	
	always @ (posedge clk) begin
		if (dataWrtEn) 
			data[ABUS[ADDR_BIT_WIDTH-1:0]] <= DBUS;
	end
	
	assign DBUS = (dataWrtEn && (ABUS[31:28] != 4'hF)) ? 32'bz : data[ABUS[ADDR_BIT_WIDTH-1:0]];
	
endmodule

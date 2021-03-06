module Mux2to1 (sel, dIn0, dIn1, dOut);
	parameter DATA_BIT_WIDTH = 4;
	
	input sel;
	input [DATA_BIT_WIDTH - 1: 0] dIn0;
	input [DATA_BIT_WIDTH - 1: 0] dIn1;
	output reg [DATA_BIT_WIDTH - 1: 0] dOut;
	
	always @ (*) begin
		if (sel)
			dOut <= dIn1;
		else
			dOut <= dIn0;
	end
	
endmodule
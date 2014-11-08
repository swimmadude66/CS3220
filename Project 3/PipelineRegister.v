module PipelineRegister(clk, reset, wrtEn, nxtPCin, iwordin, nxtPCout, iwordout);
	parameter PC_BIT_WIDTH = 32;
	parameter IWORD_BIT_WIDTH = 32;
	parameter PC_RESET_VALUE = 40;
	parameter IWORD_RESET_VALUE = 32'hFFFFFFFF;
	
	input clk, reset, wrtEn;
	input [PC_BIT_WIDTH - 1: 0] nxtPCin;
	input [IWORD_BIT_WIDTH - 1: 0] iwordin;
	output [PC_BIT_WIDTH - 1: 0] nxtPCout = PC_RESET_VALUE;
	output [IWORD_BIT_WIDTH - 1: 0] iwordout = IWORD_RESET_VALUE;
	reg [PC_BIT_WIDTH - 1: 0] nxtPCout;
	reg [IWORD_BIT_WIDTH - 1: 0] iwordout;
	
	always @(posedge clk) begin
		if (reset == 1'b1)begin
			nxtPCout <= PC_RESET_VALUE;
			iwordout <= IWORD_RESET_VALUE;
		end
		else if (wrtEn == 1'b1)begin
			nxtPCout <= nxtPCin;
			iwordout <= iwordin;
		end
	end
endmodule
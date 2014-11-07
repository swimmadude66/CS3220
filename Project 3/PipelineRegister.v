module PipelineRegister(clk, reset, wrtEn, nxtPCin, iwordin, dRegAddr, nxtPCout, iwordout, prevDRegAddr);
	parameter PC_BIT_WIDTH = 32;
	parameter IWORD_BIT_WIDTH = 32;
	parameter DREG_BIT_WIDTH = 4;
	parameter PC_RESET_VALUE = 40;
	parameter IWORD_RESET_VALUE = 0;
	parameter DREG_RESET_VALUE = 0;
	
	input clk, reset, wrtEn;
	input [PC_BIT_WIDTH - 1: 0] nxtPCin;
	input [IWORD_BIT_WIDTH - 1: 0] iwordin;
	input [DREG_BIT_WIDTH - 1: 0] dRegAddr;
	output [PC_BIT_WIDTH - 1: 0] nxtPCout;
	output [IWORD_BIT_WIDTH - 1: 0] iwordout;
	output [DREG_BIT_WIDTH - 1: 0] prevDRegAddr;
	reg [PC_BIT_WIDTH - 1: 0] nxtPCout;
	reg [IWORD_BIT_WIDTH - 1: 0] iwordout;
	reg [DREG_BIT_WIDTH - 1: 0] prevDRegAddr;
	
	always @(posedge clk) begin
		if (reset == 1'b1)begin
			nxtPCout <= PC_RESET_VALUE;
			iwordout <= IWORD_RESET_VALUE;
			prevDRegAddr <= DREG_RESET_VALUE;
		end
		else if (wrtEn == 1'b1)begin
			nxtPCout <= nxtPCin;
			iwordout <= iwordin;
			prevDRegAddr <= dRegAddr;
		end
	end
endmodule
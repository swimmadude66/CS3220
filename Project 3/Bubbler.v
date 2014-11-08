module Bubbler (clk, isLoad, isBranch, isJAL, cmpIn, s1Addr, s2Addr, s1used, s2used, dAddr, regWrtEn, bubbleOut);
	
	input clk;
	input isLoad, isBranch, isJAL, cmpIn, s1used, s2used, regWrtEn;
	input [3: 0] s1Addr, s2Addr, dAddr;
	reg [3: 0] prevDAddr = 4'b0000;
	reg prevRegWrtEn = 0;
	reg bubble = 1'b0;
	output reg bubbleOut;
	
	always @ (*) begin
		if (isLoad | isBranch | isJAL) begin
			bubble = 1'b1;
		end
		else if (s1used & dAddr == s1Addr) begin
			bubble = 1'b1;
		end
		else if (s2used & dAddr == s2Addr) begin
			bubble = 1'b1;
		end
		else begin
			bubble = 1'b0;
		end
	end
	
	always @ (negedge clk) begin
		prevDAddr <= dAddr;
		prevRegWrtEn <= regWrtEn;
		bubbleOut <= bubble;
	end
endmodule
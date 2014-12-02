module Bubbler(prevWrEn, rs1, rs2, prevrd, bubble);
	input prevWrEn;
	input[3:0] rs1, rs2, prevrd;
	
	output bubble;
	
	assign bubble = ((rs1 == prevrd)||(rs2 == prevrd))&&prevWrEn;
endmodule
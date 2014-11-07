module PCSelector(isBranch, isJAL, cmp, pcSel);

	input isBranch, isJAL, cmp;
	output[1:0] pcSel;

	assign pcSel = ((isBranch&cmp)<<1)&isJAL;

endmodule
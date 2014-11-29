module PriorityEncoder(KIRQ, SWIRQ, TIRQ, IDN);
	wire[3:0] IDN = TIRQ	? 4'h1:
							KIRQ	? 4'h2:
							SWIRQ	? 4'h3:
									  4'hF;
endmodule

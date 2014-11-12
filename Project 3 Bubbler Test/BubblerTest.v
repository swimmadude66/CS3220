module BubbleTest(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
	Bubbler bubbler (SW[0], SW[1], 0, 0, SW[2], {0,0,0,SW[3]}, {0,0,0,SW[4]}, SW[5], SW[6], {0,0,0,SW[7]}, SW[8], bubble);


endmodule
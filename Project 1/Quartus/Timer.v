module Timer(
	input CLOCK_50, 
   input [9:0] SW,	
   input [3:0] KEY, 
   output [6:0] HEX0,
   output [6:0] HEX1,
   output [6:0] HEX2,
   output [6:0] HEX3,
   output reg [9:0] LEDR,
	output reg [2:0] LEDG
   );
	
	reg[6:0] minutes = 0;
	reg[5:0] seconds = 0;
	wire[2:0] X;
	reg[2:0] state = 3'b000;
	
	//countSecond(CLOCK_50, CLOCK);
	TFlipFlop(KEY[1], KEY[0], X[0]);
	TFlipFlop(KEY[2], KEY[0], X[1]);
	dec2_7seg(state, HEX0);
	
	parameter SET_SEC = 3'b000, SET_MIN = 3'b001, START = 3'b010, STOP = 3'b011, FLASH = 3'b100;
	
	always @(negedge KEY[0] or negedge CLOCK_50) begin
		if (KEY[0] == 1'b0) begin
			state <= 3'b000;
		end
		case(state)
			SET_SEC:	if (X[0] == 1'b1) begin
							state <= SET_MIN;
						end
						else if (X[1]  == 1'b1) begin
							state <= START;
						end
						else begin
							if (SW[7:4] >= 5)
								seconds <= 50;
							else begin
								seconds <= SW[7:4]*10;
							end
							if (SW[3:0] >= 9) begin
								seconds <= seconds+9;
							end
							else begin
								seconds <= seconds + SW[3:0];
							end
						end	
			SET_MIN: if (X[1] == 1'b1) begin
							state <= START;
						end
						else begin
							if (SW[7:4] >= 9) begin
								minutes <= 90;
							end
							else begin
								minutes <= (SW[7:4])*10;
							end
							if (SW[3:0] >= 9) begin
								minutes <= minutes+9;
							end
							else begin
								minutes <= minutes + SW[3:0];	
							end
						end
			START: 	if (X[1] == 1'b0) begin
							state <= STOP;
						end
						else if (SW[9] ==  1'b1) begin
							state <= FLASH;
						end
			STOP: 	if (X[1] == 1'b1) begin
							state <= START;
						end
			FLASH: 	if (X[2] == 1'b1) begin
							LEDR = 10'b1111111111;
						end
						else begin
							LEDR = 10'b0000000000;
						end
		endcase
	end
endmodule

module TFlipFlop(reset, clk, tOut);
	input reset, clk;
	output tOut;
	reg tOut = 0;
	
	always @(negedge reset or negedge clk) begin
		if (reset == 1'b0)
			tOut <= 0;
		else 
			tOut <= ~tOut;
	end
endmodule

module dec2_7seg(
	input [3:0] num, 
	output [6:0] display
	);
   assign display = 
	num == 0 ? ~7'b0111111 :
	num == 1 ? ~7'b0000110 :
	num == 2 ? ~7'b1011011 :
	num == 3 ? ~7'b1001111 :
	num == 4 ? ~7'b1100110 :
	num == 5 ? ~7'b1101101 :
	num == 6 ? ~7'b1111101 :
	num == 7 ? ~7'b0000111 :
	num == 8 ? ~7'b1111111 :
	num == 9 ? ~7'b1100111 :
	7'bxxxxxxx;   // Output is a don't care if illegal input
endmodule // dec2_7seg

module countSecond(
	input clkin, 
	input reset,
	input running,
	output reg second
	);
	
	reg[25:0] counter = 0;
	always @(negedge reset or negedge clkin) begin
		if (reset == 1'b0) begin
			counter <= 0;
		end
		if (running == 1'b1) begin
			if (counter >= 50000000) begin
				second = 1'b1;
				counter <= 0;
			end
			else begin
				second = 1'b0;
				counter <= counter + 1;
			end
		end
	end
endmodule

module countDown(
	input secondClock,
	output reg[6:0] minutes,
	output reg[5:0] seconds
	);
		
endmodule



	
	
	
	
	
	
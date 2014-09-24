module Timer(
	input CLOCK_50, 
   input [9:0] SW,	
   input [3:0] KEY, 
   output [6:0] HEX0,
   output [6:0] HEX1,
   output [6:0] HEX2,
   output [6:0] HEX3,
   output reg [9:0] LEDR,
	output reg[0:0] LEDG
   );
	
	reg[3:0] tenminutes = 0;
	reg[3:0] tenseconds = 0;
	reg[3:0] oneminutes = 0;
	reg[3:0] oneseconds = 0;
	
	
	reg[3:0] tenminutesdisplay = 0;
	reg[3:0] tensecondsdisplay = 0;
	reg[3:0] oneminutesdisplay = 0;
	reg[3:0] onesecondsdisplay = 0;
	reg[2:0] state = 0;
	
	
	TFlipFlop(KEY[1], KEY[0], X);				//SET transisiton
	TFlipFlop(KEY[2], KEY[0], Y);				//Start/Stop
	TFlipFlop(CLOCK_F, KEY[0], F);			//stores HEX flash state
	TFlipFlop(ALARM, KEY[0], A);				//Store ALARM state
	
	countSecond(CLOCK_50, Y ,CLOCK_10);		//Counter clock, 1 second, pauses on stop
	countSecond(CLOCK_50, 1, ALARM);			// Alarm Clock, flashes at 1Hz, no pause
	blink(CLOCK_50, CLOCK_F);					//HEX Blinker, flashes at ~3HZ
	
	dec2_7seg(onesecondsdisplay, HEX0);		//Write out relevant times
	dec2_7seg(tensecondsdisplay, HEX1);
	dec2_7seg(oneminutesdisplay, HEX2);
	dec2_7seg(tenminutesdisplay, HEX3);
		
	parameter SET_SEC = 0, SET_MIN = 1, START = 2, FLASH = 3; //No stop needed because our clock pauses in run.
	
	always @(negedge CLOCK_50) begin
		if (KEY[0] == 0) begin			//Check for RESET first
			state <= SET_SEC;
			tenminutes = 0;
			oneminutes = 0;
			tenseconds = 0;
			oneseconds = 0;
			tenminutesdisplay = 0;
			oneminutesdisplay = 0;
			tensecondsdisplay = 0;
			onesecondsdisplay = 0;
			LEDR = 10'b0000000000;
		end
		else begin
			case(state)
				SET_SEC:	begin												//set the seconds
								tenminutesdisplay <= tenminutes;		//make sure display is on
								oneminutesdisplay <= oneminutes;
								if (X == 1'b1) begin
									state <= SET_MIN;
								end
								else if (Y  == 1'b1) begin
									state <= START;
								end
								else begin
									if (SW[7:4] >= 5)
										tenseconds <= 5;
									else begin
										tenseconds <= SW[7:4];
									end
									if (SW[3:0] >= 9) begin
										oneseconds <= 9;
									end
									else begin
										oneseconds <= SW[3:0];
									end
									if (F == 1) begin						//blink the relevant HEX board
										tensecondsdisplay <= 10;
										onesecondsdisplay <= 10;
									end
									else begin
										tensecondsdisplay <= tenseconds;
										onesecondsdisplay <= oneseconds;
									end
								end
							end
				SET_MIN: begin
								tensecondsdisplay <= tenseconds;
								onesecondsdisplay <= oneseconds;
								if (Y == 1'b1) begin
									state <= START;
								end
								else if (X == 1'b0) begin
									state <= SET_SEC;
								end
								else begin
									if (SW[7:4] >= 9) begin
										tenminutes <= 9;
									end
									else begin
										tenminutes <= SW[7:4];
									end
									if (SW[3:0] >= 9) begin
										oneminutes <= 9;
									end
									else begin
										oneminutes <= SW[3:0];	
									end
									if (F == 1) begin
										tenminutesdisplay <= 10;
										oneminutesdisplay <= 10;
									end
									else begin
										tenminutesdisplay <= tenminutes;
										oneminutesdisplay <= oneminutes;
										
									end
								end
							end
				START: 	begin
								tenminutesdisplay <= tenminutes;			//ensure all HEX are on, not blinking
								oneminutesdisplay <= oneminutes;
								tensecondsdisplay <= tenseconds;
								onesecondsdisplay <= oneseconds;
								if(CLOCK_10 == 1'b1) begin					//fires every second
									if(oneseconds >0)begin
										oneseconds <= oneseconds - 1;
									end
									else begin									//check seconds, and roll upward
										if(tenseconds >0)begin
											tenseconds <= tenseconds - 1;
											oneseconds <= 9;
										end
										else begin
											if(oneminutes>0)begin
												oneminutes <= oneminutes - 1;
												tenseconds <= 5;
												oneseconds <= 9;
											end
											else begin
												if(tenminutes>0)begin
													tenminutes <= tenminutes - 1;
													oneminutes <= 9;
													tenseconds <= 5;
													oneseconds <= 9;
												end
												else begin
													state <= FLASH;		//if everything is zero, no need to stick around!
												end
											end
										end
									end 
								end
							end
				FLASH: 	if (A == 1'b1) begin
								LEDR = 10'b1111111111;
							end
							else begin
								LEDR = 10'b0000000000;
							end
			endcase
		end
	end
endmodule

module TFlipFlop(clk, reset, tOut);
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
	num == 10 ? ~ 7'b0000000 :
	7'bxxxxxxx;   // Output is a don't care if illegal input
endmodule // dec2_7seg

module countSecond(clkin, running, second);
	input clkin;
	input running;
	output second;
	reg second = 0;
	
	reg[25:0] counter = 0;
	always @(negedge clkin or negedge running) begin
		if(running  == 0) begin
			counter <= counter;
		end
		else begin	
			if (counter >= 50000000) begin
				second = 1;
				counter <= 0;
			end
			else begin
				second = 0;
				counter <= counter + 1;
			end
		end
	end
endmodule

// The CLOCK_27 and CLOCK_24 inputs were not being recognized. Otherwise, every use of this would just be a countSecond
// with a different clock and constant running bit

module blink(clkin, blinkout);
	input clkin;
	output blinkout;
	reg blinkout = 0;
	
	reg[25:0] counter = 0;
	always @(negedge clkin) begin
		if (counter >= 20000000) begin
			blinkout = 1;
			counter <= 0;
		end
		else begin
			blinkout = 0;
			counter <= counter + 1;
		end
	end
endmodule





	
	
	
	
	
	
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
	
	
	TFlipFlop(KEY[1], KEY[0], X);
	TFlipFlop(KEY[2], KEY[0], Y);
	TFlipFlop(CLOCK_10, KEY[0], Z);
	TFlipFlop(CLOCK_F, KEY[0], F);
	
	countSecond(CLOCK_50, Y ,CLOCK_10);
	countSecond(CLOCK_50, 1 ,CLOCK_F);
	
	dec2_7seg(onesecondsdisplay, HEX0);
	dec2_7seg(tensecondsdisplay, HEX1);
	dec2_7seg(oneminutesdisplay, HEX2);
	dec2_7seg(tenminutesdisplay, HEX3);
	
	//countDown(CLOCK_10, tenminutes, oneminutes, tenseconds, oneseconds, DONE);
	
	parameter SET_SEC = 0, SET_MIN = 1, START = 2, STOP = 3, FLASH = 4;
	
	always @(negedge CLOCK_50) begin
		if (KEY[0] == 0) begin
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
				SET_SEC:	begin
								tenminutesdisplay <= tenminutes;
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
									if (F == 1) begin
										tensecondsdisplay <= tenseconds;
										onesecondsdisplay <= oneseconds;
									end
									else begin
										tensecondsdisplay <= 10;
										onesecondsdisplay <= 10;
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
										tenminutesdisplay <= tenminutes;
										oneminutesdisplay <= oneminutes;
									end
									else begin
										tenminutesdisplay <= 10;
										oneminutesdisplay <= 10;
									end
								end
							end
				START: 	begin
								tenminutesdisplay <= tenminutes;
								oneminutesdisplay <= oneminutes;
								tensecondsdisplay <= tenseconds;
								onesecondsdisplay <= oneseconds;
								if (Y == 1'b0) begin
									state <= STOP;
								end
								else if (SW[9] ==  1'b1) begin
									state <= FLASH;
								end
								else begin 
									if(CLOCK_10 == 1'b1) begin
										if(oneseconds >0)begin
											oneseconds <= oneseconds - 1;
										end
										else begin
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
														state <= FLASH;
													end
												end
											end
										end 
									end
								end
							end
				STOP: 	if (Y == 1'b1) begin
								state <= START;
							end
				FLASH: 	if (F == 1'b1) begin
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

module countDown(secondClock, tm, om, ts, os, DONE);
	input secondClock;
	inout reg[3:0] tm, om, ts, os;
	output reg DONE;

	always @(negedge secondClock) begin
		if(os >0)begin
			os <= os - 1;
		end
		else begin
			if(ts >0)begin
				ts <= ts - 1;
				os <= 9;
			end
			else begin
				if(om>0)begin
					om <= om - 1;
					ts <= 5;
					os <= 9;
				end
				else begin
					if(tm>0)begin
						tm <= tm - 1;
						om <= 9;
						ts <= 5;
						os <= 9;
					end
					else begin
						DONE <= 1;
					end
				end
			end
		end
	end
	
	
		
endmodule



	
	
	
	
	
	
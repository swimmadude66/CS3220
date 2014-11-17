module Timer(clk, reset, aBus, dBus, wrtEn);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;
	parameter RESET_VALUE = 32'h0;
	parameter INTERNAL_RESET_VALUE = 20'h0;
	parameter TCTRL_RESET_VALUE = 9'h0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH -1:0] aBus;
	inout [DBUS_WIDTH -1:0] dBus;
	input wrtEn;
	
	Register #(.BIT_WIDTH(32), .RESET_VALUE(RESET_VALUE)) tcnt (clk, reset, 1'b1, tcntIn, tcntOut);
	Register #(.BIT_WIDTH(32), .RESET_VALUE(RESET_VALUE)) tlim (clk, reset, 1'b1, tlimIn, tlimOut);
	Register #(.BIT_WIDTH(9), .RESET_VALUE(TCTRL_RESET_VALUE)) tctrl (clk, reset, 1'b1, tctrlIn, tctrlOut);
	
	reg ready = 1'b0;
	reg [19:0] internalcnt = INTERNAL_RESET_VALUE;
	reg [31:0] tcntIn = RESET_VALUE;
	wire [31:0] tcntOut;
	reg [31:0] tlimIn;
	wire [31:0] tlimOut;
	wire [8:0] tctrlIn;
	wire [8:0] tctrlOut;
	
	always @(*) begin
		if (aBus == 32'hF0000020 && !wrtEn)	//Read from Keys
			tctrl[0] = 1'b0;
		else if (aBus == 32'hF0000120 && wrtEn) begin
			if (dBus[0] == 0) begin
				tctrl[0] = 1'b0;
			end
			if (dBus[2] == 0) begin
				tctrl[2] = 1'b0;
			end
			tctrl[8] = tctrl[8];
		end	
		else if(ready) begin				//Keys has changed
			tctrl[2] = 1'b1&tctrl[0];
			tctrl[0] = 1'b1;
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			internalcnt <= INTERNAL_RESET_VALUE;
			tcntIn <= RESET_VALUE;
			tlimIn <= RESET_VALUE;
			ready <= 1'b0;
		end
		else begin
			if (aBus == 32'hF0000020 && wrtEn) begin
				internalcnt <= INTERNAL_RESET_VALUE;
				tcntIn <= dBus;
			end
			else if (internalcnt == 500000) begin
				internalcnt <= INTERNAL_RESET_VALUE;
				if ((tcntOut == (tlimOut - 1)) && (tlimOut != 32'b0)) begin
					tcntIn <= RESET_VALUE;
					ready <= 1'b1;
				end
				else begin
					tcntIn <= tcntIn + 32'h1;
				end
			end
			else begin
				internalcnt <= internalcnt + 20'h1;
			end
			
			if (aBus == 32'hF0000024 && wrtEn) begin
				tlimIn <= dBus;
			end
			
			if (ready) begin
				ready <= 1'b0;
			end
		end
	end
	
	assign dBus = 	(aBus == 32'hF0000020 && !wrtEn) ? tcntOut :
						(aBus == 32'hF0000024 && !wrtEn) ? tlimOut :
						(aBus == 32'hF0000120 && !wrtEn) ? {23'b0, tctrlOut} :
						32'bz;
	
endmodule
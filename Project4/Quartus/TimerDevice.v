module Timer(clk, reset, aBus, dBus, wrtEn);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;

	parameter TCTRL_RESET_VALUE = 9'h0;
	parameter CNT_RESET_VALUE = 32'b0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH - 1:0] aBus;
	inout [DBUS_WIDTH - 1:0] dBus;
	input wrtEn;
	
	wire writeCnt;
	assign writeCnt = (aBus == 32'hF0000020 && wrtEn);
	wire writeLim;
	assign writeLim = (aBus == 32'hF0000024 && wrtEn);
	wire writeCtrl;
	assign writeCtrl = (aBus == 32'hF0000120 && wrtEn);
	wire timerIncrement;
	assign timerIncrement = ((tcnt == tlim - 1) && (tlim != 32'b0) && (internalcnt == 50000));

	reg [31:0] tcnt = CNT_RESET_VALUE;
	reg [31:0] tlim = CNT_RESET_VALUE;
	reg [8:0] tctrl = TCTRL_RESET_VALUE;
	reg [32:0] internalcnt = CNT_RESET_VALUE;
	
	always @(posedge clk) begin
		if (reset == 1'b1) begin
			tcnt <= CNT_RESET_VALUE;
			tlim <= CNT_RESET_VALUE;
			tctrl <= TCTRL_RESET_VALUE;
			internalcnt <= CNT_RESET_VALUE;
		end
		else begin
			//for ready bit
			if (writeCtrl == 1'b1) begin
				if (dBus[0] == 1'b0) begin
					tctrl[0] <= dBus[0];
				end
			end
			else if (timerIncrement) begin
				tctrl[0] <= 1'b1;
			end
			
			//for overflow bit
			if (writeCtrl == 1'b1) begin
				if (dBus[2] == 1'b0) begin
					tctrl[2] <= dBus[2];
				end
			end
			else if (timerIncrement && tctrl[0] == 1'b1) begin
				tctrl[2] <= 1'b1;
			end
			
			//for interrupt enable
			if (writeCtrl == 1'b1) begin
				tctrl[8] <= dBus[8];
			end
			
			if (writeCnt == 1'b1) begin
				tcnt <= dBus;
			end 
			
			if (writeLim == 1'b1) begin
				tlim <= dBus;
			end
			
			if (internalcnt == 50000) begin
				if (timerIncrement) begin
					tcnt <= CNT_RESET_VALUE;
				end
				else begin
					tcnt <= tcnt + 32'b1;
				end
				internalcnt <= CNT_RESET_VALUE;
			end
			else begin
				tcnt <= tcnt;
				internalcnt <= internalcnt + 32'b1;
			end
		end
	end
	
	assign dBus = 	(aBus == 32'hF0000020 && !wrtEn) ? tcnt :
						(aBus == 32'hF0000024 && !wrtEn) ? tlim :
						(aBus == 32'hF0000120 && !wrtEn) ? {23'b0, tctrl} :
						32'bz;
endmodule

module Timer2(clk, reset, aBus, dBus, wrtEn);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;

	parameter TCTL_RESET_VALUE = 9'h0;
	parameter CNT_RESET_VALUE = 32'b0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH - 1:0] aBus;
	inout [DBUS_WIDTH - 1:0] dBus;
	input wrtEn;

	wire AddrCnt = (aBus == 32'hF0000020);
	wire AddrLim = (aBus == 32'hF0000024);
	wire AddrCtl =(aBus == 32'hF0000120);

	reg [31:0] tcnt = CNT_RESET_VALUE;
	reg [31:0] tlim = CNT_RESET_VALUE;
	reg [8:0] tctl = TCTL_RESET_VALUE;
	
	always@(posedge clk)begin
		if(AddrCnt && wrtEn)begin
			tcnt = dBus;
		end
		else begin
			tcnt = tcnt + 1;
			if(AddrLim && wrtEn)
				tlim = dBus;
			else if(AddrCtl && wrtEn)begin
				if(dBus[0] == 1'b0)
					tctl[0] =  1'b0;
				if(dBus[2] == 1'b0)
					tctl[2] = 1'b0;
				else
					tctl = tctl;
			end
			else begin
				tctl = tctl;
				tlim = tlim;
			end
			
		end
		if(tlim != 0) begin
			if(tcnt == tlim-1)begin
				tcnt = 32'd0;
				tctl[2] = 1'b1 & tctl[0];
				tctl[0] = 1'b1;
			end
		end
	end
	
	assign dBus = 	(AddrCnt && !wrtEn) ? tcnt :
						(AddrLim	&& !wrtEn) ? tlim :
						(AddrCtl && !wrtEn) ? tctl :
						32'bz;
	
endmodule

module Timer(clk, reset, aBus, dBus, wrtEn, IRQ);
	parameter ABUS_WIDTH = 32;
	parameter DBUS_WIDTH = 32;

	parameter TCTL_RESET_VALUE = 9'h0;
	parameter CNT_RESET_VALUE = 32'b0;
	
	input clk;
	input reset;
	input [ABUS_WIDTH - 1:0] aBus;
	inout [DBUS_WIDTH - 1:0] dBus;
	input wrtEn;
	output IRQ;
	wire AddrCnt = (aBus == 32'hF0000020);
	wire AddrLim = (aBus == 32'hF0000024);
	wire AddrCtl = (aBus == 32'hF0000120);

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
				tlim = tlim;
			end
			
		end
		if(tlim != 0) begin
			if(tcnt >= tlim-1)begin
				tcnt = 32'd0;
				tctl[2] = 1'b1 & tctl[0];
				tctl[0] = 1'b1;
			end
		end
	end
	
	assign dBus = 	(AddrCnt && !wrtEn) ? tcnt :
						(AddrLim	&& !wrtEn) ? tlim :
						(AddrCtl && !wrtEn) ? {23'b0, tctl} :
						32'bz;
						
	assign IRQ = (tctl[0]);
	
endmodule

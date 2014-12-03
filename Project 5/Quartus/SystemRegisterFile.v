module SystemRegisterFile (clk, isSpecial, opcode, nxtPc, irq, idn, rdindex, wrtindex, dataIn, pcAddrOut, spRegOut, ieOut, pcIntrSel);
	parameter INDEX_BIT_WIDTH = 4;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_REGS = (1 << INDEX_BIT_WIDTH);
	
	//Registers
	parameter PCS = 4'h0;
	parameter IHA = 4'h1;
	parameter IRA = 4'h2;
	parameter IDN = 4'h3;
	
	input clk;
	input isSpecial;
	input [4:0] opcode;
	input [31:0] nxtPc;
	input irq;
	input [3:0] idn;
	input [3:0] rdindex, wrtindex;
	input [31:0] dataIn;
	output [31:0] pcAddrOut;
	output [31:0] spRegOut;
	output ieOut, pcIntrSel;
	
	reg[DATA_BIT_WIDTH - 1: 0] data [0:N_REGS-1];
		
	always @(posedge clk) begin
		if (irq) begin
			//Interrupt requested
			data[IDN] <= idn;
			if(data[PCS][0])begin
				data[PCS][1] <= data[PCS][0];
				data[PCS][0] <= 1'b0;
				data[IRA] <= nxtPc;
			end
		end
		else begin
			if (isSpecial && opcode[3:0] == 4'h1) begin
				//RETI
				//update PCS (restore interrupts)
				data[PCS][0] <= data[PCS][1];
			end
			if (isSpecial && opcode[3:0] == 4'h3) begin
				//WSR
				data[wrtindex] <= dataIn;
			end
		end
	end
	
	assign pcAddrOut = (data[PCS][0] & irq) ? data[IHA]:
														   data[IRA];
	assign pcIntrSel = ((PCS[0] & irq == 1'b1) || (isSpecial && opcode[3:0] == 4'h1));
	assign spRegOut = data[rdindex];
	assign ieOut = data[PCS][0];
	
endmodule
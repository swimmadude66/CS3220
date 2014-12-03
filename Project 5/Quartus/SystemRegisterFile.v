module SystemRegisterFile (clk, isSpecial, opcode, nxtPc, irq, idn, rdindex, wrtindex, dataIn, pcAddrOut, spRegOut, ieOut, pcIntrSel);
	parameter INDEX_BIT_WIDTH = 4;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_REGS = (1 << INDEX_BIT_WIDTH);
	
	//Registers
	parameter PCS = 4'h0;
	parameter IHA = 4'h1;
	parameter IRA = 4'h2;
	parameter IDN = 4'h3;
	
	input clk, isSpecial, irq;
	input [4:0] opcode;
	input [31:0] nxtPc, dataIn;
	input [3:0] idn, rdindex, wrtindex;
	output [31:0] pcAddrOut, spRegOut;
	output ieOut, pcIntrSel;
	
	reg[DATA_BIT_WIDTH - 1: 0] data [0:N_REGS];
	
	initial begin
		data[PCS][0] = 1'b1;
	end
	
	always @(posedge clk) begin
		if (data[PCS][0]&irq) begin
			//Interrupt requested
			data[IDN] <= idn;
			data[PCS][1] <= data[PCS][0];
			data[PCS][0] <= 1'b0;
			data[IRA] <= nxtPc;
		end
		else begin
			if (isSpecial && (opcode[3:0] == 4'h1)) begin
				//RETI
				//update PCS (restore interrupts)
				data[PCS][0] <= data[PCS][1];
			end
			if (isSpecial && (opcode[3:0] == 4'h3)) begin
				//WSR
				data[wrtindex] <= dataIn;
			end
		end
	end
	
	assign pcAddrOut = (data[PCS][0] & irq) ? data[IHA]:
														   data[IRA];
	assign pcIntrSel = ((data[PCS][0] & irq) || (isSpecial && (opcode[3:0] == 4'h1)));
	assign spRegOut = data[rdindex];
	assign ieOut = data[PCS][0];
endmodule

module SystemRegisterFile2 (clk, isSpecial, opcode, nxtPc, irq, idn, rdindex, wrtindex, dataIn, pcAddrOut, spRegOut, ieOut, pcIntrSel);
	input clk, isSpecial, irq;
	input [4:0] opcode;
	input [31:0] nxtPc, dataIn;
	input [3:0] idn, rdindex, wrtindex;
	output [31:0] pcAddrOut, spRegOut;
	output ieOut, pcIntrSel;
	reg[31:0] PCS = 32'd1;
	reg[31:0] IHA, IRA, IDN, spRegOut;
	
	always @(posedge clk)begin
		if(PCS[0] & irq)begin
			IDN = idn;
			PCS[1] = PCS[0];
			PCS[0] = 1'b0;
			IRA = nxtPc;
		end
		else if(isSpecial) begin
			if(opcode[3:0] == 4'h3)begin
				case(wrtindex)
					4'h0:
						PCS = dataIn;
					4'h1:
						IHA = dataIn;
					4'h2:
						IRA = dataIn;
					4'h3:
						IDN = dataIn;
					default;
				endcase
			end
			else if(opcode[3:0] == 4'h2)begin
				spRegOut =	(rdindex == 4'h0) ? PCS :
								(rdindex == 4'h1) ? IHA :
								(rdindex == 4'h2) ? IRA :
								(rdindex == 4'h3) ? IDN :
								32'b0;
			end
			else if(opcode[3:0] == 4'h1)begin
				PCS[0] = PCS[1];
			end
			else begin
				PCS = PCS;
				IHA = IHA;
				IRA = IRA;
				IDN = IDN;
			end
		end
		else begin
			PCS = PCS;
			IHA = IHA;
			IRA = IRA;
			IDN = IDN;
		end
	end
	
	
	assign pcAddrOut = (PCS[0] & irq) ? IHA: IRA;
	assign pcIntrSel = ((PCS[0] & irq) || (isSpecial && (opcode[3:0] == 4'h1)));
	assign ieOut = PCS[0];

endmodule


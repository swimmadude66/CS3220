module SystemRegisterFile (clk, isSpecial, opcode, nxtPc, irq, idn, index, dataIn, pcAddrOut, spRegOut, ieOut);
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
	input [4: 0] opcode;
	input [31: 0] nxtPc;
	input irq;
	input [3: 0] idn;
	input [3: 0] index;
	input [31: 0] dataIn;
	output [31: 0] pcAddrOut;
	output [31: 0] spRegOut;
	output ieOut;
	
	reg[DATA_BIT_WIDTH - 1: 0] data [0: N_REGS];
	
	always @(posedge clk) begin
		if (ieOut == 1'b1 && irq == 1'b1) begin
			//Interrupt
			data[IRA] <= nxtPc;
			data[IDN] <= idn;
			
			data[PCS][1] <= data[PCS][0];
			data[PCS][0] <= 1'b0;
		end
		else begin
			if (isSpecial && opcode[3:0] == 8'hF1) begin
				//update PCS (restore interrupts)
				data[PCS][0] <= data[PCS][1];
			end
			if (isSpecial && opcode[3:0] == 8'hF3) begin
				data[index] <= dataIn;
			end
		end
	end
	
	assign pcAddrOut = (ieOut == 1'b1 && irq == 1'b1) ? data[IHA]:
																	    data[IRA];
	assign dataOut = data[index];
	assign ieOut = data[PCS][0];
	
endmodule
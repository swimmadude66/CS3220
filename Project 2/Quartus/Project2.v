module Project2(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
  input  [9:0] SW;
  input  [3:0] KEY;
  input  CLOCK_50;
  output [9:0] LEDR;
  output [7:0] LEDG;
  output [6:0] HEX0,HEX1,HEX2,HEX3;
 
  parameter DBITS         				 = 32;
  parameter OPBITS						 = 8;
  parameter INST_SIZE      			 = 32'd4;
  parameter INST_BIT_WIDTH				 = 32;
  parameter START_PC       			 = 32'h40;
  parameter REG_INDEX_BIT_WIDTH 		 = 4;
  parameter ADDR_KEY  					 = 32'hF0000010;
  parameter ADDR_SW   					 = 32'hF0000014;
  parameter ADDR_HEX  					 = 32'hF0000000;
  parameter ADDR_LEDR 					 = 32'hF0000004;
  parameter ADDR_LEDG 					 = 32'hF0000008;
  
  parameter IMEM_INIT_FILE				 = "Sorter2.mif";
  parameter IMEM_ADDR_BIT_WIDTH 		 = 11;
  parameter IMEM_DATA_BIT_WIDTH 		 = INST_BIT_WIDTH;
  parameter IMEM_PC_BITS_HI     		 = IMEM_ADDR_BIT_WIDTH + 2;
  parameter IMEM_PC_BITS_LO     		 = 2;
  
  parameter DMEMADDRBITS 				 = 13;
  parameter DMEMWORDBITS				 = 2;
  parameter DMEMWORDS					 = 2048;
  
  parameter OP1_ALUR 					 = 4'b0000;
  parameter OP1_ALUI 					 = 4'b1000;
  parameter OP1_CMPR 					 = 4'b0010;
  parameter OP1_CMPI 					 = 4'b1010;
  parameter OP1_BCOND					 = 4'b0110;
  parameter OP1_SW   					 = 4'b0101;
  parameter OP1_LW   					 = 4'b1001;
  parameter OP1_JAL  					 = 4'b1011;
  
  // Add parameters for various secondary opcode values
  parameter OP2_0 						 = 4'b0000;
  parameter OP2_1 						 = 4'b0001;
  parameter OP2_2 						 = 4'b0010;
  parameter OP2_3 						 = 4'b0011;
  parameter OP2_8 						 = 4'b1000;
  parameter OP2_9 						 = 4'b1001;
  parameter OP2_10 						 = 4'b1010;
  parameter OP2_11 						 = 4'b1011;
  
  //Register definitions
  parameter REG_0							 = 4'b0000;
  parameter REG_1							 = 4'b0001;
  parameter REG_2							 = 4'b0010;
  parameter REG_3							 = 4'b0011;
  parameter REG_4							 = 4'b0100;
  parameter REG_5							 = 4'b0101;
  parameter REG_6							 = 4'b0110;
  parameter REG_7							 = 4'b0111;
  parameter REG_8							 = 4'b1000;
  parameter REG_9							 = 4'b1001;
  parameter REG_10						 = 4'b1010;
  parameter REG_11						 = 4'b1011;
  parameter REG_12						 = 4'b1100;
  parameter REG_13						 = 4'b1101;
  parameter REG_14						 = 4'b1110;
  parameter REG_15						 = 4'b1111;
  
  //PLL, clock genration, and reset generation
  wire clk, lock;
  //Pll pll(.inclk0(CLOCK_50), .c0(clk), .locked(lock));
  PLL	PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
  wire reset = ~lock;
  
  // Create PC and its logic
  //wire pcWrtEn = 1'b1;
  //wire[DBITS - 1: 0] pcIn; // Implement the logic that generates pcIn; you may change pcIn to reg if necessary
  //wire[DBITS - 1: 0] pcOut;
  // This PC instantiation is your starting point
  //Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, reset, pcWrtEn, pcIn, pcOut);

  // Creat instruction memeory
  wire[32:0] pcOut;
  wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;
  InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWord);
  
  // Put the code for getting opcode1, rd, rs, rt, imm, etc. here 
  wire[7:0] opcode;
  wire[3:0] rd, rs1, rs2;
  wire[15:0] imm;
  Control #(DBITS, OPBITS, REG_INDEX_BIT_WIDTH) control (instWord, opcode, rd, rs1, rs2, imm);
  
  // Create the registers
  
  // This comes from decoding logic
  // (reg becomes wire in non-edge always block)
  wire[32:0] aluOut, dmemOut, regout1, regout2;
  wire[2:0] pnz;
  
  PC #(.DBITS(DBITS), .OPBITS(OPBITS)) pc (imm, aluOut, pnz, opcode, pcOut);
  
  // Now instantiate the register file module
  RegFile # (.DBITS(DBITS),.ABITS(5)) regFile (rs1, regout1, rs2, regout2, rd, aluOut, dmemOut, opcode, clk);
  
  // Create ALU unit
  ALU #(DBITS, OPBITS) alu (opcode, regout1, regout2, imm, aluOut, pnz);

  // Put the code for data memory and I/O here
  DMem #(DBITS, IMEM_ADDR_BIT_WIDTH) dmem (aluOut, regout2, dmemOut, 0, clk);
  
  // KEYS, SWITCHES, HEXS, and LEDS are memeory mapped IO
    
endmodule

module RegFile(RADDR1,DOUT1,RADDR2,DOUT2,WADDR,aluIn,DmemIn,opcode,CLK);
  parameter DBITS; // Number of data bits
  parameter ABITS; // Number of address bits
  parameter WORDS = (1<<ABITS);
  parameter MFILE = "";
  reg [(DBITS-1):0] mem[(WORDS-1):0];
  input  [(ABITS-1):0] RADDR1,RADDR2,WADDR;
  input  [(DBITS-1):0] aluIn, DmemIn;
  input [7:0] opcode;
  output wire [(DBITS-1):0] DOUT1,DOUT2;
  input CLK;
  always @(posedge CLK)
    if(opcode[6] == 1'b0) begin 
      if(opcode[7:4] == 4'b1001) begin
		  mem[WADDR]=DmemIn;
		end
		else begin
		  mem[WADDR]=aluIn;
		end
	 end
  assign DOUT1=mem[RADDR1];
  assign DOUT2=mem[RADDR2];
endmodule

module DMem(ADDRIN, DATAIN, DATAOUT, WE, CLK);
  parameter DBITS; // Number of data bits
  parameter ABITS; // Number of address bits
  parameter WORDS = (1<<ABITS);
  parameter MFILE = "";
  reg [(DBITS-1):0] mem[(WORDS-1):0];
  input  [(ABITS-1):0] ADDRIN;
  input  [(DBITS-1):0] DATAIN;
  output wire [(DBITS-1):0] DATAOUT;
  input CLK,WE;
  always @(posedge CLK)
    if(WE)
      mem[ADDRIN]=DATAIN;
  assign DATAOUT=mem[ADDRIN];
endmodule

module ALU(opcode, AIn, BInReg, BInImm, aluOut, pnz);
  parameter DBITS;
  parameter OPBITS;
  
  parameter OP2_ADD 						 = 4'b0000;
  parameter OP2_SUB 						 = 4'b0001;
  parameter OP2_AND 						 = 4'b0010;
  parameter OP2_OR 						 = 4'b0011;
  parameter OP2_XOR						 = 4'b1000;
  parameter OP2_NAND						 = 4'b1001;
  parameter OP2_NOR 						 = 4'b1010;
  parameter OP2_NXOR						 = 4'b1011;
  
  input [(DBITS - 1):0] AIn, BInReg, BInImm;
  input [(OPBITS - 1): 0] opcode;
  reg BIn;
  output reg [(DBITS - 1): 0] aluOut;
  output reg [2: 0] pnz;
  always @(opcode or AIn or BInReg or BInImm) begin
    BIn = (opcode[OPBITS - 1] == 1) ? BInImm : BInReg;
	 if (opcode[OPBITS-3:4] == 2'b10)begin
		aluOut = (opcode[3:0] == 4'b0000) ? 0:
				   (opcode[3:0] == 4'b1000) ? 1:
														AIn - BIn;
	 end
	 else begin
		aluOut =  (opcode[3:0] == OP2_ADD)  ?   AIn  + BIn:
					 (opcode[3:0] == OP2_SUB)  ?   AIn  - BIn:
					 (opcode[3:0] == OP2_AND)  ?   AIn  & BIn:
					 (opcode[3:0] == OP2_OR)   ?   AIn  | BIn:
					 (opcode[3:0] == OP2_XOR)  ?   AIn  ^ BIn:
					 (opcode[3:0] == OP2_NAND) ? ~(AIn  & BIn):
					 (opcode[3:0] == OP2_NOR)  ? ~(AIn  | BIn):
															 AIn ~^ BIn;
	 end
    if (aluOut == 0) begin
		pnz = 3'b001;
	 end
	 else if (aluOut[31] == 1'b1) begin
	   pnz = 3'b010;
	 end
	 else if (aluOut[31] == 1'b0) begin
		pnz = 3'b100;
	 end
  end
endmodule

module PC(Imm, AluOut, pnz, opcode, pcOut);
  parameter ADDRBITS = 11;
  parameter DBITS;
  parameter OPBITS;
  parameter PC_START = 2'b10;

  input [(DBITS - 1):0] Imm, AluOut;
  input [(OPBITS - 1): 0] opcode;
  input[2:0] pnz;
  reg [ADDRBITS - 1: 0] pc = PC_START;
  output reg [(DBITS - 1): 0] pcOut;
  always @(opcode or Imm or AluOut) begin
	 if (opcode[6:5] == 2'b11) begin
		if (opcode[3]==1'b0) begin
			if(opcode[3:0] == 4'b0000) begin
				pcOut = pc + 1;
			end
			else if (opcode[1:0]  == 2'b01) begin
				pcOut = pnz[0] == 1'b1 ? pc + 1 + Imm:
												 pc + 1;
			end
			else if (opcode[1:0]  == 2'b10) begin
				pcOut = pnz[1] == 1'b1 ? pc + 1 + Imm:
												 pc + 1;
			end
			else if (opcode[1:0]  == 2'b11) begin
				pcOut = (pnz[0] == 1'b1 || pnz[1] == 1'b1) ? pc + 1 + Imm:
												 pc + 1;
			end
		end
		else if (opcode[3] == 1'b1) begin
			if (opcode[3:0] == 4'b1000)begin
				pcOut = pc + 1 + Imm;
			end
			else if (opcode[1:0]  == 2'b01) begin
				pcOut = pnz[0] == 1'b1 ? pc + 1:
												 pc + 1 + Imm;
			end
			else if (opcode[1:0]  == 2'b10) begin
				pcOut = (pnz[0] == 1'b1 || pnz[2] == 1'b1) ? pc + 1 + Imm:
												 pc + 1;
			end
			else if (opcode[1:0]  == 2'b11) begin
				pcOut = pnz[2] == 1'b1 ? pc + 1 + Imm:
												 pc + 1;
			end
		end
		
	 end
	 else if (opcode[5:4] == 2'b11) begin
	   pcOut = pc + 1 + AluOut;
	 end
	 else begin
		pcOut = pc + 1;
	 end
  end
endmodule


module Project2(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
  input  [9:0] SW;
  input  [3:0] KEY;
  input  CLOCK_50;
  output [9:0] LEDR;
  output [7:0] LEDG;
  output [6:0] HEX0,HEX1,HEX2,HEX3;
 
  parameter DBITS         				 = 32;
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
  wire pcWrtEn = 1'b1;
  wire[DBITS - 1: 0] pcIn; // Implement the logic that generates pcIn; you may change pcIn to reg if necessary
  wire[DBITS - 1: 0] pcOut;
  // This PC instantiation is your starting point
  Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, reset, pcWrtEn, pcIn, pcOut);

  // Creat instruction memeory
  wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;
  InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWord);
  
  // Put the code for getting opcode1, rd, rs, rt, imm, etc. here 
  wire opcode1 = instWord[31: 28];
  wire opcode2 = instWord[27: 24];
  wire rd = instWord[23 : 20];
  wire rs1;
  assign rs1 = (instWord[30] == 1'b1) ? instWord[23: 20]:
												    instWord[19: 16];
  wire rs2;
  assign rs2 = (instWord[31:30] == 2'b0) ? instWord[23: 20]:
					(instWord[31:30] == 2'b0  &&
					 instWord[26] == 1'b0)	  ? instWord[19: 16]:
																		  4'b0;
  wire imm;
  assign imm = (instWord[31:30] == 2'b10  ||
					 instWord[31:30] == 2'b01) ? instWord[15: 0]:
																		16'b0;
  
  // Create the registers
  wire [3:0] rregno1=rs1, rregno2=rs2;
  wire [(DBITS-1):0] regout1,regout2;
  wire [3:0] wregno=rd;
  // This comes from decoding logic
  // (reg becomes wire in non-edge always block)
  reg wrreg;
  reg [(DBITS-1):0] wregval;
  // Now instantiate the register file module
  RegFile # (.DBITS(DBITS),.ABITS(5)) regFile (
			    rregno1, regout1, rregno2, regout2,
			    wregno, wregval, wrreg, clk);
  
  // Create ALU unit
  always @(negedge clk) begin
	 
	 
  end
  // Put the code for data memory and I/O here
  
  // KEYS, SWITCHES, HEXS, and LEDS are memeory mapped IO
    
endmodule

module RegFile(RADDR1,DOUT1,RADDR2,DOUT2,WADDR,DIN,WE,CLK);
  parameter DBITS; // Number of data bits
  parameter ABITS; // Number of address bits
  parameter WORDS = (1<<ABITS);
  parameter MFILE = "";
  reg [(DBITS-1):0] mem[(WORDS-1):0];
  input  [(ABITS-1):0] RADDR1,RADDR2,WADDR;
  input  [(DBITS-1):0] DIN;
  output wire [(DBITS-1):0] DOUT1,DOUT2;
  input CLK,WE;
  always @(posedge CLK)
    if(WE)
      mem[WADDR]=DIN;
  assign DOUT1=mem[RADDR1];
  assign DOUT2=mem[RADDR2];
endmodule

module ALU(opcode, aluIn1, aluIn2, aluOut);
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
  
  input [(DBITS - 1):0] aluIn1, aluIn2;
  input [(OPBITS - 1): 0] opcode; 
  output reg [(DBITS - 1): 0] aluOut;
  always @(opcode or aluIn1 or aluIn2) begin
    aluOut = (opcode == OP2_ADD)  ?   aluIn1  + aluIn2:
				 (opcode == OP2_SUB)  ?   aluIn1  - aluIn2:
				 (opcode == OP2_AND)  ?   aluIn1  & aluIn2:
				 (opcode == OP2_OR)   ?   aluIn1  | aluIn2:
				 (opcode == OP2_XOR)  ?   aluIn1  ^ aluIn2:
				 (opcode == OP2_NAND) ? ~(aluIn1  & aluIn2):
				 (opcode == OP2_NOR)  ? ~(aluIn1  | aluIn2):
									           aluIn1 ~^ aluIn2;
  end
endmodule


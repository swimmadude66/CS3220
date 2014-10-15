module Control(instr, opcode, rd, rs1, rs2, Imm);
  parameter DBITS;
  parameter OPBITS;
  parameter REGBITS;
  
  input [(DBITS - 1):0] instr;
  reg BIn;
  output reg [(OPBITS - 1): 0] opcode;
  output reg [(REGBITS - 1): 0] rd, rs1, rs2;
  output reg [(DBITS - 1): 0] Imm;
  always @(instr) begin
    opcode = instr[31: 24];
    rd = instr[23 : 20];
    rs1 = (instr[30] == 1'b1) ? instr[23: 20]:
										  instr[19: 16];
  
    rs2 = (instr[31:30] == 2'b0) ? instr[23: 20]:
		    (instr[31:30] == 2'b0  &&
			  instr[26] == 1'b0)	   ? instr[19: 16]:
														  4'b0;
  
    Imm = (instr[31:30] == 2'b10  ||
			  instr[31:30] == 2'b01) ? instr[15: 0]:
														 16'b0;
  end
endmodule

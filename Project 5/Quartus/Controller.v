module Controller (inst, aluCmpIn, bubble, sndOpcode, dRegAddr, s1RegAddr, s2RegAddr, imm, regFileWrtEn, immSel, memOutSel, pcSel, isLoad, isStore, isSpecial);
	
	parameter INST_BIT_WIDTH = 32;
	
	// inputs
	input [INST_BIT_WIDTH-1:0] inst;
	input aluCmpIn;
	input bubble;
	
	// output opcodes
	output reg [4: 0] sndOpcode;
	
	// register addresses
	output reg [3: 0] dRegAddr;
	output reg [3: 0] s1RegAddr;
	output reg [3: 0] s2RegAddr;
	
	// immediate value
	output reg [15: 0] imm;
	
	// control signals
	output reg regFileWrtEn, isLoad, isStore, isSpecial;
	output reg immSel;  
	output reg [1:0] memOutSel;
	output reg [1:0] pcSel;
	
	reg rfwe, iL, iS, specialReg;
	reg[1:0] pcs;
	
	always @(*)
	begin
		case(inst[31:28])
		4'b0000:begin // arithmetic
								sndOpcode 		<= {1'b0, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= inst[15:12];
								imm 		 		<= 16'd0;
								immSel			<= 1'b0; // doesn't matter
								memOutSel		<= 2'b00; // doesn't matter
								pcs 				<= 2'b00; // pc + 4
								rfwe 				<= 1'b1; // write to register
								iL		 			<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
							end
		4'b1000:begin // immediate arithmetic
								sndOpcode 		<= {1'b0, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0];
								immSel			<= 1'b1; // get the data from immediate
								memOutSel		<= 2'b00; // doesn't matter
								pcs 				<= 2'b00; // pc + 4
								rfwe 				<= 1'b1; // write to register
								iL 				<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
							end
		4'b0010:begin // comparison
								sndOpcode 		<= {1'b1, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= inst[15:12];
								imm 		 		<= 16'd0;
								rfwe 				<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // doesn't matter
								memOutSel		<= 2'b00; // doesn't matter
								pcs 				<= 2'b00; // pc + 4
								iL 				<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
							end
							
		4'b1010:begin // immediate comparison
								sndOpcode 		<= {1'b1, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0];
								rfwe 				<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b1; // get the data from immediate
								memOutSel		<= 2'b00; // doesn't matter
								pcs 				<= 2'b00; // pc + 4
								iL 				<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
							end
		4'b0110:begin // compare and branch
								sndOpcode 		<= {1'b1, inst[27:24]};
								dRegAddr  		<= 4'd0;
								s1RegAddr 		<= inst[23:20];
								s2RegAddr 		<= inst[19:16];
								imm 		 		<= inst[15:0]; // relative pc
								rfwe 	<= 1'b0; // no write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // relative pc
								memOutSel		<= 2'b00; // doesn't matter
								if(aluCmpIn)
									pcs 			<= 2'b01; // branch
								else
									pcs	  		<= 2'b00; // do not branch
								iL 				<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
							end
		4'b1001:begin // load instruction
								sndOpcode 		<= 5'b00000;
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0]; // relative pc
								rfwe 				<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b1; // relative pc
								memOutSel		<= 2'b01; // load data from memory
								pcs 				<= 2'b00; // pc + 4
								iL 				<= 1'b1;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
							end
		4'b0101:begin // store instruction
								sndOpcode 		<= 5'b00000;
								dRegAddr  		<= 4'd0;
								s1RegAddr 		<= inst[23:20];
								s2RegAddr 		<= inst[19:16];
								imm 		 		<= inst[15:0]; // relative pc
								rfwe 				<= 1'b0; // no write to register
								//dataWrtEn 		<= 1'b1; // write to data memory
								immSel			<= 1'b1; // relative pc
								memOutSel		<= 2'b00; // load data from memory
								pcs 				<= 2'b00; // pc + 4
								iL 				<= 1'b0;
								iS 				<= 1'b1;
								specialReg		<= 1'b0;
							end
		4'b1011:begin // JAL instruction
								sndOpcode 		<= 5'b00000; // addition
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0] << 2; // relative pc
								rfwe 				<= 1'b1; // no write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b1; // relative pc
								memOutSel		<= 2'b10; // load data from memory
								pcs 				<= 2'b10; // pc + 4
								iL 				<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
							end
		4'b1111:begin	//specialRegister access
								sndOpcode 		<= {1'b0, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= 4'd0;
								s2RegAddr 		<= inst[19:16];
								imm 		 		<= 16'd0;
								rfwe 				<= (inst[27:24] == 4'h2) ? 1'b1 : 1'b0;
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // relative pc
								memOutSel		<= (inst[27:24] == 4'h2) ? 2'b11 : 2'b00;
								pcs 				<= 2'b00;
								iL 				<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b1;
							end
							
		default:begin
								sndOpcode 		<= 5'd0;
								dRegAddr  		<= 4'd0;
								s1RegAddr 		<= 4'd0;
								s2RegAddr 		<= 4'd0;
								imm 		 		<= 16'd0; // relative pc
								rfwe 				<= 1'b0; // no write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // relative pc
								memOutSel		<= 2'b00; // load data from memory
								pcs 				<= 2'b00; // pc + 4
								iL 				<= 1'b0;
								iS 				<= 1'b0;
								specialReg		<= 1'b0;
					end
		endcase
		if(bubble)begin
			regFileWrtEn 	<=	1'b0;
			isLoad			<= 1'b0;
			isStore			<= 1'b0;
			pcSel				<= 2'b11;
			isSpecial		<= 1'b0;
		end
		else begin
			regFileWrtEn 	<=	rfwe;
			isLoad			<= iL;
			isStore			<= iS;
			pcSel				<= pcs;
			isSpecial		<= specialReg;
		end
	end
endmodule
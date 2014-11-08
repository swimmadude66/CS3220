module Controller (clk, inst,sndOpcode, dRegAddr, s1RegAddr, s2RegAddr, imm, regFileWrtEn, s1Sel, s2Sel, memOutSel, isLoad, isStore, isBranch, isJAL);
	
	parameter INST_BIT_WIDTH = 32;
	
	// inputs
	input [INST_BIT_WIDTH-1:0] inst;
	input clk;
	// intermediate values
	reg immSel;
	reg prevWrt = 1'b0;
	reg s2used = 1'b0;
	
	// output opcodes
	output reg [4: 0] sndOpcode;
	
	// register addresses
	reg[3: 0] prevDRegAddr;
	output reg [3: 0] dRegAddr;
	output reg [3: 0] s1RegAddr;
	output reg [3: 0] s2RegAddr;
	
	// immediate value
	output reg [15: 0] imm;
	
	// control signals
	output reg regFileWrtEn;
	output reg s1Sel = 1'b0;
	output reg [1:0] s2Sel = 2'b0;
	output reg [1:0] memOutSel;
	output reg isLoad, isStore, isBranch, isJAL;
	
	always @(*)
	begin
		case(inst[31:28])
		4'b0000:begin // arithmetic
								sndOpcode 		<= {1'b0, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= inst[15:12];
								imm 		 		<= 16'd0;
								regFileWrtEn 	<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // doesn't matter
								memOutSel		<= 2'b00; // doesn't matter
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b1;
							end
		4'b1000:begin // immediate arithmetic
								sndOpcode 		<= {1'b0, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0];
								regFileWrtEn 	<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b1; // get the data from immediate
								memOutSel		<= 2'b00; // doesn't matter
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b0;
							end
		4'b0010:begin // comparison
								sndOpcode 		<= {1'b1, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= inst[15:12];
								imm 		 		<= 16'd0;
								regFileWrtEn 	<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // doesn't matter
								memOutSel		<= 2'b00; // doesn't matter
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b1;
							end
							
		4'b1010:begin // immediate comparison
								sndOpcode 		<= {1'b1, inst[27:24]};
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0];
								regFileWrtEn 	<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b1; // get the data from immediate
								memOutSel		<= 2'b00; // doesn't matter
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b0;
							end
		4'b0110:begin // compare and branch
								sndOpcode 		<= {1'b1, inst[27:24]};
								dRegAddr  		<= 4'd0;
								s1RegAddr 		<= inst[23:20];
								s2RegAddr 		<= inst[19:16];
								imm 		 		<= inst[15:0]; // relative pc
								regFileWrtEn 	<= 1'b0; // no write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // relative pc
								memOutSel		<= 2'b00; // doesn't matter
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b1;
								isJAL				<= 1'b0;
								if (inst[26] == 1'b1) begin
									s2used			 = 1'b0;
								end
								else begin
									s2used			 = 1'b1;
								end
							end
		4'b1001:begin // load instruction
								sndOpcode 		<= 5'b00000;
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0]; // relative pc
								regFileWrtEn 	<= 1'b1; // write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b1; // relative pc
								memOutSel		<= 2'b01; // load data from memory
								isLoad 			<= 1'b1;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b0;
							end
		4'b0101:begin // store instruction
								sndOpcode 		<= 5'b00000;
								dRegAddr  		<= 4'd0;
								s1RegAddr 		<= inst[23:20];
								s2RegAddr 		<= inst[19:16];
								imm 		 		<= inst[15:0]; // relative pc
								regFileWrtEn 	<= 1'b0; // no write to register
								//dataWrtEn 		<= 1'b1; // write to data memory
								immSel			<= 1'b1; // relative pc
								memOutSel		<= 2'b00; // load data from memory
								isLoad 			<= 1'b0;
								isStore 			<= 1'b1;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b1;
							end
		4'b1011:begin // JAL instruction
								sndOpcode 		<= 5'b00000; // addition
								dRegAddr  		<= inst[23:20];
								s1RegAddr 		<= inst[19:16];
								s2RegAddr 		<= 4'd0;
								imm 		 		<= inst[15:0] << 2; // relative pc
								regFileWrtEn 	<= 1'b1; // no write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b1; // relative pc
								memOutSel		<= 2'b10; // load data from memory
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b1;
								s2used			 = 1'b0;
							end
		4'b1111:begin // NOOP
								sndOpcode 		<= 5'b11111;
								dRegAddr  		<= 4'd0;
								s1RegAddr 		<= 4'd0;
								s2RegAddr 		<= 4'd0;
								imm 		 		<= 15'd0; // relative pc
								regFileWrtEn 	<= 1'b0; // no write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // relative pc
								memOutSel		<= 2'b00; // load data from memory
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b0;
					end
		default:begin
								sndOpcode 		<= 5'd0;
								dRegAddr  		<= 4'd0;
								s1RegAddr 		<= 4'd0;
								s2RegAddr 		<= 4'd0;
								imm 		 		<= 15'd0; // relative pc
								regFileWrtEn 	<= 1'b0; // no write to register
								//dataWrtEn 		<= 1'b0; // no write to data memory
								immSel			<= 1'b0; // relative pc
								memOutSel		<= 2'b00; // load data from memory
								isLoad 			<= 1'b0;
								isStore 			<= 1'b0;
								isBranch			<= 1'b0;
								isJAL				<= 1'b0;
								s2used			 = 1'b0;
					end
				
		endcase
		if(prevWrt == 1'b1) begin        //hazard possible
			s1Sel = (prevDRegAddr == s1RegAddr)?    1'b1: //use forwarded
                                                 1'b0; //use register
         if (s2used == 1'b1) begin
				s2Sel = (prevDRegAddr == s2RegAddr)?     {1'b1, immSel}: //useforwarded
																	  {1'b0, immSel};
			end
			else begin
				s2Sel = {1'b0, immSel};
			end
		end
      else begin            //no hazards
			s1Sel = 1'b0; 
			s2Sel = {1'b0, immSel};
      end
    end
	 
    always @(posedge clk) begin
        prevDRegAddr = dRegAddr;
        prevWrt = regFileWrtEn;
	end
endmodule
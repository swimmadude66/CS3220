module PipeLineReg(clk, rst, nxtPC, memSel, regWrtEn, isLoad, isStore, isSpecial, destReg, srcReg, aluOut, datain, sndOpcode, 
memSelOut, aluOutOut, dataOut, isLoadOut, isStoreOut, isSpecialOut, nxtPCOut, regWrtEnOut, destRegOut, spRegAddr, intOp);

input clk, rst;
input regWrtEn, isLoad, isStore, isSpecial;
input[1:0] memSel;
input[3:0] destReg, srcReg;
input[4:0] sndOpcode;
input[31:0] nxtPC, aluOut, datain;

output reg regWrtEnOut, isLoadOut, isStoreOut, isSpecialOut;
output reg[1:0] memSelOut;
output reg[3:0] destRegOut,spRegAddr;
output reg[4:0] intOp;
output reg[31:0] nxtPCOut, aluOutOut, dataOut;

//reg regWrtEnOut, isLoadOut, isStoreOut;
//reg[1:0] memSelOut;
//reg[3:0] destRegOut;
//reg[31:0] nxtPCOut, aluOutOut, dataOut;

always @(posedge clk) begin
		if (rst == 1'b1)begin
			regWrtEnOut	<= 1'b0;
			isLoadOut	<= 1'b0;
			isStoreOut	<= 1'b0;
			isSpecialOut<= 1'b0;
			memSelOut	<= 2'b00;
			destRegOut	<= 4'h0;
			spRegAddr	<= 4'h0;
			nxtPCOut		<= 32'd0;
			aluOutOut	<= 32'd0;
			dataOut		<= 32'd0;
			intOp			<= 5'd0;
		end
		else begin
			regWrtEnOut	<= regWrtEn;
			isLoadOut	<= isLoad;
			isStoreOut	<= isStore;
			isSpecialOut<= isSpecial;
			memSelOut	<= memSel;
			destRegOut	<= destReg;
			spRegAddr	<= srcReg;
			nxtPCOut		<= nxtPC;
			aluOutOut	<= aluOut;
			dataOut		<= datain;
			intOp			<= sndOpcode;
		end
end	


endmodule
module PipeLineReg(clk, rst, nxtPC, memSel, regWrtEn, isLoad, isStore, destReg, aluOut, data2, memSelOut, aluOutOut, data2Out, isLoadOut, isStoreOut, nxtPCOut, regWrtEnOut, destRegOut);

input clk, rst;
input regWrtEn, isLoad, isStore;
input[1:0] memSel;
input[3:0] destReg;
input[31:0] nxtPC, aluOut, data2;

output regWrtEnOut, isLoadOut, isStoreOut;
output[1:0] memSelOut;
output[3:0] destRegOut;
output[31:0] nxtPCOut, aluOutOut, data2Out;

reg regWrtEnOut, isLoadOut, isStoreOut;
reg[1:0] memSelOut;
reg[3:0] destRegOut;
reg[31:0] nxtPCOut, aluOutOut, data2Out;

always @(posedge clk) begin
		if (rst == 1'b1)begin
			regWrtEnOut	<= 1'b0;
			isLoadOut	<= 1'b0;
			isStoreOut	<= 1'b0;
			memSelOut	<= 2'b00;
			destRegOut	<= 4'b0000;
			nxtPCOut		<= 32'd0;
			aluOutOut	<= 32'd0;
			data2Out		<= 32'd0;
		end
		else begin
			regWrtEnOut	<= regWrtEn;
			isLoadOut	<= isLoad;
			isStoreOut	<= isStore;
			memSelOut	<= memSel;
			destRegOut	<= destReg;
			nxtPCOut		<= nxtPC;
			aluOutOut	<= aluOut;
			data2Out		<= data2;
		end
end	


endmodule
/********************************************************************************************************************************************
Github repo : https://github.com/Praseeda-S/RISC-V-Soc.git
Date : 20/04/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Design and Verification of Vriddhi: A RISC-V Core
Design name : Execution unit
Module name : exe
Description : Performs operations and calculations on the operands obtained from register set based on the control signals from decoder unit
********************************************************************************************************************************************/

module exe #(parameter WIDTH=32)(
//input		clk,
input wire rstn,
input wire [31:0]imm,
input wire [1:0] alu_b,
input wire [1:0] alu_a,
input wire [3:0] alu_cntr,
input wire [31:0]Rd1,Rd2,
input wire [31:0]pc,
input wire [2:0] branch_cntr,
output     [31:0]alu_result,
output 		 ov_flag, z_flag,
output reg pcbranch
);
reg [31:0]b;
reg [31:0]a;



//---------------------------------------------------------------------

//SELECTION OF INPUT A


always@(*)
begin
if(~rstn)
begin
a<=32'b0;

end
else 
begin
case(alu_a)
	2'b01: a <= 32'h00000000;
	2'b10: a <= pc;
	2'b11: a <= Rd1;
	default: a <= Rd1;
endcase 
end
end
//-------------------------------------------------------------------

//SELECTION OF INPUT B


always@(*)
begin
if(~rstn)
begin
b<= 32'b0;

end
else 
begin
case(alu_b)
	2'b00: b <= Rd2;
	2'b01: b <= Rd2 & 32'h0000001F;
	2'b10: b <= imm;
	2'b11: b <= 32'h00000004;
	default: b <= Rd2;
endcase
end
end
//-----------------------------------------------------------------------




//ALU

alu #(	.WIDTH(WIDTH)
) 
alu_inst(	.alu_cntr(alu_cntr),
		.a(a),
		.b(b),
		.o_flag(ov_flag),
		.z_flag(z_flag),
		.rstn(rstn),
		.alu_result(alu_result)
);


//--------------------------------------------------------------------------------

// BRANCH CONTROL

always@(*)
begin
if(~rstn)
begin
pcbranch <= 1'b0;
end
else 
begin

	case(branch_cntr)
	3'b001:		pcbranch <= ({ov_flag,z_flag}==2'b01)? 1'b1:1'b0;	//---------beq	
	3'b010:		pcbranch <= (z_flag == 1'b0)? 1'b1:1'b0;		//---------bne
	3'b011:		pcbranch <= ({ov_flag,z_flag} == 2'b10)? 1'b1:1'b0;	//---------blt,bltu
	3'b100:		pcbranch <= (ov_flag ==1'b0)? 1'b1:1'b0;		//---------bge,bgeu
	default:	pcbranch <= 1'b0;	
	endcase
	end
end

endmodule

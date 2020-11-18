module exe #(parameter WIDTH=32)(
input wire [31:0]imm,
input wire [2:0]ALUb,
input wire [1:0]ALUa,
input wire [2:0]alu_cntr,
input wire [31:0]Rd1,Rd2,
input wire [31:0]pc,
input wire [2:0]branch_cntr,
output reg [31:0]alu_out,
output reg ov_flag, z_flag
output reg pcbranch
);
//-------------------------------------------------------------------

//SELECTION OF INPUT B

reg [31:0]b;

always@(*)
begin
case(ALUb[1:0])
	2'b00: b = Rd2;
	2'b01: b = Rd2 & 0x0000001F;
	2'b10: b = imm;
	2'b11: b = 0x00000004;
	default: b = Rd2;
endcase
end
//---------------------------------------------------------------------

//SELECTION OF INPUT A

reg [31:0]a;
 
always@(*)
begin
case(ALUa)
	2'b01: a = 0x00000000;
	2'b10: a = Pc;
	2'b11: a = Rd1;
	default: a = Rd1;
endcase 
end
//-----------------------------------------------------------------------

//ALU

alu #(	.WIDTH(WIDTH)
) 
alu_inst(	.alu_cntr(alu_cntr),
		.a(a),
		.b(b),
		.status[0](z_flag),
		.status[1](ov_flag),
		.alu_out(alu_out)
);

//--------------------------------------------------------------------------------

// BRANCH CONTROL

always@(*)
begin
	case(branch_cntr)
	3'b001:		pcbranch = ({ov_flag,z_flag}==2'b01)? 1'b1:1'b0;	//---------beq	
	3'b010:		pcbranch = (z_flag == 1'b0)? 1'b1:1'b0;		//---------bne
	3'b011:		pcbranch = ({ov_flag,z_flag}) == 2'b10)? 1'b1:1'b0;	//---------blt,bltu
	3'b100:		pcbranch = (ov_flag ==1'b0)? 1'b1:1'b0;		//---------bge,bgeu
	default:	pcbranch = 1'b0;	
	endcase
end

endmodule

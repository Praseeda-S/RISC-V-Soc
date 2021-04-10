module exe #(parameter WIDTH=32)(
input wire clk,
input wire [31:0]imm,
input wire [1:0] ALUb,
input wire [1:0] ALUa,
input wire [3:0] alu_cntr,
input wire [31:0]Rd1,Rd2,
input wire [31:0]pc,
input wire [2:0] branch_cntr,
output     [31:0]alu_result,
output 		 ov_flag, z_flag,
output reg pcbranch
);
//-------------------------------------------------------------------

//SELECTION OF INPUT B

reg [31:0]b;

always@(*)
begin
case(ALUb)
	2'b00: b <= Rd2;
	2'b01: b <= Rd2 & 32'h0000001F;
	2'b10: b <= imm;
	2'b11: b <= 32'h00000004;
	default: b <= Rd2;
endcase
end
//---------------------------------------------------------------------

//SELECTION OF INPUT A

reg [31:0]a;
 
always@(*)
begin
case(ALUa)
	2'b01: a <= 32'h00000000;
	2'b10: a <= pc;
	2'b11: a <= Rd1;
	default: a <= Rd1;
endcase 
end
//-----------------------------------------------------------------------


wire [1:0] flags;

//ALU

alu #(	.WIDTH(WIDTH)
) 
alu_inst(	.alu_cntr(alu_cntr),
		.a(a),
		.b(b),
		.status(flags),
		.alu_result(alu_result)
);


assign ov_flag = flags[1];
assign z_flag = flags[0];


//--------------------------------------------------------------------------------

// BRANCH CONTROL

always@(*)
begin
	case(branch_cntr)
	3'b001:		pcbranch <= ({ov_flag,z_flag}==2'b01)? 1'b1:1'b0;	//---------beq	
	3'b010:		pcbranch <= (z_flag == 1'b0)? 1'b1:1'b0;		//---------bne
	3'b011:		pcbranch <= ({ov_flag,z_flag} == 2'b10)? 1'b1:1'b0;	//---------blt,bltu
	3'b100:		pcbranch <= (ov_flag ==1'b0)? 1'b1:1'b0;		//---------bge,bgeu
	default:	pcbranch <= 1'b0;	
	endcase
end

endmodule

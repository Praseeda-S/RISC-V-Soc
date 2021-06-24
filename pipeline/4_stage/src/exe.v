module exe #(parameter WIDTH=32)(
input wire clk,
input      rstn,
input wire [31:0]imm,
input wire [1:0] ALUb,
input wire [1:0] ALUa,
input wire [3:0] alu_cntr,
input wire [31:0]Rd1,Rd2,
input wire [31:0]pc_id2exe,
input wire [2:0] branch_cntr,
input wire [1:0] Memtoreg_id2exe,
input wire [2:0] Ld_cntr_id2exe,
input wire [1:0] St_cntr_id2exe,
input wire       RegW_id2exe,
input wire [4:0] wr_addr_id2exe,
output reg    [31:0]alu_result,
output reg       ov_flag, 
output     z_flag, 
output reg pcbranch,
output reg [1:0] Memtoreg_exe2lsu,
output reg [2:0] Ld_cntr_exe2lsu,
output reg [1:0] St_cntr_exe2lsu,
output reg [31:0] Rd2_exe2lsu,
output reg RegW_exe2lsu,
output reg [4:0] wr_addr_exe2lsu
);
//-------------------------------------------------------------------



//ASSIGNING TO REGISTERS FOR PIPELINING

always@(posedge clk or negedge rstn)
begin

if (~rstn) begin
Memtoreg_exe2lsu <= 0;
Ld_cntr_exe2lsu  <= 0;
St_cntr_exe2lsu  <= 0;
ov_flag    <= 0;
alu_result <= 0;
Rd2_exe2lsu<= 0;
RegW_exe2lsu    <= 0;
wr_addr_exe2lsu <= 0;
end
 
else
begin
Memtoreg_exe2lsu <= Memtoreg_id2exe;
Ld_cntr_exe2lsu <=  Ld_cntr_id2exe;
St_cntr_exe2lsu <= St_cntr_id2exe;
ov_flag <= overflow;
alu_result <= result;
Rd2_exe2lsu <= Rd2;
RegW_exe2lsu <= RegW_id2exe;
wr_addr_exe2lsu <= wr_addr_id2exe;
end
end
//-------------------------------------------------------------------

//SELECTION OF INPUT B

reg [31:0]b;

always@(*)
begin
if (~rstn) b <= 0;

else
begin
case(ALUb)
	2'b00: b <= Rd2;
	2'b01: b <= Rd2 & 32'h0000001F;
	2'b10: b <= imm;
	2'b11: b <= 32'h00000004;
	default: b <= Rd2;
endcase
end
end
//---------------------------------------------------------------------

//SELECTION OF INPUT A

reg [31:0]a;
 
always@(*)
begin
if (~rstn) a <= 0;
else begin
case(ALUa)
	2'b01: a <= 32'h00000000;
	2'b10: a <= pc_id2exe;
	2'b11: a <= Rd1;
	default: a <= Rd1;
endcase 
end
end
//-----------------------------------------------------------------------


wire overflow;
wire z_flag;
wire [31:0] result;
//ALU

alu #(	.WIDTH(WIDTH)
) 
alu_inst(	.alu_cntr(alu_cntr),
		.a(a),
		.b(b),
		.o_flag(overflow),
		.z_flag(z_flag),
		.alu_result(result)
);


//--------------------------------------------------------------------------------

// BRANCH CONTROL

always@(posedge clk or negedge rstn)
begin

if (~rstn) pcbranch <= 0;

else begin
	case(branch_cntr)
	3'b001:		pcbranch <= ({overflow,z_flag}==2'b01)? 1'b1:1'b0;	//---------beq	
	3'b010:		pcbranch <= (z_flag == 1'b0)? 1'b1:1'b0;		//---------bne
	3'b011:		pcbranch <= ({overflow,z_flag} == 2'b10)? 1'b1:1'b0;	//---------blt,bltu
	3'b100:		pcbranch <= (overflow ==1'b0)? 1'b1:1'b0;		//---------bge,bgeu
	default:	pcbranch <= 1'b0;	
	endcase
end
end

endmodule

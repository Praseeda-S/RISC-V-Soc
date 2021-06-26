module riscv32b(
input clk,
input rstn,
output	[31:0]	instr_addr,
input 	[31:0]	instr_in,
output 	[31:0] 	data_addr,
output 	[3:0] 	datamem_wr,
input 	[31:0] 	data_in,
output 	[7:0] 	data_out0,
output 	[7:0] 	data_out1,
output 	[7:0] 	data_out2,
output 	[7:0] 	data_out3
);

// instruction parsing
wire [31:0] instr;
wire [31:0]data_out;
wire [4:0] reg_addr1 = instr[19:15];
wire [4:0] reg_addr2 = instr[24:20];
wire [4:0] reg_addr3 = instr[11:7];

// data parsing
assign data_out0 = data_out[7:0];
assign data_out1 = data_out[15:8];
assign data_out2 = data_out[23:16];
assign data_out3 = data_out[31:24];


wire reg_wr;
wire [31:0] memtoreg_data;
wire [31:0] rs1;
wire [31:0] rs2;

wire [31:0] alu_out;
wire alu_ov_flag;
wire alu_z_flag;

wire [31:0] imm_data;
wire pcbranch;
wire [31:0] pc;

// control signals
wire cpu_wait;
wire jal;
wire jalr;
wire [1:0] mem_to_reg;
wire [1:0] St_cntr;
wire [2:0] Ld_cntr;
wire [1:0] ALUa;
wire [1:0] ALUb;
wire [3:0] ALU_cntr;
wire [2:0] Branch_cntr;


registers regset(
.clk		(clk),
.rstn		(rstn),
.write		(reg_wr),
.rs1_addr	(reg_addr1),
.rs2_addr	(reg_addr2),
.w_addr		(reg_addr3),
.w_data		(memtoreg_data),
.rs1_out	(rs1),
.rs2_out	(rs2)
);

ifetch fetchunit(
.clk		(clk),
.rstn		(rstn),
.instr_addr_o	(instr_addr),
.rs1		(rs1),
.immediate	(imm_data),
.jal		(jal),
.jalr		(jalr),
.pcbranch	(pcbranch),
.instr_in	(instr_in),
.instr_reg	(instr),
.cpu_wait	(cpu_wait),
.pc_if2id	(pc)
);

idecode decodeunit(
.rstn		(rstn),
.hold		(cpu_wait),
.instr		(instr),
.reg_write	(reg_wr),
.memtoreg	(mem_to_reg),
.st_cntr	(St_cntr),
.ld_cntr	(Ld_cntr),
.alu_a		(ALUa),
.alu_b		(ALUb),
.alu_cntr	(ALU_cntr),
.imm		(imm_data),
.branch_cntr	(Branch_cntr),
.jal		(jal),
.jalr		(jalr)
);

exe	exeunit(
.rstn		(rstn),
.imm		(imm_data),
.ALUb		(ALUb),
.ALUa		(ALUa),
.alu_cntr	(ALU_cntr),
.Rd1		(rs1),
.Rd2		(rs2),
.pc		(pc),
.branch_cntr	(Branch_cntr),
.alu_result	(alu_out),
.ov_flag	(alu_ov_flag),
.z_flag		(alu_z_flag),
.pcbranch	(pcbranch)
);

lsu lsuunit(
.rstn		(rstn),
.alu_out	(alu_out),
.alu_ov_flag	(alu_ov_flag),
.data_addr	(data_addr),
.MemtoReg	(mem_to_reg),
.dmem_wr	(datamem_wr),
.reg_wrdata	(memtoreg_data),
.Ld_cntr	(Ld_cntr),
.St_cntr	(St_cntr),
.datamem_wr_in	(rs2),
.datamem_wr_o	(data_out),
.datamem_rd_in	(data_in)
);

endmodule

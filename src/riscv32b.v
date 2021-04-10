module riscv32b(
input clk,
input rstn,
output [31:0]instr_addr,
output instr_rd,
input [31:0] instr_in,
output [31:0] data_addr,
output datamem_rd,
output datamem_wr,
input [31:0] data_in,
output [31:0] data_out
);

// instruction parsing
wire [4:0] reg_addr1 = instr_in[19:15];
wire [4:0] reg_addr2 = instr_in[24:20];
wire [4:0] reg_addr3 = instr_in[11:7];


wire reg_wr;
wire [31:0] memtoreg_data;
wire [31:0] rs1;
wire [31:0] rs2;

wire [31:0] alu_out;
wire alu_ov_flag;
wire alu_z_flag;

wire [31:0] imm_data;
wire pcbranch;

// control signals
wire jal;
wire jalr;
wire mem_wr;
wire [1:0] mem_to_reg;
wire [31:0] St_cntr;
wire [1:0]Ld_cntr;
wire [1:0] ALUa;
wire [1:0] ALUb;
wire [3:0] ALU_cntr;
wire [2:0] Branch_cntr;

assign datamem_wr = mem_wr;


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
.pcbranch	(pcbranch)
);

idecode decodeunit(
.clk		(clk),
.instr		(instr_in),
.RegW		(reg_wr),
.MemW		(mem_wr),
.Memtoreg	(mem_to_reg),
.St_cntr	(St_cntr),
.Ld_cntr	(Ld_cntr),
.ALUa		(ALUa),
.ALUb		(ALUb),
.ALU_cntr	(ALU_cntr),
.imm		(imm_data),
.Branch_cntr	(Branch_cntr),
.Jal		(jal),
.Jalr		(jalr)
);

exe	exeunit(
.clk		(clk),
.imm		(imm_data),
.ALUb		(ALUb),
.ALUa		(ALUa),
.alu_cntr	(ALU_cntr),
.Rd1		(rs1),
.Rd2		(rs2),
.pc		(instr_addr),
.branch_cntr	(Branch_cntr),
.alu_result	(alu_out),
.ov_flag	(alu_ov_flag),
.z_flag		(alu_z_flag),
.pcbranch	(pcbranch)
);

lsu lsuunit(
.clk		(clk),
.alu_out	(alu_out),
.alu_ov_flag	(alu_ov_flag),
.data_addr	(data_addr),
.MemtoReg	(mem_to_reg),
.reg_wrdata	(memtoreg_data),
.Ld_cntr	(Ld_cntr),
.St_cntr	(St_cntr),
.datamem_wr_in	(rs2),
.datamem_wr_o	(data_out),
.datamem_rd_in	(data_in)
);

endmodule

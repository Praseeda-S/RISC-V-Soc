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
wire [4:0] reg_addr1 = instr[19:15];
wire [4:0] reg_addr2 = instr[24:20];
wire [4:0] reg_addr3 = instr[11:7];
wire [4:0] reg_addr31;
wire [4:0] reg_addr32;
wire [4:0] reg_addr33;

// data parsing
assign data_out0 = data_out[7:0];
assign data_out1 = data_out[15:8];
assign data_out2 = data_out[23:16];
assign data_out3 = data_out[31:24];


wire reg_wr;
wire [31:0] memtoreg_data;
wire [31:0] rs1;
wire [31:0] rs2;
wire [31:0] rs22;
wire reg_wr1, reg_wr2;

wire [31:0] alu_out;
wire alu_ov_flag;
wire alu_z_flag;

wire [31:0] imm_data;
wire pcbranch;

wire [31:0] pc;
wire [31:0] pc1;
wire [31:0] pc2;

// control signals
wire ide_wait;
wire exe_wait;
wire jal;
wire jalr;
wire [1:0] mem_to_reg;
wire [1:0] mem_to_reg2;
wire [1:0] St_cntr;
wire [2:0] Ld_cntr;
wire [1:0] St_cntr2;
wire [2:0] Ld_cntr2;
wire [1:0] ALUa;
wire [1:0] ALUb;
wire [3:0] ALU_cntr;
wire [2:0] Branch_cntr;

wire	   br_taken;
wire [31:0]target_addr;

wire [31:0]data_out;

// for data hazard 
wire [1:0]     rs1_hazard;
wire [1:0]     rs2_hazard;
wire [31:0]    rs1_input;
wire [31:0]    rs2_input;
wire [31:0]    result;
wire [31:0]    memtoreg_data_DH;



registers regset(
.clk			(clk),
.rstn			(rstn),
.write			(reg_wr2),
.rs1_addr		(reg_addr1),
.rs2_addr		(reg_addr2),
.w_addr			(reg_addr33),
.w_data			(memtoreg_data),
.rs1_out_id2exe		(rs1),
.rs2_out_id2exe		(rs2)
);

ifetch fetchunit(
.clk			(clk),
.rstn			(rstn),
.instr_addr_o		(instr_addr),
.rs1			(rs1),
.immediate		(imm_data),
.jal			(jal),
.jalr			(jalr),
.pcbranch		(pcbranch),
.instr_in		(instr_in),
.instr_reg		(instr),
.ide_wait		(ide_wait),
.exe_wait		(exe_wait),
.pc_if2id		(pc1),
.pc			(pc),
.Branch_cntr            (Branch_cntr),
.bpu_branch		(br_taken),
.bpu_addr		(target_addr)
);

idecode decodeunit(
.clk			(clk),
.ide_wait       	(ide_wait),
.instr			(instr),
.pc_if2id       	(pc1),
.wr_addr   		(reg_addr3),
.RegW			(reg_wr),
.Memtoreg		(mem_to_reg),
.St_cntr		(St_cntr),
.Ld_cntr		(Ld_cntr),
.ALUa			(ALUa),
.ALUb			(ALUb),
.ALU_cntr		(ALU_cntr),
.imm			(imm_data),
.Branch_cntr		(Branch_cntr),
.Jal			(jal),
.Jalr			(jalr),
.pc_id2exe     		(pc2),
.wr_addr_id2exe 	(reg_addr31)
);

exe	exeunit(
.clk			(clk),
.exe_wait		(exe_wait),
.imm			(imm_data),
.ALUb			(ALUb),
.ALUa			(ALUa),
.alu_cntr		(ALU_cntr),
.Rd1			(rs1_input),
.Rd2			(rs2_input),
.pc_id2exe      	(pc2),
.branch_cntr		(Branch_cntr),
.Memtoreg_id2exe 	(mem_to_reg),
.Ld_cntr_id2exe 	(Ld_cntr),
.St_cntr_id2exe 	(St_cntr),
.RegW_id2exe    	(reg_wr),
.wr_addr_id2exe  	(reg_addr31),
.alu_result		(alu_out),
.ov_flag		(alu_ov_flag),
.z_flag			(alu_z_flag),
.pcbranch		(pcbranch),
.Memtoreg_exe2lsu 	(mem_to_reg2),
.Ld_cntr_exe2lsu 	(Ld_cntr2),
.St_cntr_exe2lsu 	(St_cntr2),
.Rd2_exe2lsu     	(rs22),
.RegW_exe2lsu    	(reg_wr1),
.wr_addr_exe2lsu 	(reg_addr32)
);

lsu lsuunit(
.clk			(clk),
.alu_out_exe2lsu	(alu_out),
.alu_ov_flag_exe2lsu	(alu_ov_flag),
.data_addr		(data_addr),
.MemtoReg		(mem_to_reg2),
.dmem_wr		(datamem_wr),
.reg_wrdata		(memtoreg_data),
.Ld_cntr		(Ld_cntr2),
.St_cntr		(St_cntr2),
.datamem_wr_in		(rs22),
.datamem_wr_o		(data_out),
.datamem_rd_in		(data_in),
.RegW_exe2lsu   	(reg_wr1),
.RegW_lsu2reg   	(reg_wr2),
.wr_addr_exe2lsu 	(reg_addr32),
.wr_addr_lsu2reg 	(reg_addr33)
);

datahazard datahardunit(
.clk			(clk),
.reg_addr1		(reg_addr1),
.reg_addr2		(reg_addr2),
.reg_addr31		(reg_addr31),
.reg_addr33		(reg_addr33),
.reg_wr1		(reg_wr),
.reg_wr2		(reg_wr2),
.rs1_hazard		(rs1_hazard),
.rs2_hazard		(rs2_hazard),
.memtoreg_data		(memtoreg_data),
.memtoreg_data_DH       (memtoreg_data_DH)
);

forwarding forwardingunit(
.clk			(clk),
.memtoreg_data		(memtoreg_data_DH),
.rs1_hazard		(rs1_hazard),
.rs2_hazard		(rs2_hazard),
.result 		(alu_out),
.rs1			(rs1),
.rs2			(rs2),
.rs1_input		(rs1_input),
.rs2_input		(rs2_input)
);

BranchPrediction bpu(
.clk			(clk),
.rstn			(rstn),
.pcbranch		(pcbranch),
.pc			(pc),
.pc_id2exe		(pc2),
.imm 			(imm_data),
.Branch_cntr		(Branch_cntr),
.br_taken_reg		(br_taken),
.target_address_reg	(target_addr)
);

endmodule

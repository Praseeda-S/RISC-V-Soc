/********************************************************************************************************
Github repo : 313849252
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : RISC-V Core
Module name : riscv32b
Description : Houses the 5 blocks comprising the core 
********************************************************************************************************/

module riscv32b(
input clk,
input rstn,
input  [31:0] instr_in,
input  [31:0] data_in,
output [31:0] data_addr,
output [3:0]  datamem_wr,
output [31:0] instr_addr,
output [7:0]  data_out0,
output [7:0]  data_out1,
output [7:0]  data_out2,
output [7:0]  data_out3
);

// instruction parsing
wire [31:0]instr;
wire [6:0] opcode = instr[6:0];
wire [6:0] opcode_id2exe;
wire [6:0] opcode_exe2lsu;
wire [4:0] rs1_addr = instr[19:15];
wire [4:0] rs2_addr = instr[24:20];
wire [4:0] wr_addr = instr[11:7];
wire [4:0] wr_addr_id2exe;
wire [4:0] wr_addr_exe2lsu;
wire [4:0] wr_addr_lsu2reg;
wire [31:0]data_out;


// data parsing
assign data_out0 = data_out[7:0];
assign data_out1 = data_out[15:8];
assign data_out2 = data_out[23:16];
assign data_out3 = data_out[31:24];


wire [31:0] memtoreg_data;
wire [31:0] rs1;
wire [31:0] rs2;
wire [31:0] rs2_exe2lsu;
wire reg_wr1, reg_wr2;
wire reg_wr;

wire [31:0] alu_result;
wire alu_ov_flag;
wire alu_z_flag;

wire [31:0] imm_data;
wire pcbranch;

wire [31:0] pc;
wire [31:0] pc_if2id;
wire [31:0] pc_id2exe;

// control signals
wire ide_wait;
wire exe_wait;
wire jal;
wire jalr;
wire [1:0] mem_to_reg;
wire [1:0] mem_to_reg2;
wire [1:0] st_cntr;
wire [2:0] ld_cntr;
wire [1:0] st_cntr2;
wire [2:0] ld_cntr2;
wire [1:0] alu_a;
wire [1:0] alu_b;
wire [3:0] alu_cntr;
wire [2:0] branch_cntr;

wire br_taken;
wire [31:0]target_addr;


// for data hazard 
wire [31:0] w_data;
wire [1:0]  rs1_hazard;
wire [1:0]  rs2_hazard;
wire [31:0] rs1_fwd2exe;
wire [31:0] rs2_fwd2exe;
wire [31:0] result;
wire [31:0] memtoreg_data_DH;
wire store_load_hazard;



registers regset(
.clk            (clk),
.rstn           (rstn),
.write          (reg_wr2),
.rs1_addr       (rs1_addr),
.rs2_addr       (rs2_addr),
.w_addr         (wr_addr_lsu2reg),
.w_data         (w_data),
.rs1_out_id2exe (rs1),
.rs2_out_id2exe (rs2)
);

ifetch fetchunit(
.clk           (clk),
.rstn          (rstn),
.instr_addr_o  (instr_addr),
.rs1           (rs1),
.imm           (imm_data),
.jal           (jal),
.jalr          (jalr),
.pcbranch      (pcbranch),
.instr_in      (instr_in),
.instr_reg     (instr),
.ide_wait      (ide_wait),
.exe_wait      (exe_wait),
.pc_if2id      (pc_if2id),
.pc_if2bpu     (pc),
.branch_cntr   (branch_cntr),
.bpu_branch    (br_taken),
.bpu_addr      (target_addr)
);

idecode decodeunit(
.clk            (clk),
.rstn           (rstn),
.ide_wait       (ide_wait),
.instr          (instr),
.pc_if2id       (pc_if2id),
.wr_addr        (wr_addr),
.reg_write      (reg_wr),
.memtoreg_id2exe(mem_to_reg),
.opcode         (opcode),
.st_cntr_id2exe (st_cntr),
.ld_cntr_id2exe (ld_cntr),
.alu_a          (alu_a),
.alu_b          (alu_b),
.alu_cntr       (alu_cntr),
.imm            (imm_data),
.branch_cntr    (branch_cntr),
.jal            (jal),
.jalr           (jalr),
.pc_id2exe      (pc_id2exe),
.wr_addr_id2exe (wr_addr_id2exe),
.opcode_id2exe  (opcode_id2exe)
);

exe   exeunit(
.clk        (clk),
.rstn       (rstn),
.opcode_id2exe       (opcode_id2exe),
.opcode_exe2lsu      (opcode_exe2lsu),
.exe_wait            (exe_wait),
.imm                 (imm_data),
.alu_b               (alu_b),
.alu_a               (alu_a),
.alu_cntr            (alu_cntr),
.reg_source1         (rs1_fwd2exe),
.reg_source2         (rs2_fwd2exe),
.pc_id2exe           (pc_id2exe),
.branch_cntr         (branch_cntr),
.memtoreg_id2exe     (mem_to_reg),
.ld_cntr_id2exe      (ld_cntr),
.st_cntr_id2exe      (st_cntr),
.reg_write_id2exe    (reg_wr),
.wr_addr_id2exe      (wr_addr_id2exe),
.alu_result          (alu_result),
.ov_flag             (alu_ov_flag),
.z_flag              (alu_z_flag),
.pcbranch            (pcbranch),
.memtoreg_exe2lsu    (mem_to_reg2),
.ld_cntr_exe2lsu     (ld_cntr2),
.st_cntr_exe2lsu     (st_cntr2),
.reg_source2_exe2lsu (rs2_exe2lsu),
.reg_write_exe2lsu   (reg_wr1),
.wr_addr_exe2lsu     (wr_addr_exe2lsu)
);

lsu lsuunit(
.clk        (clk),
.alu_out_exe2lsu     (alu_result),
.alu_ov_flag_exe2lsu (alu_ov_flag),
.data_addr           (data_addr),
.memtoreg            (mem_to_reg2),
.dmem_wr             (datamem_wr),
.reg_wrdata          (memtoreg_data),
.ld_cntr             (ld_cntr2),
.st_cntr             (st_cntr2),
.datamem_wr_in       (rs2_exe2lsu),
.datamem_wr_o        (data_out),
.datamem_rd_in       (data_in),
.reg_write_exe2lsu   (reg_wr1),
.reg_write_lsu2reg   (reg_wr2),
.wr_addr_exe2lsu     (wr_addr_exe2lsu),
.wr_addr_lsu2reg     (wr_addr_lsu2reg)
);

datahazard datahardunit(
.clk               (clk),
.rstn              (rstn),
.rs1_addr          (rs1_addr),
.rs2_addr          (rs2_addr),
.wr_addr_id2exe    (wr_addr_id2exe),
.wr_addr_lsu2reg   (wr_addr_lsu2reg),
.reg_wr1           (reg_wr),
.reg_wr2           (reg_wr2),
.St_cntr           (st_cntr2),
.ALU_result        (alu_result),
.opcode            (opcode_exe2lsu),
.rs1_hazard        (rs1_hazard),
.rs2_hazard        (rs2_hazard),
.memtoreg_data     (memtoreg_data),
.memtoreg_data_DH  (memtoreg_data_DH),
.store_load_hazard (store_load_hazard)
);

forwarding forwardingunit(
.clk               (clk),
.rstn              (rstn),
.memtoreg_data     (memtoreg_data_DH),
.rs1_hazard        (rs1_hazard),
.rs2_hazard        (rs2_hazard),
.alu_result        (alu_result),
.rs1               (rs1),
.rs2               (rs2),
.store_load_hazard (store_load_hazard),
.store_value       (rs2_exe2lsu),
.w_data            (w_data),
.rs1_fwd2exe       (rs1_fwd2exe),
.rs2_fwd2exe       (rs2_fwd2exe)
);

BranchPrediction bpu(
.clk                (clk),
.rstn               (rstn),
.pcbranch           (pcbranch),
.pc                 (pc),
.pc_id2exe          (pc_id2exe),
.imm                (imm_data),
.branch_cntr        (branch_cntr),
.br_taken_reg       (br_taken),
.target_address_reg (target_addr)
);

endmodule

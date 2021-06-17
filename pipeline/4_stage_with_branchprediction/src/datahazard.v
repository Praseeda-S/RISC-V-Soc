//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine
module datahazard(
input wire clk,
input wire rstn,
input wire [4:0]  rs1_addr,
input wire [4:0]  rs2_addr,
input wire [4:0]  wr_addr_id2exe, 
input wire [4:0]  wr_addr_lsu2reg,
input wire        reg_wr1,
input wire        reg_wr2,
input wire [1:0]  St_cntr,
input wire [31:0] ALU_result,
input wire [31:0] memtoreg_data,
input wire [6:0]  opcode,
output reg [1:0]  rs1_hazard,
output reg [1:0]  rs2_hazard,
output reg [31:0] memtoreg_data_DH,
output reg store_load_hazard  
);

wire [1:0]  rs1_haz,rs2_haz;
reg  [1:0]  St_cntr_reg;
reg  [31:0] ALU_result_reg;
wire store_load_haz;

assign store_load_haz = ((|St_cntr_reg) & (ALU_result_reg == ALU_result) & (opcode == 7'b0000011));

assign rs1_haz = ((rs1_addr != 0) && (rs1_addr == wr_addr_id2exe) && reg_wr1) ? 2'b01 : (((rs1_addr != 0) && (rs1_addr == wr_addr_lsu2reg) && reg_wr2) == 1  ? 2'b10 : 2'b00) ;

assign rs2_haz = ((rs2_addr != 0) && (rs2_addr == wr_addr_id2exe) && reg_wr1) ? 2'b01 : (((rs2_addr != 0) && (rs2_addr == wr_addr_lsu2reg) && reg_wr2) == 1  ? 2'b10 : 2'b00) ;

always @(posedge clk or negedge rstn) begin

if (~rstn) begin
rs1_hazard <= 0;
rs2_hazard <= 0;
memtoreg_data_DH <= 0;
store_load_hazard <= 0;
St_cntr_reg <= 0;
ALU_result_reg <= 0;
end

else begin
rs1_hazard <= rs1_haz;
rs2_hazard <= rs2_haz;
memtoreg_data_DH <= memtoreg_data;
store_load_hazard <= store_load_haz;
St_cntr_reg <= St_cntr;
ALU_result_reg <= ALU_result;
end
end
endmodule




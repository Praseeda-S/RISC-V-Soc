//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine

module datahazard(
input wire clk,
input wire [4:0] reg_addr1,
input wire [4:0] reg_addr2,
input wire [4:0] reg_addr31, 
input wire [4:0] reg_addr33,
input wire       reg_wr1,
input wire       reg_wr2,
output reg  [1:0]     rs1_hazard,
output reg  [1:0]     rs2_hazard,
input wire [31:0]     memtoreg_data,
output reg [31:0]     memtoreg_data_DH 
);

wire [1:0] rs1_haz,rs2_haz;

assign rs1_haz = ((reg_addr1 != 0) && (reg_addr1 == reg_addr31) && reg_wr1) ? 2'b01 : (((reg_addr1 != 0) && (reg_addr1 == reg_addr33) && reg_wr2) == 1  ? 2'b10 : 2'b00) ;

assign rs2_haz = ((reg_addr2 != 0) && (reg_addr2 == reg_addr31) && reg_wr1) ? 2'b01 : (((reg_addr2 != 0) && (reg_addr2 == reg_addr33) && reg_wr2) == 1  ? 2'b10 : 2'b00) ;

always @(posedge clk)
begin
rs1_hazard <= rs1_haz;
rs2_hazard <= rs2_haz;
memtoreg_data_DH <= memtoreg_data;

end

endmodule




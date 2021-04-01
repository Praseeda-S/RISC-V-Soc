module lsu(
input clk,
input rstn,
input [31:0] alu_out,
input alu_ov_flag,
output [31:0] data_addr,
input MemtoReg,
output [31:0] reg_wrdata,
input [1:0] Ld_cntr,
input [31:0] St_cntr,
input [31:0]datamem_wr_in,
output [31:0]datamem_wr_o,
input [31:0] datamem_rd_in
);

assign data_addr = alu_out;
case (Memtoreg)
	2'b01:	assign reg_wrdata = alu_out;
	2'b10:	assign reg_wrdata = {30{1'b0}, alu_ov_flag}};
	2'b11:	case(Ld_cntr)
			2'b00:	assign reg_wrdata = datamem_rd_in;
			2'b01:	assign reg_wrdata = {16{1'b1},datamem_rd_in[15:0]}
			2'b10:	assign reg_wrdata = {24{1'b1},datamem_rd_in[7:0]}
always@(clk)
begin
	assign datamem_wr_o = datamem_wr_in & St_cntr;
end

		 
endmodule

module lsu(
input			clk,
input	   [31:0] 	alu_out_exe2lsu,
input 			alu_ov_flag_exe2lsu,
output	   [31:0]	data_addr,
input 	   [1:0] 	MemtoReg,
output reg [3:0]  	dmem_wr,
output reg [31:0] 	reg_wrdata,
input 	   [2:0] 	Ld_cntr,
input 	   [1:0] 	St_cntr,
input 	   [31:0]	datamem_wr_in,
output reg [31:0]  	datamem_wr_o,
input 	   [31:0] 	datamem_rd_in,
input           	RegW_exe2lsu,
output reg      	RegW_lsu2reg,
input      [4:0]     	wr_addr_exe2lsu,
output reg [4:0]	wr_addr_lsu2reg
);

assign data_addr = alu_out_exe2lsu;

wire [1:0]b_pos = alu_out_exe2lsu[1:0];

always@(*)
begin
RegW_lsu2reg <= RegW_exe2lsu;
wr_addr_lsu2reg <= wr_addr_exe2lsu;
end
	
always@(*)
begin

case (MemtoReg)
	2'b01:	reg_wrdata <= alu_out_exe2lsu;
	2'b10:	reg_wrdata <= {{30{1'b0}}, alu_ov_flag_exe2lsu};
	2'b11:	case(Ld_cntr)
			3'b000:	reg_wrdata <= datamem_rd_in;
			3'b001:	reg_wrdata <= {{16{datamem_rd_in[15]}},datamem_rd_in[15:0]};
			3'b010: reg_wrdata <= {{24{datamem_rd_in[7]}},datamem_rd_in[7:0]};
			3'b011:	reg_wrdata <= {{16{1'b0}},datamem_rd_in[15:0]};
			3'b100:	reg_wrdata <= {{24{1'b0}},datamem_rd_in[7:0]};
		endcase

endcase
end

always@(*)
begin

case(St_cntr)
	2'b00:	dmem_wr <= 4'b0000;
	2'b01:	dmem_wr <= 4'b1111;
	2'b10:	case (b_pos)
		2'b00:	dmem_wr <= 4'b0011;
		2'b10:	dmem_wr <= 4'b1100;
		endcase
	2'b11:	case (b_pos)
		2'b00:	dmem_wr <= 4'b0001;
		2'b01:	dmem_wr <= 4'b0010;
		2'b10:	dmem_wr <= 4'b0100;
		2'b11:	dmem_wr <= 4'b1000;
		endcase
endcase
end

always@(*)
begin

datamem_wr_o <= datamem_wr_in << (b_pos*8);

end
		 
endmodule

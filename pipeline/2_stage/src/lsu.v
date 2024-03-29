module lsu(
input		rstn,
input	[31:0] 	alu_out,
input 		alu_ov_flag,
output	[31:0]	data_addr,
input 	[1:0] 	MemtoReg,
output reg [3:0]  dmem_wr,
output reg [31:0] reg_wrdata,
input 	[2:0] 	Ld_cntr,
input 	[1:0] 	St_cntr,
input 	[31:0]	datamem_wr_in,
output reg [31:0]  datamem_wr_o,
input 	[31:0] 	datamem_rd_in
);

assign data_addr = alu_out;

wire [1:0]b_pos = alu_out[1:0];

wire [7:0] d0 = datamem_wr_in[7:0];
wire [7:0] d1 = datamem_wr_in[15:8];
wire [7:0] d2 = datamem_wr_in[23:16];
wire [7:0] d3 = datamem_wr_in[31:24];

/*assign datamem_wr_o = (b_pos == 2'b00)? {d3,d2,d1,d0}:0;
assign datamem_wr_o = (b_pos == 2'b01)? {d0,d3,d2,d1}:0;
assign datamem_wr_o = (b_pos == 2'b10)? {d1,d0,d3,d2}:0;
assign datamem_wr_o = (b_pos == 2'b11)? {d2,d1,d0,d3}:0;
*/

/*assign dmem_wr[0] = (~St_cntr[1] & St_cntr[0]) | (St_cntr[1] & ~b_pos[1] & ~b_pos[0]);
assign dmem_wr[1] = (~St_cntr[1] & St_cntr[0]) | (St_cntr[1] & ((~St_cntr[0] & ~b_pos[1])|(St_cntr[0] & ~b_pos[1] & b_pos[0])));
assign dmem_wr[2] = (~St_cntr[1] & St_cntr[0]) | (St_cntr[1] & ((~St_cntr[0] & ~b_pos[1] & b_pos[0]) | (b_pos[1] & ~b_pos[0])));
assign dmem_wr[3] = (~St_cntr[1] & St_cntr[0]) | (St_cntr[1] & b_pos[1] & ((~St_cntr[0] & ~b_pos[0]) | b_pos[0])); 
*/

always@(*)
if (~rstn) reg_wrdata <= 0;

else begin
begin
reg_wrdata = 0;
case (MemtoReg)
	2'b01:	reg_wrdata <= alu_out;
	2'b10:	reg_wrdata <= {{30{1'b0}}, alu_ov_flag};
	2'b11:	case(Ld_cntr)
			3'b000:	reg_wrdata <= datamem_rd_in;
			3'b001:	reg_wrdata <= {{16{datamem_rd_in[15]}},datamem_rd_in[15:0]};
			3'b010: reg_wrdata <= {{24{datamem_rd_in[7]}},datamem_rd_in[7:0]};
			3'b011:	reg_wrdata <= {{16{1'b0}},datamem_rd_in[15:0]};
			3'b100:	reg_wrdata <= {{24{1'b0}},datamem_rd_in[7:0]};
		endcase

endcase
end
end

always@(*)
if (~rstn) dmem_wr <= 0;
else begin 
begin

case(St_cntr)
	2'b00:	dmem_wr <= 4'b0000;
	2'b01:	dmem_wr <= 4'b1111;
	2'b10:	case (b_pos)
		2'b00:	dmem_wr <= 4'b0011;
		2'b01:	dmem_wr <= 4'b0110;
		2'b10:	dmem_wr <= 4'b1100;
		2'b11:	dmem_wr <= 4'b1000;
		endcase
	2'b11:	case (b_pos)
		2'b00:	dmem_wr <= 4'b0001;
		2'b01:	dmem_wr <= 4'b0010;
		2'b10:	dmem_wr <= 4'b0100;
		2'b11:	dmem_wr <= 4'b1000;
		endcase
endcase
end
end

always@(*)
begin

if (~rstn) datamem_wr_o <= 0;

else
begin

case (b_pos)
	2'b00:	datamem_wr_o <= {d3,d2,d1,d0};
	2'b01:	datamem_wr_o <= {d2,d1,d0,d3};
	2'b10:	datamem_wr_o <= {d1,d0,d3,d2};
	2'b11:	datamem_wr_o <= {d0,d3,d2,d1};
endcase
end
end
		 
endmodule

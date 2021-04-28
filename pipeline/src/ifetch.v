module ifetch(
input		clk,
input 		rstn,
output	[31:0]	instr_addr_o,
input	[31:0]	rs1,
input 	[31:0]	immediate,
input 		jal,jalr,pcbranch,
input   [31:0]  instr_in,
output reg[31:0]  instr_reg,
output reg 	  cpu_wait,
output reg[31:0]  pc_if2id		
);

wire pc_error = jal|jalr|pcbranch;

wire [31:0] t1;
wire [31:0] t2;
wire [31:0] t3;
wire [31:0] pc_nxt;
reg  [31:0] pc;

assign instr_addr_o = pc;

assign t1 = (jalr===1)? rs1 : pc;
assign t2 = (jal===1)? immediate : 32'h00000004;
wire [31:0] t_sum = t1+t2;
assign t3 = (jalr===1)? t_sum &(32'hFFFFFFFE) : t_sum;

assign pc_nxt = (pcbranch)? pc+immediate: t3;

always@(posedge clk or negedge rstn)
begin

if (~rstn)
begin
 pc <= 0;
 instr_reg <= 0;
end

else
begin
 if (pc_error===1 && cpu_wait!==1)
  begin
	cpu_wait <= 1;
	begin
	case(jalr)
	1'b1:	pc <= pc_nxt;
	1'b0:	pc <= pc_nxt - 4; 
	endcase
	end
  end
 else
  begin
	cpu_wait <= 0;
	pc <= pc_nxt;
   	instr_reg <= instr_in;
	pc_if2id <= pc;
  end
end
			
end



endmodule

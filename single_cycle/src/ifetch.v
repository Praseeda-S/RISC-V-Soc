module ifetch(
input		clk,
input 		rstn,
output	[31:0]	instr_addr_o,
input	[31:0]	rs1,
input 	[31:0]	immediate,
input 		jal,jalr,pcbranch
);

wire [31:0] t1;
wire [31:0] t2;
wire [31:0] t3;
wire [31:0] pc_nxt;
reg  [31:0] pc;

assign instr_addr_o = pc;

assign t1 = (jalr==1)? rs1 : pc;
assign t2 = (jal==1)? immediate : 32'h00000004;
assign t3 = (jalr==1)? (t1+t2)&(32'hFFFFFFFE) : (t1+t2);

assign pc_nxt = (pcbranch)? pc+immediate : t3;

always@(posedge clk or negedge rstn)
begin
if (~rstn)
 pc <= 32'h00000000;
else
 pc <= pc_nxt;			
end


endmodule

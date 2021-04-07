module ifetch(
output reg [31:0]pc,
input [31:0]rs1,
input [31:0]immediate,
input jal, jalr, pcbranch,
input clk
);

wire [31:0]t1;
wire [31:0]t2;
wire [31:0]t3;

assign t1 = (jalr==1)? rs1 : pc;
assign t2 = (jal==1)? immediate : 32'h00000004;
assign t3 = (jalr==1)? (t1+t2)&(32'hFFFFFFFE) : (t1+t2);

always@(posedge clk)
begin
case(pcbranch)
	1'b0: pc <= t3;
	1'b1: pc <= pc + immediate;
	default: pc <= 32'h00000000;
endcase				
end
endmodule

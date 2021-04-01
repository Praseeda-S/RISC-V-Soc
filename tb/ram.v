module ram #(parameter AWIDTH=8, DWIDTH = 32)(
input clk,
input mem_wr,
input mem_en,
input [31:0]addr,
output [DWIDTH-1:0]data_rd,
input [DWIDTH-1:0]data_wr,
);

reg [31:0] ram_reg [0:];

wire [AWIDTH-1:0] addrs = addr[AWIDTH-1:0]; 

if (mem_en == 1)
	data_rd = ram_reg[addrs];

always@(clk)
begin
if (mem_en == 1)
	ram_reg[addrs] = data_wr;
end

endmodule

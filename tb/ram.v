module ram #(parameter AWIDTH=8, DWIDTH = 32)(
input clk,
input rstn,
input mem_wr,
input mem_en,
input [31:0]addr,
output [DWIDTH-1:0]data_rd,
input [DWIDTH-1:0]data_wr
);

integer ram_size = 2**AWIDTH;
reg [31:0] ram_reg [0:2**AWIDTH-1];

wire [AWIDTH-1:0] addrs;
assign addrs = addr[AWIDTH-1:0]; 

assign data_rd =(mem_en)? ram_reg[addrs] : 0;

integer i = 0;

always@(posedge clk)
begin
if (~rstn)
	begin
	for (i = 0; i<ram_size; i = i+1)
	 ram_reg[i] <= 0;
	end
else if (mem_en)
	ram_reg[addrs] <= data_wr;
end

endmodule

//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine
module ram #(parameter AWIDTH=8, DWIDTH = 32)(
input clk,
input rstn,
input mem_en,
input [3:0] mem_wr,
input [31:0]addr,
input [(DWIDTH/4)-1:0]data_wr0,
input [(DWIDTH/4)-1:0]data_wr1,
input [(DWIDTH/4)-1:0]data_wr2,
input [(DWIDTH/4)-1:0]data_wr3,
output [DWIDTH-1:0]data_rd
);



// 4 blocks of register arrays
reg [(DWIDTH/4)-1:0] ram_reg0 [0:2**AWIDTH-1];
reg [(DWIDTH/4)-1:0] ram_reg1 [0:2**AWIDTH-1];
reg [(DWIDTH/4)-1:0] ram_reg2 [0:2**AWIDTH-1];
reg [(DWIDTH/4)-1:0] ram_reg3 [0:2**AWIDTH-1];

wire [AWIDTH-1:0] addrs = addr[AWIDTH+1:2]; // word address
wire [3:0] byte_add = addr[1:0];            // byte location

assign data_rd = (mem_en)? {ram_reg3[addrs],ram_reg2[addrs],ram_reg1[addrs],ram_reg0[addrs]} >> (byte_add * 8): 0;

integer i = 0;
integer j = 0;
integer k = 0;
integer l = 0;

always@(posedge clk or negedge rstn)  // register block 0
begin
if (~rstn)
   begin
   for (i = 0; i<2**AWIDTH; i = i+1)
    ram_reg0[i] <= 0;
   end
else if (mem_en && mem_wr[0])
    ram_reg0[addrs] <= data_wr0;
end

always@(posedge clk or negedge rstn) // register block 1
begin
if (~rstn)
   begin
   for (j = 0; j<2**AWIDTH; j = j+1)
    ram_reg1[j] <= 0;
   end
else if (mem_en && mem_wr[1])
    ram_reg1[addrs] <= data_wr1;
end

always@(posedge clk or negedge rstn) // register block 2
begin
if (~rstn)
   begin
   for (k = 0; k<2**AWIDTH; k = k+1)
    ram_reg2[k] <= 0;
   end
else if (mem_en && mem_wr[2])
    ram_reg2[addrs] <= data_wr2;
end

always@(posedge clk or negedge rstn) // register block 3
begin
if (~rstn)
   begin
   for (l = 0; l<2**AWIDTH; l = l+1)
    ram_reg3[l] <= 0;
   end
else if (mem_en && mem_wr[3])
    ram_reg3[addrs] <= data_wr3;
end


endmodule

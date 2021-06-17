//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine
module rom(
input clk,
input [31:0] addr_in,
output [31:0] data_out
);

reg [31:0] rom_reg [0:1023];
wire [9:0] addr = addr_in[11:2];
assign data_out = rom_reg[addr];

initial 
   $readmemb("irom_hex8.txt", rom_reg);

endmodule

/********************************************************************************************************
Github repo : 313849252
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : Instruction Memory (ROM)
Module name : rom
Description : 1024 registers each of size 32 bits from where instructions are fetched for the processor
********************************************************************************************************/

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

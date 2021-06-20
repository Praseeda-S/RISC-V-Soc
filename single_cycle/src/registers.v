/******************************************************************************************************************
Github repo : 313849252
Date : 20/04/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : Register set 
Module name : registers
Description : 32 general purpose registers, each 32 bit wide houses all the operands needed for various operations 
******************************************************************************************************************/

module registers(
input         clk,
input         rstn,
input         write,
input [4:0]   rs1_addr,
input [4:0]   rs2_addr,
input [4:0]   w_addr,
input [31:0]  w_data,

output [31:0] rs1_out,
output [31:0] rs2_out
);

//register array
//32 registers each of length 32
reg[31:0] reg_arr[0:31];

//rs1 and rs2 read
//rs1_addr and rs2_addr from idecoder
assign rs1_out = reg_arr[rs1_addr]; 
assign rs2_out = reg_arr[rs2_addr];

integer i;

always @(posedge clk or negedge rstn)
begin

 if(~rstn)
   begin
     for(i = 0;i<32;i = i+1)
         reg_arr[i] <= 0;
   end
 else if(write)
	 begin
	    i = 0;
	 if (w_addr != 0)
           reg_arr[w_addr] <= w_data;
         end
end

endmodule

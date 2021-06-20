/********************************************************************************************************
Github repo : 313849252
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : Pattern History Table 
Module name : PatternHistoryTable 
Description : Consists of 2^n entries per branch, each entry containing a two-bit saturating counter
********************************************************************************************************/

module PatternHistoryTable #(parameter REGSIZE=2)(
input wire clk,
input wire rstn,
input wire en,
input wire pcbranch,
input wire [REGSIZE-1:0] pattern_addr,
output [1:0]count
);

reg [1:0] hist_table [2**REGSIZE-1:0];
integer i;
assign count = hist_table[pattern_addr];

always@(posedge clk or negedge rstn)//happens after exe stage of branch instruction
begin
  if(~rstn)
  begin
    for(i = 0;i<2**REGSIZE;i = i+1) 
   hist_table[i]<=2'b01;
  end
  
  else
  begin
  i=0; //to avoid inferred latches.
    if(en)
    begin
      if (pcbranch==1)
      begin
        if(hist_table[pattern_addr] ==2'b00 || hist_table[pattern_addr] ==2'b01|| hist_table[pattern_addr]==2'b10)
      hist_table[pattern_addr] <= hist_table[pattern_addr] + 2'b01;
      end
      else if (pcbranch==0)
      begin
        if(hist_table[pattern_addr] ==2'b01 || hist_table[pattern_addr] ==2'b10 || hist_table[pattern_addr]==2'b11)
      hist_table[pattern_addr] <= hist_table[pattern_addr] - 2'b01;
      end
     end
  end
end
endmodule

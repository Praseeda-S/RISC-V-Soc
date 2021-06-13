//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine

module PatternHistoryTable #(parameter REGSIZE=2)(
input clk,
input rstn,
input en,
input pcbranch,
input [REGSIZE-1:0] pattern_addr,

output [1:0]count
);

reg [1:0] hist_table [2**REGSIZE-1:0];
integer i;
assign count = hist_table[pattern_addr];

always@(posedge clk or negedge rstn)//happens after exe stage of branch instr
begin
  if(~rstn)
  begin
    for(i = 0;i<2**REGSIZE;i = i+1) 
	hist_table[i]<=2'b01;
  end
  else
  begin
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

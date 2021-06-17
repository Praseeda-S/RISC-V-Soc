//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine
module BranchHistoryRegister #(parameter REGSIZE=2)(
input  clk,
input  rstn,
input  bhr_en,
input  bhr_in,
output reg [REGSIZE-1:0] bhr_out 
);


always@(posedge clk or negedge rstn)
begin
if(~rstn)
  bhr_out <= 0;
else 
  begin
    if(bhr_en)
       bhr_out <= {bhr_in, bhr_out[REGSIZE-1:1]};
    else
       bhr_out <= bhr_out;
  end
end

endmodule

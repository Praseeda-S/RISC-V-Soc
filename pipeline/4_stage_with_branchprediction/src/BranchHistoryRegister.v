/***********************************************************************************************************
Github repo : 313849252
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering, Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : Branch History Register
Module name : BranchHistoryRegister
Description : A shift register that records last n branches encountered by the processor
***********************************************************************************************************/

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

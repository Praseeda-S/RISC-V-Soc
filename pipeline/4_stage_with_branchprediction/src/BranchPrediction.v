/************************************************************************************************************************************************************
Github repo : https://github.com/Praseeda-S/RISC-V-Soc.git
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering, Trivandrum
Project Name : Design and Verification of Vriddhi: A RISC-V Core
Design name : Branch Prediction Unit
Module name : BranchPrediction
Description : Predicts whether a given instruction is a branch instruction and whether it is going to be taken or not by taking inputs from BHR, PHT and BTB
************************************************************************************************************************************************************/

module BranchPrediction (
input wire clk,
input wire rstn,
input wire pcbranch,
input wire [31:0] pc,
input wire [31:0] pc_id2exe,
input wire [31:0] imm,
input wire [2:0]  branch_cntr,
output br_taken_reg,
output [31:0] target_address_reg
);

parameter BLOCKSIZE = 4;
parameter REGSIZE   = 2;


//------CONNECTING WIRES BETWEEEN BHR , PHT , BTB------//

wire hit;
reg  hit_d1;
reg  hit_d2;

wire [31:0] addr_out;
wire [REGSIZE-1:0] bhr_out;
wire [1:0] count;
wire bp_reg_wr;
reg  branch_cntr_d;

wire br_taken;

wire [31:0] target_address;
wire btb_wr;

assign br_taken = (hit & count[1]);
assign br_taken_reg = br_taken;
assign target_address_reg = target_address;

always@(posedge clk or negedge rstn)
begin
  if(~rstn)
  begin
    hit_d1 <= 0;
    hit_d2 <= 0;
    branch_cntr_d <= 0 ;
  end
  else
  begin
   hit_d1 <= hit;
   hit_d2 <= hit_d1;
   branch_cntr_d <= (|branch_cntr) ; //for bhr and pht enable signals.
  end 
end

assign btb_wr = (~hit_d2  & (|branch_cntr));
assign bp_reg_wr = branch_cntr_d;


//------------INSTANTIATING BHR , PHT , BTB------------//

BranchTargetBuffer #( .BLOCKSIZE(BLOCKSIZE) ) 
btb(
.clk       (clk),
.rstn      (rstn),
.pc        (pc),
.pc_id2exe (pc_id2exe),
.imm       (imm),
.en        (btb_wr),
.hit       (hit),
.addr_out  (target_address) 
);



BranchHistoryRegister #( .REGSIZE(REGSIZE) ) 
bhr(
.clk     (clk),
.rstn    (rstn),
.bhr_en  (bp_reg_wr),
.bhr_in  (pcbranch),
.bhr_out (bhr_out)
);



PatternHistoryTable #( .REGSIZE(REGSIZE) ) 
pht(
.clk          (clk),
.rstn         (rstn),
.en           (bp_reg_wr),
.pcbranch     (pcbranch),
.pattern_addr (bhr_out),
.count        (count)        
);


endmodule

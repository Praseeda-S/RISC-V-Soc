/********************************************************************************************************
Github repo : 313849252
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : Instruction Fetch
Module name : ifetch
Description : Updates program counter (PC) and fetches 32-bit instruction from ROM (instruction memory)
********************************************************************************************************/

module ifetch(
input wire clk,
input wire rstn,
input wire [31:0] rs1,
input wire [31:0] imm,
input wire [31:0] instr_in,
input wire [31:0] bpu_addr,
input wire [2:0]  branch_cntr,
input wire bpu_branch,
input wire jal,jalr,pcbranch, 
output ide_wait,
output exe_wait,
output [31:0] pc_if2bpu,
output [31:0] instr_addr_o,
output reg [31:0] instr_reg,
output reg [31:0] pc_if2id
);

//variable signals used for stalling
reg branch_encountered;
reg cpu_wait;
reg branch_predicted;
reg branch_predicted_d1;
reg branch_predicted_d2;

reg [31:0] pc_prev1,pc_prev2,pc_prev3;
wire branchcnt = branch_cntr[0]| branch_cntr[1]|branch_cntr[2];
wire pc_error = jal|jalr|(pcbranch^branch_predicted_d2)|(branchcnt^branch_predicted_d1)|branch_encountered; 

assign exe_wait = (pcbranch==0 & branch_predicted_d2==1)? 1'b1:1'b0; 

wire [31:0] t1;
wire [31:0] t2;
wire [31:0] t3;
wire [31:0] t4;
wire [31:0] pc_nxt;
reg  [31:0] pc;
reg [31:0] pc_next1;

assign instr_addr_o = pc;
assign ide_wait = pc_error|cpu_wait;
assign pc_if2bpu = pc;

//computing next pc
assign t1 = (jalr===1)? rs1 : pc-8;
assign t2 = t1 + imm;
assign t3 = (jalr===1)? t2 &(32'hFFFFFFFE) : t2;
assign t4 = pc+4;

assign pc_nxt = (pcbranch==1 && branch_predicted_d2==0 )? pc_next1 : (jal===1)? t3:t4 ;

always@(posedge clk or negedge rstn)
begin
if (~rstn)  
begin
 pc <= 0;
 instr_reg <= 0;
 branch_encountered <= 0;
 branch_predicted <= 0;
end

else
begin
   if(branchcnt !=0 && branch_predicted_d1==0)
   begin
   pc_next1 <= t2;
   branch_encountered<=1;
        end


   if(exe_wait==1)
   begin
      pc <= pc_prev3 + 4;
      branch_predicted <= 0;
      branch_predicted_d1 <= 0;
      branch_predicted_d2 <= 0;
   end

   else
   begin

      if (bpu_branch)
      begin
         pc <= bpu_addr;
         branch_predicted <= 1;
      end


      else if(pcbranch==0 && branch_encountered==1)
      begin
         pc<= t1;
            branch_encountered<=0;
      end

      else if (pcbranch ==1 && branch_encountered==1)
      begin
         branch_encountered<=0;
               pc<=pc_nxt;
         end

         else
      begin
            pc<= pc_nxt;
         branch_predicted <= 0;
      end

      branch_predicted_d1 <= branch_predicted;
      branch_predicted_d2 <= branch_predicted_d1;
   end
pc_prev1 <= pc;
pc_prev2 <= pc_prev1;
pc_prev3 <= pc_prev2;
 


if (pc_error !==1)
  begin
   //latching
   instr_reg <= instr_in;
        pc_if2id <= pc;
   cpu_wait<= 0;
   
  end

else
   cpu_wait<=1;

end
         
end

endmodule


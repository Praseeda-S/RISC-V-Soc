//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine
module BranchTargetBuffer #(parameter BLOCKSIZE = 4)(
input       clk,
input       rstn,
input [31:0]pc,
input [31:0]pc_id2exe,
input [31:0]imm,
input        en,
output       hit,
output reg[31:0]addr_out
);

reg [31:0] pc_arr[0:BLOCKSIZE-1];
reg [31:0] addr_arr[0:BLOCKSIZE-1];
reg hit_reg;
integer i;
reg [1:0] wr_pos;//position in which writing happens

assign hit = hit_reg & rstn;

//-------COMPARING PC TO FIND THE TARGET ADDRESS-------//
always@(pc)
begin
   hit_reg <= 0;
   addr_out <= 32'b0; //warning 13012
   for(i = 0;i<BLOCKSIZE;i = i+1)
   begin
      if(pc == pc_arr[i])
           begin
         addr_out <= addr_arr[i];
              hit_reg <= 1;
           end            
   end
end

//-----------------------WRITING-----------------------//
always@(posedge clk or negedge rstn)//in decode stage of the branch instruction itself.
begin
   if(~rstn)
   begin
          wr_pos <= 0;    
          for(i = 0;i<BLOCKSIZE;i = i+1)
          begin
             pc_arr[i] <= 32'b00000000;
             addr_arr[i] <= 32'b00000000;
          end
        end
   else
   begin
	   i=0; //to avoid inferred latches.
      if(en)
      begin
        pc_arr[wr_pos] <= pc_id2exe;
        addr_arr[wr_pos] <= pc_id2exe+imm;
        wr_pos <= wr_pos + 1'b1;
      end 
   end
	
end

endmodule

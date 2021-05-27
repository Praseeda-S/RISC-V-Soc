module btb#(parameter BLOCKSIZE = 4)(
input       clk,
input       rstn,
input [31:0]pc,
input [2:0] Branch_cntr,
input [31:0]pc_id2exe,
input [31:0]imm,

output reg      hit,
output reg[31:0]addr_out
);

reg [31:0] pc_arr[0:BLOCKSIZE-1];
reg [31:0] addr_arr[0:BLOCKSIZE-1];

integer i;
integer wr_pos;//position in which writing happens

//--------COMPARING PC TO FIND THE TARGET ADDRESS--------
always@(pc)
begin
	for(i = 0;i<BLOCKSIZE;i = i+1)
	begin
	   if(pc == pc_arr[i])
           begin
	      addr_out <= addr_arr[i];
              hit <= 1;
	   end
	end
end

//---------------------WRITING---------------------
always@(posedge clk or negedge rstn)
begin
	if(~rstn)
	begin
          hit <= 0;
	  wr_pos = 32'b00000000;
          for(i = 0;i<BLOCKSIZE;i = i+1)
          begin
	     pc_arr[i] <= 32'b00000000;
             addr_arr[i] <= 32'b00000000;
          end
        end
	else
	begin
	   if(|Branch_cntr)
	   begin
	     pc_arr[wr_pos] <= pc_id2exe;
	     addr_arr[wr_pos] <= pc_id2exe+imm;
	     wr_pos = wr_pos+1;
	   end 
        end
end

endmodule

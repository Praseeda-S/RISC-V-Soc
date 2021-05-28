module ifetch(
input			clk,
input 			rstn,
output	  [31:0]	instr_addr_o,
input	  [31:0]	rs1,
input 	  [31:0]	immediate,
input 			jal,jalr,pcbranch,
input     [31:0]  	instr_in,
output reg[31:0]  	instr_reg,
output   	  	ide_wait,
output 			exe_wait,
output reg[31:0]  	pc_if2id,
input     [2:0]         Branch_cntr,
output	  [31:0]	pc,
input			bpu_branch,
input	  [31:0]	bpu_addr 
);

//variable signals used for stalling
reg i;
reg cpu_wait;
reg branch_predicted;
reg branch_predicted_d1;
reg branch_predicted_d2;

reg [31:0] pc_prev1,pc_prev2,pc_prev3;

wire pc_error = jal|jalr|(pcbranch^branch_predicted_d2)|(branchcnt^branch_predicted_d1)|i; 
wire branchcnt = Branch_cntr[0]| Branch_cntr[1]|Branch_cntr[2];

assign exe_wait = (pcbranch==0 && branch_predicted_d2==1)? 1:0; 


wire [31:0] t1;
wire [31:0] t2;
wire [31:0] t3;
wire [31:0] t4;
wire [31:0] pc_nxt;
reg  [31:0] pc;
reg [31:0] pc_next1;

assign instr_addr_o = pc;
assign ide_wait = pc_error|cpu_wait;

//computing next pc
assign t1 = (jalr===1)? rs1 : pc-8;
assign t2 = t1 + immediate;
assign t3 = (jalr===1)? t2 &(32'hFFFFFFFE) : t2;
assign t4 = pc+4;

assign pc_nxt = (pcbranch==1 && branch_predicted_d2==0 )? pc_next1 : (jal===1)? t3:t4 ;

always@(posedge clk or negedge rstn)
begin
if (~rstn)	
begin
 pc <= 0;
 instr_reg <= 0;
 i <= 0;
 branch_predicted <= 0;
end

else
begin
	if(branchcnt !=0 && branch_predicted_d1==0)
	begin
	pc_next1 <= t2;
	i<=1;
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


		else if(pcbranch==0 && i==1)
		begin
			pc<= t1;
        		i<=0;
		end

		else if (pcbranch ==1 && i==1)
		begin
			i<=0;
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


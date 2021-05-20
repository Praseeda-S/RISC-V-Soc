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
output reg[31:0]  	pc_if2id,
input     [2:0]         Branch_cntr 
);

//variable signals used for stalling
reg i=0;
reg cpu_wait=0;
wire pc_error = jal|jalr|pcbranch|branchcnt|i; 
wire branchcnt = Branch_cntr[0]| Branch_cntr[1]|Branch_cntr[2];


wire [31:0] t1;
wire [31:0] t2;
wire [31:0] t3;
wire [31:0] pc_nxt;
reg  [31:0] pc;
reg [31:0] pc_next1;

assign instr_addr_o = pc;
assign ide_wait = pc_error|cpu_wait;

//computing next pc
assign t1 = (jalr===1)? rs1 : pc;
assign t2 = (jal===1)? immediate : 32'h00000004;
wire [31:0] t_sum = t1+t2;
assign t3 = (jalr===1)? t_sum &(32'hFFFFFFFE) : t_sum;
assign pc_nxt = (pcbranch===1 )? pc_next1 : ((jal===1)? (jalr===1)? t3: t3-8 : t3) ;

always@(posedge clk or negedge rstn)
begin
if (~rstn)	
begin
 pc <= 0;
 instr_reg <= 0;
end

else
begin
	if(branchcnt !=0)
	begin
	pc_next1 <= pc+immediate-8;
	i<=1;
        end


	if(pcbranch==0 && i===1)
	begin
		pc<= pc-8;
        	i<=0;
		cpu_wait<=1;
	end

	else if (pcbranch ==1 && i===1)
	begin
		i<=0;
	       pc<=pc_nxt;
	       cpu_wait <=1;
       end

        else
	begin
        	pc<= pc_nxt;
	end


if (pc_error !==1)
  begin
	//latching
	  	instr_reg <= instr_in;
         	pc_if2id <= pc;
		cpu_wait<= 0;
	
end

else
begin
	if(jal===1)
	cpu_wait<=1;
end

end
			
end

endmodule


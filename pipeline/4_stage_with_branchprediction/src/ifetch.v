module ifetch(
input			clk,
input 			rstn,
output	  [31:0]	instr_addr_o,
input	  [31:0]	rs1,
input 	  [31:0]	immediate,
input 			jal,jalr,
input     [31:0]  	instr_in,
output reg[31:0]  	instr_reg,
output   	  	ide_wait,
output 			cpu_wait,
output reg[31:0]  	pc_if2id,

input   [31:0]  target_address,
input    wire       branch_taken
);

//variable signals used for stalling

reg cpu_wait;
wire pc_error = jal|jalr; 

wire [31:0] t1;
wire [31:0] t2;
wire [31:0] t3;
wire [31:0] t4;
wire [31:0] pc_nxt;
reg  [31:0] pc;


assign instr_addr_o = pc;
assign ide_wait = pc_error|cpu_wait;

//computing next pc
assign t1 = (jalr===1)? rs1 : pc-8;
assign t2 = t1 + immediate;
assign t3 = (jalr===1)? t2 &(32'hFFFFFFFE) : t2;
assign t4 = pc+4;

assign pc_nxt = (jal===1)? t3:t4 ;

always@(posedge clk or negedge rstn)
begin
if (~rstn)	
begin
 pc <= 0;
 instr_reg <= 0;
end

else
begin

 if (branch_taken == 1 )
  begin
 	pc <= target_address;
  end
  
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


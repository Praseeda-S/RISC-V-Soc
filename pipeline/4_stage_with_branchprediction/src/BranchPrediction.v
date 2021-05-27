module BranchPrediction (
input wire clk,
input wire rstn,
input wire pcbranch,
input wire [31:0] pc,
input wire [31:0] pc_id2exe,
input wire [31:0] imm,
input wire [2:0]  Branch_cntr,

output reg br_taken_reg,
output reg [31:0] target_address_reg

);

parameter BLOCKSIZE = 4;
parameter REGSIZE   = 2;


//------CONNECTING WIRES BETWEEEN BHR , PHT , BTB------//

wire hit;
wire [31:0] addr_out;
wire [REGSIZE-1:0] bhr_out;
wire [1:0] count;
wire bp_reg_wr;
reg  Branch_cntr_delay;
wire br_taken;
wire [31:0] target_address;

assign br_taken = (hit & (count[1]));
assign bp_reg_wr = (Branch_cntr_delay);

always @(posedge clk)
begin
	br_taken_reg <= br_taken;
	target_address_reg <= target_address;
	Branch_cntr_delay <= |Branch_cntr ; 
end




//------------INSTANTIATING BHR , PHT , BTB------------//

BranchTableBuffer #( .BLOCKSIZE(BLOCKSIZE) ) 
btb(
.clk 	(clk),
.rstn	(rstn),
.pc	(pc),
.pc_id2exe (pc_id2exe),
.imm 	(imm),
.Branch_cntr (Branch_cntr),
.hit	(hit),
.addr_out  (target_address) 
);



BranchHistoryRegister #( .REGSIZE(REGSIZE) ) 
bhr(
.clk 	 (clk),
.rstn	 (rstn),
.bhr_en  (bp_reg_wr),
.bhr_in  (pcbranch),
.bhr_out (bhr_out)
);



PatternHistoryTable #( .REGSIZE(REGSIZE) ) 
pht(
.clk 	 (clk),
.rstn	 (rstn),
.en  	 (bp_reg_wr),
.pcbranch     (pcbranch),
.pattern_addr (bhr_out),
.count   (count)        
);


endmodule

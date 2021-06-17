module registers(
input clk,
input rstn,
input write,
input [4:0] rs1_addr,
input [4:0] rs2_addr,
input [4:0] w_addr,
input [31:0]  w_data,
output reg [31:0] rs1_out_id2exe,
output reg [31:0] rs2_out_id2exe
);

//register array
//32 registers each of length 32
reg[31:0] reg_arr[0:31];

//rs1 and rs2 read
//rs1_addr and rs2_addr from idecoder
wire [31:0] rs1_out = reg_arr[rs1_addr]; 
wire [31:0] rs2_out = reg_arr[rs2_addr];

integer i;

always @(posedge clk)
begin
 rs1_out_id2exe <= rs1_out;
 rs2_out_id2exe <= rs2_out;
end



always @(posedge clk or negedge rstn)
begin

 if(~rstn)
   begin
     for(i = 0;i<32;i = i+1)
         reg_arr[i] <= 0;
   end
 else if(write)
    begin
	 i = 0; //to avoid ineferred latches.
    if (w_addr != 0)
           reg_arr[w_addr] <= w_data;
         end
end

endmodule

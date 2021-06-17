module exe #(parameter WIDTH=32)(
input wire clk,
input wire rstn,
input wire exe_wait,
input wire [31:0] imm,
input wire [1:0]  alu_b,
input wire [1:0]  alu_a,
input wire [3:0]  alu_cntr,
input wire [31:0] reg_source1,reg_source2,
input wire [31:0] pc_id2exe,
input wire [2:0]  branch_cntr,
input wire [1:0]  memtoreg_id2exe,
input wire [2:0]  ld_cntr_id2exe,
input wire [1:0]  st_cntr_id2exe,
input wire        reg_write_id2exe,
input wire [4:0]  wr_addr_id2exe,
input wire [6:0]  opcode_id2exe,
output reg [31:0] alu_result,
output reg [1:0]  memtoreg_exe2lsu,
output reg [2:0]  ld_cntr_exe2lsu,
output reg [1:0]  st_cntr_exe2lsu,
output reg [31:0] reg_source2_exe2lsu,
output reg [4:0]  wr_addr_exe2lsu,
output reg [6:0]  opcode_exe2lsu,
output reg reg_write_exe2lsu,
output reg ov_flag, 
output reg pcbranch,
output z_flag
);
//-------------------------------------------------------------------


reg  stall1;
reg  stall2;
wire overflow;
wire [31:0] result;

//ASSIGNING TO REGISTERS FOR PIPELINING

always@(posedge clk or negedge rstn)
begin

if(~rstn) begin
   stall1 <= 0;
   stall2 <= 0;
   memtoreg_exe2lsu <= 0;
   ld_cntr_exe2lsu <=  0;
   st_cntr_exe2lsu <= 0;
   ov_flag <= 0;
   alu_result <= 0;
   reg_source2_exe2lsu <= 0;
   reg_write_exe2lsu <= 0;
   wr_addr_exe2lsu <= 0;
   opcode_exe2lsu <= 0;
end

else begin
if (exe_wait|stall1)
  begin
   reg_write_exe2lsu <= 0;
   st_cntr_exe2lsu <= 0;
   if (stall1!=1) stall1 <= 1;
   else
   begin 
      if (stall2!=1) stall2 <= 1;
      else
      begin
         stall1 <= 0;
         stall2 <= 0;
      end
   end   
  end

else
  begin
   stall1 <= 0;
   stall2 <= 0;
   memtoreg_exe2lsu <= memtoreg_id2exe;
   ld_cntr_exe2lsu <=  ld_cntr_id2exe;
   st_cntr_exe2lsu <= st_cntr_id2exe;
   ov_flag <= overflow;
   alu_result <= result;
   reg_source2_exe2lsu <= reg_source2;
   reg_write_exe2lsu <= reg_write_id2exe;
   wr_addr_exe2lsu <= wr_addr_id2exe;
   opcode_exe2lsu <= opcode_id2exe;
  end

end
end
//-------------------------------------------------------------------

//SELECTION OF INPUT B

reg [31:0]b;

always@(*)
begin
case(alu_b)
   2'b00: b <= reg_source2;
   2'b01: b <= reg_source2 & 32'h0000001F;
   2'b10: b <= imm;
   2'b11: b <= 32'h00000004;
   default: b <= reg_source2;
endcase
end
//---------------------------------------------------------------------

//SELECTION OF INPUT A

reg [31:0]a;
 
always@(*)
begin
case(alu_a)
   2'b01: a <= 32'h00000000;
   2'b10: a <= pc_id2exe;
   2'b11: a <= reg_source1;
   default: a <= reg_source1;
endcase 
end
//-----------------------------------------------------------------------



//ALU

alu #(   .WIDTH(WIDTH)
) 
alu_inst(   .alu_cntr(alu_cntr),
      .a(a),
      .b(b),
      .o_flag(overflow),
      .z_flag(z_flag),
      .alu_result(result)
);


//--------------------------------------------------------------------------------

// BRANCH CONTROL

always@(posedge clk)
begin
   case(branch_cntr)
   3'b001:     pcbranch <= ({overflow,z_flag}==2'b01)? 1'b1:1'b0; //---------beq 
   3'b010:     pcbranch <= (z_flag == 1'b0)? 1'b1:1'b0;     //---------bne
   3'b011:     pcbranch <= ({overflow,z_flag} == 2'b10)? 1'b1:1'b0;  //---------blt,bltu
   3'b100:     pcbranch <= (overflow ==1'b0)? 1'b1:1'b0;    //---------bge,bgeu
   default: pcbranch <= 1'b0; 
   endcase
end

endmodule

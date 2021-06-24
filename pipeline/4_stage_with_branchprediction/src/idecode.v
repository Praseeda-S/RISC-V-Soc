/********************************************************************************************************
Github repo : https://github.com/Praseeda-S/RISC-V-Soc.git
Date : 20/04/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Design and Verification of Vriddhi: A RISC-V Core
Design name : Instruction Decode 
Module name : idecode
Description : Generates control signals after taking inputs from ROM and instruction fetch unit
********************************************************************************************************/

module idecode(
input wire clk,
input wire rstn,
input wire ide_wait,
input wire [31:0] instr,
input wire [31:0] pc_if2id,
input wire [4:0]  wr_addr,
input wire [6:0]  opcode,
output reg [1:0]  memtoreg_id2exe,
output reg [1:0]  st_cntr_id2exe,
output reg [2:0]  ld_cntr_id2exe,
output reg [1:0]  alu_a,
output reg [1:0]  alu_b,
output reg [3:0]  alu_cntr,
output reg [31:0] imm,
output reg [2:0]  branch_cntr,
output reg [31:0] pc_id2exe,
output reg [4:0]  wr_addr_id2exe,
output reg [6:0]  opcode_id2exe,
output reg reg_write,
output reg jal, jalr
);



// Immediate parsing
wire [31:0]Uimm = {instr[31:12],{12{1'b0}}};
wire [31:0]Iimm = {{20{instr[31]}},instr[31:20]};
wire [31:0]SBimm = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
wire [31:0]UJimm = {{12{instr[31]}},instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};
wire [31:0]Simm = {{20{instr[31]}}, instr[31:25],instr[11:7]};
wire [31:0]Shiftimm = {{27{1'b0}},Iimm[4:0]};


always@(posedge clk or negedge rstn)
begin

if(~rstn) begin
{reg_write,memtoreg_id2exe,st_cntr_id2exe,ld_cntr_id2exe,alu_a,alu_b,alu_cntr,imm,branch_cntr,jal,jalr} <= 52'd0;
pc_id2exe <= 32'h0;
wr_addr_id2exe <= 5'h0;
opcode_id2exe <= 7'h0;
end

else begin
if (ide_wait=== 1) //decoder stall
begin
   jal<=0;
   jalr<=0;
   branch_cntr <= 3'b000;
end

else begin

case(instr[6:0])

   7'b0000011: //-----------load---------------
         begin 
         {reg_write,memtoreg_id2exe,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1111110000001000;
         st_cntr_id2exe <= 2'b00;
         case(instr[14:12])
            3'b010:  ld_cntr_id2exe <= 3'b000;
            3'b001: ld_cntr_id2exe <= 3'b001;
            3'b000: ld_cntr_id2exe <= 3'b010;
            3'b101:  ld_cntr_id2exe <= 3'b011;
            3'b100:  ld_cntr_id2exe <= 3'b100;
            
         endcase
         imm <= Iimm;
         end

   7'b0100011: //-----------store----------------
         begin
         {reg_write,memtoreg_id2exe,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b0001110000001000;
         ld_cntr_id2exe <= 3'b000;
         case(instr[14:12])
            3'b010: st_cntr_id2exe <= 2'b01;
            3'b001: st_cntr_id2exe <= 2'b10;
            3'b000: st_cntr_id2exe <= 2'b11;
            default: st_cntr_id2exe <= 2'b00; 
         endcase
         imm <= Simm;   
         end

   7'b0110111: //-----------------lui----------------
         begin
         {reg_write,memtoreg_id2exe,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1010110000001000;
         st_cntr_id2exe <= 2'b00;
         ld_cntr_id2exe <= 3'b000;
         imm <= Uimm; 
         end

   7'b0010111: //-----------------auipc------------------
         begin
         {reg_write,memtoreg_id2exe,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1011010000001000;
         st_cntr_id2exe <= 2'b00;
         ld_cntr_id2exe <= 3'b000; 
         imm <= Uimm;
         end
   
   7'b0110011: //------------------R Type--------------------
         begin
         {reg_write,branch_cntr,jal,jalr} <= 6'b100000;
         st_cntr_id2exe <= 2'b00;
         ld_cntr_id2exe <= 3'b000;
         case(instr[14:12])
            3'b111:  //-----------AND  
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111001001;
               end
            
            3'b110:  //-----------OR
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111001011;
               end

            3'b100:  //-------------XOR
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111001010;
               end 

            3'b000:  //---------------ADD/SUB
               begin
               {memtoreg_id2exe,alu_a,alu_b} <= 6'b011100;
               case(instr[30])
                  1'b1: alu_cntr <= 4'b1100;
                  default: alu_cntr <= 4'b1000;
               endcase
               end

            3'b010:  //---------------SLT
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b1011001100;
               end

            3'b011:  //----------------SLTU
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b1011000100;
               end
            
            3'b001:  //--------------------SLL
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111011101;
               end

            3'b101:  //------------------SRL/SRA
               begin
               {memtoreg_id2exe,alu_a,alu_b} <= 6'b011101;
               case(instr[30])
                  1'b0: alu_cntr <= 4'b1110;
                  default: alu_cntr <= 4'b1111;
               endcase
               end
            default:begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111001000;
               end
         endcase
         end
   
   7'b0010011: //-----------------I Type--------------------
         begin
            {reg_write,branch_cntr,jal,jalr} <= 6'b100000;
            st_cntr_id2exe <= 2'b00;
            ld_cntr_id2exe <= 3'b000;
            case(instr[14:12])
            3'b111:  //-----------ANDi 
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111101001;
               imm <= Iimm;
               end
            
            3'b110:  //-----------ORi
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111101011;
               imm <= Iimm;
               end

            3'b100:  //-------------XORi
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111101010;
               imm <= Iimm;
               end 

            3'b000:  //---------------ADDi
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111101000;
               imm <= Iimm;
               end

            3'b010:  //---------------SLTi
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b1011101100;
               imm <= Iimm;
               end

            3'b011:  //----------------SLTiU
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b1011100100;
               imm <= Iimm;
               end
            
            3'b001:  //--------------------SLLi
               begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111101101;
               imm <= Shiftimm;
               end

            3'b101:  //------------------SRLi/SRAi
               begin
               {memtoreg_id2exe,alu_a,alu_b} <= 6'b011110;
               case(instr[30])
                  1'b0: alu_cntr <= 4'b1110;
                  default: alu_cntr <= 4'b1111;
               endcase
               imm <= Shiftimm;
               end
            default:begin
               {memtoreg_id2exe,alu_a,alu_b,alu_cntr} <= 10'b0111101000;
               imm <= Iimm;
               end
            endcase
         end
   
   7'b1100011: //-------------------branch------------------------
         begin
         {reg_write,memtoreg_id2exe,jal,jalr,alu_a,alu_b} <= 9'b001001100;
         st_cntr_id2exe <= 2'b00;
         ld_cntr_id2exe <= 3'b000;
         imm <= SBimm;
         case(instr[14:12])
            3'b000:  //----------------beq
               begin
               alu_cntr <= 4'b1100;
               branch_cntr <= 3'b001;
               end
            3'b001:  //---------------bne
               begin
               alu_cntr <= 4'b1100;
               branch_cntr <= 3'b010;
               end
            3'b100: //--------------------blt
               begin
               alu_cntr <= 4'b1100;
               branch_cntr <= 3'b011;
               end
            3'b101: //-------------------bge
               begin
               alu_cntr <= 4'b1100;
               branch_cntr <= 3'b100;
               end
            3'b110: //--------------------bltu
               begin
               alu_cntr <= 4'b0100;
               branch_cntr <= 3'b011;
               end
            3'b111:  //---------------------bgeu
               begin
               alu_cntr <= 4'b0100;
               branch_cntr <= 3'b100;
               end
         endcase
         end

   7'b1101111: //----------------------jal----------------
         begin
         {reg_write,memtoreg_id2exe,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1011011000101000;
         st_cntr_id2exe <= 2'b00;
         ld_cntr_id2exe <= 3'b000; 
         imm <= UJimm;
         end

   7'b1100111: //------------------jalR-----------------
         begin
         {reg_write,memtoreg_id2exe,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1011011000111000;
         st_cntr_id2exe <= 2'b00;
         ld_cntr_id2exe <= 3'b000; 
         imm <= Iimm;
         end
   default: {reg_write,memtoreg_id2exe,st_cntr_id2exe,ld_cntr_id2exe,alu_a,alu_b,alu_cntr,imm,branch_cntr,jal,jalr} <= 52'd0;

   
endcase
pc_id2exe <= pc_if2id;
wr_addr_id2exe <= wr_addr;
opcode_id2exe <= opcode;
end
end  
end

endmodule



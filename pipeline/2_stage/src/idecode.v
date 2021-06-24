module idecode(
input rstn,
input hold,
input [31:0]instr,
output reg reg_write,
output reg [1:0]memtoreg,
output reg [1:0]st_cntr,
output reg [2:0]ld_cntr,
output reg [1:0]alu_a,
output reg [1:0]alu_b,
output reg [3:0]alu_cntr,
output reg [31:0]imm,
output reg [2:0]branch_cntr,
output reg jal, jalr
);


// Immediate parsing
wire [31:0]Uimm = {instr[31:12],{12{1'b0}}};
wire [31:0]Iimm = {{20{instr[31]}},instr[31:20]};
wire [31:0]SBimm = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
wire [31:0]UJimm = {{12{instr[31]}},instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};
wire [31:0]Simm = {{20{instr[31]}}, instr[31:25],instr[11:7]};
wire [31:0]Shiftimm = {{27{1'b0}},Iimm[4:0]};


always@(*)
begin
if(~rstn) {reg_write,memtoreg,st_cntr,ld_cntr,alu_a,alu_b,alu_cntr,imm,branch_cntr,jal,jalr} <= 52'd0;

else if (hold === 1) {branch_cntr,jal,jalr} <= 5'b00000;

else begin

case(instr[6:0])

	7'b0000011:	//-----------load---------------
			begin	
			{reg_write,memtoreg,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1111110000001000;
			st_cntr <= 2'b00;
			case(instr[14:12])
				3'b010:	ld_cntr <= 000;
				3'b001: ld_cntr <= 001;
				3'b000: ld_cntr <= 010;
				3'b101:	ld_cntr <= 011;
				3'b100:	ld_cntr <= 100;
				
			endcase
			imm <= Iimm;
			end

	7'b0100011:	//-----------store----------------
			begin
			{reg_write,memtoreg,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b0001110000001000;
			ld_cntr <= 3'b000;
			case(instr[14:12])
				3'b010: st_cntr <= 2'b01;
				3'b001: st_cntr <= 2'b10;
				3'b000: st_cntr <= 2'b11;
				default: st_cntr <= 2'b00; 
			endcase
			imm <= Simm;	
			end

	7'b0110111:	//-----------------lui----------------
			begin
			{reg_write,memtoreg,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1010110000001000;
			st_cntr <= 2'b00;
			ld_cntr <= 3'b000;
			imm <= Uimm; 
			end

	7'b0010111:	//-----------------auipc------------------
			begin
			{reg_write,memtoreg,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1011010000001000;
			st_cntr <= 2'b00;
			ld_cntr <= 3'b000; 
			imm <= Uimm;
			end
	
	7'b0110011:	//------------------R Type--------------------
			begin
			{reg_write,branch_cntr,jal,jalr} <= 7'b100000;
			st_cntr <= 2'b00;
			ld_cntr <= 3'b000;
			case(instr[14:12])
				3'b111:	//-----------AND	
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111001001;
					end
				
				3'b110:	//-----------OR
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111001011;
					end

				3'b100:	//-------------XOR
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111001010;
					end 

				3'b000:	//---------------ADD/SUB
					begin
					{memtoreg,alu_a,alu_b} <= 6'b011100;
					case(instr[30])
						1'b1: alu_cntr <= 4'b1100;
						default: alu_cntr <= 4'b1000;
					endcase
					end

				3'b010:	//---------------SLT
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b1011001100;
					end

				3'b011:	//----------------SLTU
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b1011000100;
					end
				
				3'b001:	//--------------------SLL
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111011101;
					end

				3'b101:	//------------------SRL/SRA
					begin
					{memtoreg,alu_a,alu_b} <= 6'b011101;
					case(instr[30])
						1'b0:	alu_cntr <= 4'b1110;
						default: alu_cntr <= 4'b1111;
					endcase
					end
				default:begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111001000;
					end
			endcase
			end
	
	7'b0010011:	//-----------------I Type--------------------
			begin
				{reg_write,branch_cntr,jal,jalr} <= 6'b100000;
				st_cntr <= 2'b00;
				ld_cntr <= 3'b000;
				case(instr[14:12])
				3'b111:	//-----------ANDi	
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111101001;
					imm <= Iimm;
					end
				
				3'b110:	//-----------ORi
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111101011;
					imm <= Iimm;
					end

				3'b100:	//-------------XORi
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111101010;
					imm <= Iimm;
					end 

				3'b000:	//---------------ADDi
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111101000;
					imm <= Iimm;
					end

				3'b010:	//---------------SLTi
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b1011101100;
					imm <= Iimm;
					end

				3'b011:	//----------------SLTiU
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b1011100100;
					imm <= Iimm;
					end
				
				3'b001:	//--------------------SLLi
					begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111101101;
					imm <= Shiftimm;
					end

				3'b101:	//------------------SRLi/SRAi
					begin
					{memtoreg,alu_a,alu_b} <= 6'b011110;
					case(instr[30])
						1'b0:	alu_cntr <= 4'b1110;
						default: alu_cntr <= 4'b1111;
					endcase
					imm <= Shiftimm;
					end
				default:begin
					{memtoreg,alu_a,alu_b,alu_cntr} <= 10'b0111101000;
					imm <= Iimm;
					end
				endcase
			end
	
	7'b1100011:	//-------------------branch------------------------
			begin
			{reg_write,memtoreg,jal,jalr,alu_a,alu_b} <= 9'b001001100;
			st_cntr <= 2'b00;
			ld_cntr <= 3'b000;
			imm <= SBimm;
			case(instr[14:12])
				3'b000:	//----------------beq
					begin
					alu_cntr <= 4'b1100;
					branch_cntr <= 3'b001;
					end
				3'b001:	//---------------bne
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
				3'b111:	//---------------------bgeu
					begin
					alu_cntr <= 4'b0100;
					branch_cntr <= 3'b100;
					end
			endcase
			end

	7'b1101111:	//----------------------JAL----------------
			begin
			{reg_write,memtoreg,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1011011000101000;
			st_cntr <= 2'b00;
			ld_cntr <= 3'b000; 
			imm <= UJimm;
			end

	7'b1100111:	//------------------JALR-----------------
			begin
			{reg_write,memtoreg,alu_a,alu_b,branch_cntr,jal,jalr,alu_cntr} <= 16'b1011011000111000;
			st_cntr <= 2'b00;
			ld_cntr <= 3'b000; 
			imm <= Iimm;
			end
	
endcase

end
	
end

//IMMEDIATE DECODER

/*
case(Immc)
	3'b000: imm = Uimm;
	3'b001: imm = Iimm;
	3'b010: imm = SBimm;
	3'b011: imm = UJimm;
	3'b100: imm = Simm;
	3'b101: imm = Shiftimm;
	default: imm = Iimm;
endcase
*/

endmodule



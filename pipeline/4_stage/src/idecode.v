module idecode(
input 			clk,
input 			ide_wait,
input [31:0]		instr,
input [31:0]		pc_if2id,
input [4:0]		wr_addr,
output reg 		RegW,
output reg [1:0]	Memtoreg,
output reg [1:0]	St_cntr,
output reg [2:0]	Ld_cntr,
output reg [1:0]	ALUa,
output reg [1:0]	ALUb,
output reg [3:0]	ALU_cntr,
output reg [31:0]	imm,
output reg [2:0]	Branch_cntr,
output reg 		Jal, Jalr,
output reg [31:0]	pc_id2exe,
output reg [4:0]	wr_addr_id2exe
);
reg wait1 =0;
reg [2:0]Immc;

// Immediate parsing
wire [31:0]Uimm = {instr[31:12],{12{1'b0}}};
wire [31:0]Iimm = {{20{instr[31]}},instr[31:20]};
wire [31:0]SBimm = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
wire [31:0]UJimm = {{12{instr[31]}},instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};
wire [31:0]Simm = {{20{instr[31]}}, instr[31:25],instr[11:7]};
wire [31:0]Shiftimm = {{27{1'b0}},Iimm[4:0]};


always@(posedge clk)
begin
if (ide_wait=== 1) //decoder stall
begin
	Jal<=0;
	Jalr<=0;
        Branch_cntr <= 3'b000;
end
else
begin

case(instr[6:0])

	7'b0000011:	//-----------load---------------
			begin	
			{RegW,Memtoreg,ALUa,ALUb,Branch_cntr,Jal,Jalr,ALU_cntr} <= 16'b1111110000001000;
			St_cntr <= 2'b00;
			case(instr[14:12])
				3'b010:	Ld_cntr <= 000;
				3'b001: Ld_cntr <= 001;
				3'b000: Ld_cntr <= 010;
				3'b101:	Ld_cntr <= 011;
				3'b100:	Ld_cntr <= 100;
				
			endcase
			imm <= Iimm;
			end

	7'b0100011:	//-----------store----------------
			begin
			{RegW,Memtoreg,ALUa,ALUb,Branch_cntr,Jal,Jalr,ALU_cntr} <= 16'b0001110000001000;
			Ld_cntr <= 3'b000;
			case(instr[14:12])
				3'b010: St_cntr <= 2'b01;
				3'b001: St_cntr <= 2'b10;
				3'b000: St_cntr <= 2'b11;
				default: St_cntr <= 2'b00; 
			endcase
			imm <= Simm;	
			end

	7'b0110111:	//-----------------lui----------------
			begin
			{RegW,Memtoreg,ALUa,ALUb,Branch_cntr,Jal,Jalr,ALU_cntr} <= 16'b1010110000001000;
			St_cntr <= 2'b00;
			Ld_cntr <= 3'b000;
			imm <= Uimm; 
			end

	7'b0010111:	//-----------------auipc------------------
			begin
			{RegW,Memtoreg,ALUa,ALUb,Branch_cntr,Jal,Jalr,ALU_cntr} <= 16'b1011010000001000;
			St_cntr <= 2'b00;
			Ld_cntr <= 3'b000; 
			imm <= Uimm;
			end
	
	7'b0110011:	//------------------R Type--------------------
			begin
			{RegW,Branch_cntr,Jal,Jalr} <= 7'b100000;
			St_cntr <= 2'b00;
			Ld_cntr <= 3'b000;
			case(instr[14:12])
				3'b111:	//-----------AND	
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001001;
					end
				
				3'b110:	//-----------OR
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001011;
					end

				3'b100:	//-------------XOR
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001010;
					end 

				3'b000:	//---------------ADD/SUB
					begin
					{Memtoreg,ALUa,ALUb} <= 6'b011100;
					case(instr[30])
						1'b1: ALU_cntr <= 4'b1100;
						default: ALU_cntr <= 4'b1000;
					endcase
					end

				3'b010:	//---------------SLT
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b1011001100;
					end

				3'b011:	//----------------SLTU
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b1011000100;
					end
				
				3'b001:	//--------------------SLL
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111011101;
					end

				3'b101:	//------------------SRL/SRA
					begin
					{Memtoreg,ALUa,ALUb} <= 6'b011101;
					case(instr[30])
						1'b0:	ALU_cntr <= 4'b1110;
						default: ALU_cntr <= 4'b1111;
					endcase
					end
				default:begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001000;
					end
			endcase
			end
	
	7'b0010011:	//-----------------I Type--------------------
			begin
				{RegW,Branch_cntr,Jal,Jalr} <= 6'b100000;
				St_cntr <= 2'b00;
				Ld_cntr <= 3'b000;
				case(instr[14:12])
				3'b111:	//-----------ANDi	
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111101001;
					imm <= Iimm;
					end
				
				3'b110:	//-----------ORi
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111101011;
					imm <= Iimm;
					end

				3'b100:	//-------------XORi
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111101010;
					imm <= Iimm;
					end 

				3'b000:	//---------------ADDi
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111101000;
					imm <= Iimm;
					end

				3'b010:	//---------------SLTi
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b1011101100;
					imm <= Iimm;
					end

				3'b011:	//----------------SLTiU
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b1011100100;
					imm <= Iimm;
					end
				
				3'b001:	//--------------------SLLi
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111101101;
					imm <= Shiftimm;
					end

				3'b101:	//------------------SRLi/SRAi
					begin
					{Memtoreg,ALUa,ALUb} <= 6'b011110;
					case(instr[30])
						1'b0:	ALU_cntr <= 4'b1110;
						default: ALU_cntr <= 4'b1111;
					endcase
					imm <= Shiftimm;
					end
				default:begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111101000;
					imm <= Iimm;
					end
				endcase
			end
	
	7'b1100011:	//-------------------branch------------------------
			begin
			{RegW,Memtoreg,Jal,Jalr,ALUa,ALUb} <= 9'b001001100;
			St_cntr <= 2'b00;
			Ld_cntr <= 3'b000;
			imm <= SBimm;
			case(instr[14:12])
				3'b000:	//----------------beq
					begin
					ALU_cntr <= 4'b1100;
					Branch_cntr <= 3'b001;
					end
				3'b001:	//---------------bne
					begin
					ALU_cntr <= 4'b1100;
					Branch_cntr <= 3'b010;
					end
				3'b100: //--------------------blt
					begin
					ALU_cntr <= 4'b1100;
					Branch_cntr <= 3'b011;
					end
				3'b101: //-------------------bge
					begin
					ALU_cntr <= 4'b1100;
					Branch_cntr <= 3'b100;
					end
				3'b110: //--------------------bltu
					begin
					ALU_cntr <= 4'b0100;
					Branch_cntr <= 3'b011;
					end
				3'b111:	//---------------------bgeu
					begin
					ALU_cntr <= 4'b0100;
					Branch_cntr <= 3'b100;
					end
			endcase
			end

	7'b1101111:	//----------------------JAL----------------
			begin
			{RegW,Memtoreg,ALUa,ALUb,Branch_cntr,Jal,Jalr,ALU_cntr} <= 16'b1011011000101000;
			St_cntr <= 2'b00;
			Ld_cntr <= 3'b000; 
			imm <= UJimm;
			end

	7'b1100111:	//------------------JALR-----------------
			begin
			{RegW,Memtoreg,ALUa,ALUb,Branch_cntr,Jal,Jalr,ALU_cntr} <= 16'b1011011000111000;
			St_cntr <= 2'b00;
			Ld_cntr <= 3'b000; 
			imm <= Iimm;
			end
	
endcase
pc_id2exe <= pc_if2id;
wr_addr_id2exe <= wr_addr;
end
	
end

endmodule



module idecode(
input clk,
input [31:0]instr,
output reg RegW, MemW,
output reg [1:0]Memtoreg,
output reg [31:0]St_cntr,
output reg [1:0]Ld_cntr,
output reg [1:0]ALUa,
output reg [1:0]ALUb,
output reg [3:0]ALU_cntr,
output reg [31:0]imm,
output reg [2:0]Branch_cntr,
output reg Jal, Jalr
);

reg [2:0]Immc;
wire [31:0]Uimm = {instr[31:12],{12{1'b0}}};
wire [31:0]Iimm = {{20{instr[31]}},instr[31:20]};
wire [31:0]SBimm = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
wire [31:0]UJimm = {{12{instr[31]}},instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};
wire [31:0]Simm = {{20{instr[31]}}, instr[30:25],instr[11:8],instr[7]};
wire [31:0]Shiftimm = {{27{1'b0}},Imm[4:0]};


always@(posedge clk)
begin

case(instr[6:0])

	7'b0000011:	//-----------load---------------
			begin	
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10111110001000001000;
			St_cntr <= 32'h00000000;
			case(instr[14:12])
				3'b001: Ld_cntr <= 01;
				3'b000: Ld_cntr <= 10;
				default: Ld_cntr <= 00;
			endcase
			end

	7'b0100011:	//-----------store----------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b01001110100000001000;
			Ld_cntr <= 2'b00;
			case(instr[14:12])
				3'b010: St_cntr <= 32'h11111111;
				3'b001: St_cntr <= 32'h00001111;
				3'b000: St_cntr <= 32'h00000011;
				default: St_cntr <= 32'h00000000; 
			endcase	
			end

	7'b0110111:	//-----------------lui----------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10010110000000001000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 2'b00; 
			end

	7'b0010111:	//-----------------auipc------------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10011010000000001000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 2'b00; 
			end
	
	7'b0110011:	//------------------R Type--------------------
			begin
			{RegW,MemW,Immc,Branch_cntr,Jal,Jalr} <= 10'b1000000000;
			St_cntr <= 32'h00000000;
			case(instr[14:12])
				3'b111:	//-----------AND	
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001001;
					Ld_cntr <= 2'b00;
					end
				
				3'b110:	//-----------OR
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001011;
					Ld_cntr <= 2'b00;
					end

				3'b100:	//-------------XOR
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001010;
					Ld_cntr <= 2'b00;
					end 

				3'b000:	//---------------ADD/SUB
					begin
					{Memtoreg,ALUa,ALUb} <= 6'b011100;
					Ld_cntr <= 2'b00;
					case(instr[30])
						1'b1: ALU_cntr <= 4'b1100;
						default: ALU_cntr <= 4'b1000;
					endcase
					end

				3'b010:	//---------------SLT
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b1011001100;
					Ld_cntr <= 2'b00;
					end

				3'b011:	//----------------SLTU
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b1011000100;
					Ld_cntr <= 2'b00;
					end
				
				3'b001:	//--------------------SLL
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111011101;
					Ld_cntr <= 2'b00;
					end

				3'b101:	//------------------SRL/SRA
					begin
					{Memtoreg,ALUa,ALUb} <= 6'b011101;
					Ld_cntr <= 2'b00;
					case(instr[30])
						1'b0:	ALU_cntr <= 4'b1110;
						default: ALU_cntr <= 4'b1111;
					endcase
					end
				default:begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111001000;
					Ld_cntr <= 2'b00;
					end
			endcase
			end
	
	7'b0010011:	//-----------------I Type--------------------
			begin
				{RegW,MemW,Branch_cntr,Jal,Jalr} <= 7'b1000000;
				St_cntr <= 32'h00000000;
				case(instr[14:12])
				3'b111:	//-----------ANDi	
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0111100011001;
					Ld_cntr <= 2'b00;
					end
				
				3'b110:	//-----------ORi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0111100011011;
					Ld_cntr <= 2'b00;
					end

				3'b100:	//-------------XORi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0111100011010;
					Ld_cntr <= 2'b00;
					end 

				3'b000:	//---------------ADDi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0111100011000;
					Ld_cntr <= 2'b00;
					end

				3'b010:	//---------------SLTi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b1011100011100;
					Ld_cntr <= 2'b00;
					end

				3'b011:	//----------------SLTiU
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b1011100010100;
					Ld_cntr <= 2'b00;
					end
				
				3'b001:	//--------------------SLLi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0111101011101;
					Ld_cntr <= 2'b00;
					end

				3'b101:	//------------------SRLi/SRAi
					begin
					{Memtoreg,ALUa,ALUb,Immc} <= 9'b011110101;
					Ld_cntr <= 2'b00;
					case(instr[30])
						1'b0:	ALU_cntr <= 4'b1110;
						default: ALU_cntr <= 4'b1111;
					endcase
					end
				default:begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0111100011000;
					Ld_cntr <= 2'b00;
					end
				endcase
			end
	
	7'b1100011:	//-------------------branch------------------------
			begin
			{RegW,MemW,Memtoreg,Immc,Jal,Jalr,ALUa,ALUb} <= 13'b0001010001100;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 2'b00;
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
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10011011011000101000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 2'b00; 
			end

	7'b1100111:	//------------------JALR-----------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10011011001000111000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 2'b00; 
			end
	
endcase	

//IMMEDIATE DECODER

case(Immc)
	3'b000: imm = Uimm;
	3'b001: imm = Iimm;
	3'b010: imm = SBimm;
	3'b011: imm = UJimm;
	3'b100: imm = Simm;
	3'b101: imm = Shiftimm;
	default: imm = Iimm;
endcase

end
endmodule



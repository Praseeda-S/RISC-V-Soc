module idecode(
input [31:0]instr,
output reg RegW, MemW,
output reg [1:0]Memtoreg,
output reg [31:0]St_cntr,
output reg Ld_cntr,
output reg [1:0]ALUa,
output reg [2:0]ALUb,
output reg [1:0]ALU_cntr,
output reg [31:0]imm,
output reg Branch_cntr, Jal, Jalr
);

wire [2:0]Immc;
wire [31:0]Uimm = {[31:12]instr,12{1'b0}};
wire [31:0]Iimm = {20{instr[31]},[31:20]instr};
wire [31:0]SBimm = {20{instr[31]},instr[7],instr[30:25],instr[11:8],1'b0};
wire [31:0]UJimm = {12{instr[31]},instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};
wire [31:0]Simm = {20{instr[31]}, instr[30:25],instr[11:8],instr[7]};
wire [31:0]Shiftimm = {27{1'b0},Imm[4:0]};


always@(*)
begin

case(instr[6:0])

	7'b0000011:	//-----------load---------------
			begin	
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10111101000100000000;
			St_cntr <= 32'h00000000;
			case(instr[14:12])
				3'b101: Ld_cntr <= 1;
				3'b100: Ld_cntr <= 1;
				default: Ld_cntr <= 0;
			endcase
			end

	7'b0100011:	//-----------store----------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b01001101010000000000;
			Ld_cntr <= 1'b0;
			case(instr[14:12])
				3'b010: St_cntr <= 32'h11111111;
				3'b001: St_cntr <= 32'h00001111;
				3'b000: St_cntr <= 32'h00000011;
				default: St_cntr <= 32'h00000000; 
			endcase	
			end

	7'b0110111:	//-----------------lui----------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10000101000000000000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 1'b0; 
			end

	7'b0010111:	//-----------------auipc------------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10001010100000000000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 1'b0; 
			end
	
	7'b0110011:	//------------------R Type--------------------
			begin
			{RegW,MemW,Immc,Branch_cntr,Jal,Jalr} <= 10'b1000000000;
			St_cntr <= 32'h00000000;
			case(instr[14:12])
				3'b111:	//-----------AND	
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0011000001;
					Ld_cntr <= 1'b0;
					end
				
				3'b110:	//-----------OR
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0011000011;
					Ld_cntr <= 1'b0;
					end

				3'b100:	//-------------XOR
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0011000010;
					Ld_cntr <= 1'b0;
					end 

				3'b000:	//---------------ADD/SUB
					begin
					{Memtoreg,ALUa,ALUb} <= 7'b0011000;
					Ld_cntr <= 1'b0;
					case(instr[30])
						1'b1: ALU_cntr <= 3'b100;
						default: ALU_cntr <= 3'b000;
					endcase
					end

				3'b010:	//---------------SLT
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0111000100;
					Ld_cntr <= 1'b1;
					end

				3'b011:	//----------------SLTU
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0100100100;
					Ld_cntr <= 1'b1;
					end
				
				3'b001:	//--------------------SLL
					begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0011001101;
					Ld_cntr <= 1'b0;
					end

				3'b101:	//------------------SRL/SRA
					begin
					{Memtoreg,ALUa,ALUb} <= 7'b0011001;
					Ld_cntr <= 1'b0;
					case(instr[30])
						1'b0:	ALU_cntr <= 3'b110;
						default: ALU_cntr <= 3'b111;
					endcase
					end
				default:begin
					{Memtoreg,ALUa,ALUb,ALU_cntr} <= 10'b0011000000;
					Ld_cntr <= 1'b0;
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
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0011010001001;
					Ld_cntr <= 1'b0;
					end
				
				3'b110:	//-----------ORi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0011010001011;
					Ld_cntr <= 1'b0;
					end

				3'b100:	//-------------XORi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0011010001010;
					Ld_cntr <= 1'b0;
					end 

				3'b000:	//---------------ADDi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0011010001000;
					Ld_cntr <= 1'b0;
					end

				3'b010:	//---------------SLTi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0111010001100;
					Ld_cntr <= 1'b1;
					end

				3'b011:	//----------------SLTiU
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0100110001100;
					Ld_cntr <= 1'b1;
					end
				
				3'b001:	//--------------------SLLi
					begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0011010101101;
					Ld_cntr <= 1'b0;
					end

				3'b101:	//------------------SRLi/SRAi
					begin
					{Memtoreg,ALUa,ALUb,Immc} <= 10'b0011010101;
					Ld_cntr <= 1'b0;
					case(instr[30])
						1'b0:	ALU_cntr <= 3'b110;
						default: ALU_cntr <= 3'b111;
					endcase
					end
				default:begin
					{Memtoreg,ALUa,ALUb,Immc,ALU_cntr} <= 13'b0011010001000;
					Ld_cntr <= 1'b0;
					end
				endcase
			end
	
	7'b1100011:	//-------------------branch------------------------
			begin
			{RegW,MemW,Memtoreg,Immc,Jal,Jalr,ALU_cntr} <= 12'b000001000100;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 1'b0;
			case(instr[14:12])
				3'b000:	//----------------beq
					begin
					{ALUa,ALUb} <= 5'b11000;
					Branch_cntr <= 3'b001;
					end
				3'b001:	//---------------bne
					begin
					{ALUa,ALUb} <= 5'b11000;
					Branch_cntr <= 3'b010;
					end
				3'b100: //--------------------blt
					begin
					{ALUa,ALUb} <= 5'b11000;
					Branch_cntr <= 3'b011;
					end
				3'b101: //-------------------bge
					begin
					{ALUa,ALUb} <= 5'b11000;
					Branch_cntr <= 3'b100;
					end
				3'b110: //--------------------bltu
					begin
					{ALUa,ALUb} <= 5'b00011;
					Branch_cntr <= 3'011;
					end
				3'b111:	//---------------------bgeu
					begin
					{ALUa,ALUb} <= 5'b00011;
					Branch_cntr <= 3'b100;
					end
			endcase
			end

	7'b1101111:	//----------------------JAL----------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10001001101100010000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 1'b0; 
			end

	7'b1100111:	//------------------JALR-----------------
			begin
			{RegW,MemW,Memtoreg,ALUa,ALUb,Immc,Branch_cntr,Jal,Jalr,ALU_cntr} <= 20'b10001001100100011000;
			St_cntr <= 32'h00000000;
			Ld_cntr <= 1'b0; 
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



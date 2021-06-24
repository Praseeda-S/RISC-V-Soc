module alu #(parameter WIDTH=32)(
input  			[3:0]		alu_cntr,
input signed  		[WIDTH-1:0] 	a, b,
output  				o_flag,
output					z_flag,
output reg 		[WIDTH-1:0] 	alu_result);

wire [WIDTH-1:0] unsigned_in_a = $unsigned(a);
wire [WIDTH-1:0] unsigned_in_b = $unsigned(b);

reg slt_reg;

assign z_flag = (alu_result == 0)? 1:0;
assign o_flag = (alu_cntr[2:0] == 3'b100)? slt_reg : 0;


always@(*)
begin
case(alu_cntr[3])
1'b0:	//-----------------------------UNSIGNED OPERATIONS [sltiu, sltu, bgeu, bltu]
	begin
	if (alu_cntr[2:0] == 3'b100)
		alu_result <= unsigned_in_a - unsigned_in_b;
		slt_reg <= (unsigned_in_a < unsigned_in_b);	
	end
1'b1:	//-------------------------------SIGNED OPERATIONS
	begin 
	case(alu_cntr[2:0])
		3'b000:	alu_result <= a + b;
		3'b001: alu_result <= a & b;
		3'b010:	alu_result <= a ^ b;
		3'b011:	alu_result <= a | b;
		3'b100:	begin 
			alu_result <= a - b;
			slt_reg <= (a < b);
			end
		3'b101:	alu_result <= a << b;
		3'b110:	alu_result <= a >> b;
		3'b111:	alu_result <= a >>> b;
	endcase
	end
endcase
end
endmodule


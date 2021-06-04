//this module contains total 3 output and  3 inputs
//this module contains total 3 output and  3 inputs

module alu (
input  			[3:0]		alu_cntr,//ok
input signed  		[31:0] 	a, b, //fomr alu_a and alu_b
output  				o_flag,//ok towards branch cntl unit
output					z_flag, //ok towards btanch cntl unit
output reg 		[31:0] 	alu_result); //ok towards 

wire [31:0] unsigned_in_a = $unsigned(a);
wire [31:0] unsigned_in_b = $unsigned(b);

reg slt_reg;

assign z_flag = (alu_result == 0)? 1:0;
 // assign z_flag = (alu_result == )
assign o_flag = (alu_cntr[2:0] == 3'b100)? slt_reg : 0;

  
  

always@(a or b or alu_cntr)
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
					3'b001: alu_result <= a & b;//1001(rtl), 0000(book)
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



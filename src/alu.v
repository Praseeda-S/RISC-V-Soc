module alu #(parameter WIDTH=32)(
input wire [3:0]	alu_cntr,
input wire [WIDTH-1:0] 	a, b,
output     [1:0]	status,
output     [WIDTH-1:0] 	alu_result);

wire signed [WIDTH:0]in_a = {1'b0,a};
wire signed [WIDTH:0]in_b = {1'b0,b};

wire [WIDTH:0] unsigned_in_a = {1'b0,a};
wire [WIDTH:0] unsigned_in_b = {1'b0,b};

reg [WIDTH:0] alu_out;

assign alu_result = alu_out[WIDTH-1:0]; 
assign status[0] = alu_result == {WIDTH{1'b0}};
assign status[1] = alu_out[WIDTH];

always@(a or b or alu_cntr)
begin
case(alu_cntr[3])
1'b0:	//-----------------------------UNSIGNED OPERATIONS [sltiu, sltu, bgeu, bltu]
	begin
	if (alu_cntr[2:0] == 3'b100)
		alu_out <= unsigned_in_a - unsigned_in_b;	
	end
1'b1:	//-------------------------------SIGNED OPERATIONS
	case(alu_cntr[2:0])
		3'b000:	alu_out <= in_a + in_b;
		3'b001: alu_out <= in_a & in_b;
		3'b010:	alu_out <= in_a ^ in_b;
		3'b011:	alu_out <= in_a | in_b;
		3'b100:	alu_out <= in_a - in_b;
		3'b101:	alu_out <= in_a << in_b;
		3'b110:	alu_out <= in_a >> in_b;
		3'b111:	alu_out <= in_a >>> in_b;
	endcase

endcase
end
endmodule


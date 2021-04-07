module alu #(parameter WIDTH=32)(
input wire [3:0] alu_cntr,
input wire [WIDTH-1:0] a, b,
output reg [1:0]status,
output reg [WIDTH-1:0] alu_out);

wire signed [WIDTH-1:0]in_a;
wire signed [WIDTH-1:0]in_b;

assign in_a = a;
assign in_b = b;

wire [WIDTH:0]temp1;
assign temp1 = {1'b0, in_a} + {1'b0, in_b};

always@(a or b or alu_cntr)
begin
case(alu_cntr[3])
1'b0:	//-----------------------------UNSIGNED OPERATIONS [sltiu, sltu, bgeu, bltu]
	begin
	if (alu_cntr[2:0] == 3'b100)
		begin
		alu_out <= a - b;
		status[1] <= a < b; 
		status[0] <= (alu_out == {WIDTH{1'b0}});

		end
	else
		begin
		end	
	end
1'b1:	//-------------------------------SIGNED OPERATIONS
	case(alu_cntr[2:0])
		3'b000:
			begin
			alu_out <= temp1[WIDTH-1:0];
			status[1] <= temp1[WIDTH];
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		3'b001: 
			begin
			alu_out <= in_a & in_b;
			status[1] <= 1'b0;
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		3'b010:
			begin
			alu_out <= in_a ^ in_b;
			status[1] <= 1'b0;
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		3'b011:
			begin
			alu_out <= in_a | in_b;
			status[1] <= 1'b0;
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		3'b100: 
			begin
			alu_out <= in_a - in_b;
			status[1] <= in_a < in_b; 
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		3'b101:
			begin
			alu_out <= in_a << in_b;
			status[1] <= 1'b0;
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		3'b110: 
			begin
			alu_out <= in_a >> in_b;
			status[1] <= 1'b0;
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		3'b111:
			begin
			alu_out <= in_a >>> in_b;
			status[1] <= 1'b0;
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
		default:
			begin
			alu_out <= {WIDTH{1'b0}};
			status[1] <= 1'b0;
			status[0] <= (alu_out == {WIDTH{1'b0}});
			end
	endcase


endcase
end
endmodule


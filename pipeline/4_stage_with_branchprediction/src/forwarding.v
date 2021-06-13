//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine

module forwarding(
input 		  clk,
input wire [31:0] memtoreg_data,
input wire [1:0]  rs1_hazard,
input wire [1:0]  rs2_hazard,
input wire [31:0] result,
input wire [31:0] rs1,
input wire [31:0] rs2,

output reg [31:0] rs1_input,
output reg [31:0] rs2_input
);

wire [1:0] rs1_haz, rs2_haz;

always @(*)
begin 

case (rs1_hazard)
	2'b00: rs1_input <= rs1;
	2'b01: rs1_input <= result;
	2'b10: rs1_input <= memtoreg_data;
	default: rs1_input <= 32'h00000000;
endcase	

case (rs2_hazard)
	2'b00: rs2_input <= rs2;
	2'b01: rs2_input <= result;
	2'b10: rs2_input <= memtoreg_data;
	default: rs2_input <= 32'h00000000;

endcase	

end

endmodule

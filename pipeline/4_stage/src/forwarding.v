module forwarding(
input 		  rstn,
input wire [31:0] memtoreg_data,
input wire [1:0]  rs1_hazard,
input wire [1:0]  rs2_hazard,
input wire [31:0] result,
input wire [31:0] rs1,
input wire [31:0] rs2,

output reg [31:0] rs1_fwd2exe,
output reg [31:0] rs2_fwd2exe
);

wire [1:0] rs1_haz, rs2_haz;

always @(*)
begin 
if (~rstn) begin
 rs1_fwd2exe <= 0;
 rs2_fwd2exe <= 0;
end

else begin
case (rs1_hazard)
	2'b00:
	rs1_fwd2exe <= rs1;
	
	2'b01:
	rs1_fwd2exe <= result;
	
	2'b10:
	rs1_fwd2exe <= memtoreg_data;
        
        default: rs1_fwd2exe <= rs1;
endcase	

case (rs2_hazard)
	2'b00:
	rs2_fwd2exe <= rs2;
	
	2'b01:
	rs2_fwd2exe <= result;
	
	2'b10:
	rs2_fwd2exe <= memtoreg_data;

	default: rs2_fwd2exe <= rs2;
endcase
	
end
end

endmodule

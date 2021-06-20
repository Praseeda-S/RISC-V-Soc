/*************************************************************************************************************
Github repo : 313849252
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering, Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : Forward unit
Module name : forwarding
Description : Forwards the result of ALU operation from execute or writeback stage to a dependent instruction
*************************************************************************************************************/

module forwarding(
input clk,
input rstn,
input wire [31:0] memtoreg_data,
input wire [1:0]  rs1_hazard,
input wire [1:0]  rs2_hazard,
input wire [31:0] alu_result,
input wire [31:0] rs1,
input wire [31:0] rs2,
input wire        store_load_hazard,
input wire [31:0] store_value,
output reg [31:0] rs1_fwd2exe,
output reg [31:0] rs2_fwd2exe,
output reg [31:0] w_data
);

wire [1:0] rs1_haz, rs2_haz;
reg  [31:0] store_value_reg;

always @(*)
begin 

case (rs1_hazard)
   2'b00: rs1_fwd2exe <= rs1;
   2'b01: rs1_fwd2exe <= alu_result;
   2'b10: rs1_fwd2exe <= memtoreg_data;
   default: rs1_fwd2exe <= 32'h00000000;
endcase  

case (rs2_hazard)
   2'b00: rs2_fwd2exe <= rs2;
   2'b01: rs2_fwd2exe <= alu_result;
   2'b10: rs2_fwd2exe <= memtoreg_data;
   default: rs2_fwd2exe <= 32'h00000000;

endcase  

case(store_load_hazard)
   1'b0: w_data <= store_value_reg;
   1'b1: w_data <= memtoreg_data;
   default: w_data <= 32'h00000000;
endcase

end

always @(posedge clk or negedge rstn)
begin
if(~rstn) begin
store_value_reg <= 32'h00000000;
end
else begin
store_value_reg <= store_value;
end
end

endmodule

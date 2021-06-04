interface alu_intf(input logic clk, rstn);
	
       	logic [3:0]alu_cntr;
	logic [31:0]a;
	logic [31:0]b;

	logic        o_flag;
	logic        z_flag;
	logic  [31:0]alu_result;

	clocking alu_cb@(posedge clk);
		default output #1;
		output alu_cntr, a, b;
		input o_flag, z_flag, alu_result;
	endclocking

	modport dut(input alu_cntr, a, b, output o_flag, z_flag, alu_result);
  	modport mon(input alu_cntr, a, b,o_flag, z_flag, alu_result);


endinterface


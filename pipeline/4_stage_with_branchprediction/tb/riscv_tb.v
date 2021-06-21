/******************************************************************************************************************************************************************************
Github repo : 313849252
Date : 20/05/2021
Authors : Praseeda S, Sanjana AR, Parvathy PH, Anna Sebastine
College Name : College of Engineering Trivandrum
Project Name : Vriddhi : Design and Verification of RISC-V core
Design name : RISC-V Testbench 
Module name : riscv_tb
Description : Inputs signals for the coordinated sequential simulation of proposed design without the need of any hardware and opens dump file for storing the state of design
******************************************************************************************************************************************************************************/

module riscv_tb(output out);

reg  clk = 1'b0;
reg  rstn;
wire [7:0] gpio;

assign out=1'b0;

riscv32b_fpga fpga0(
.clk  (clk),
.rstn (rstn),
.gpio_o  (gpio)
);

always #2 clk = ~clk;

initial
begin
 $dumpfile("riscv.vcd");
 $dumpvars(0, riscv_tb);
 rstn = 1'b0;
 repeat(10) @(posedge clk);
 #1;
 rstn = 1'b1;
 repeat(1000) @(posedge clk);
 $finish;
end

endmodule

//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine

module riscv_tb;

reg clk = 1'b0;
reg rstn;
wire [7:0] gpio;

riscv32b_fpga fpga0(
.clk	(clk),
.rstn	(rstn),
.gpio_o	(gpio)
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

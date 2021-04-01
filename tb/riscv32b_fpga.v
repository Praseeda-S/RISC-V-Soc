module riscv32b_fpga(
input clk,
input rstn,
output gpio_o
);

wire [31:0] instr_addr;
wire instr_rd;
wire [31:0] instr;
wire [31:0] data_addr;
wire datamem_rd;
wire datamem_wr;
wire [31:0] data_rd;
wire [31:0] data_wr;
wire mem_en = ((datamem_wr | datamem_rd) && data_addr[31:10] == 0)? 1'b1:1'b0;
wire gpio_en = ((datamem_wr | datamem_rd) && data_addr[31:10] == 1)? 1'b1:1'b0;




riscv32b cpu0(
.clk		(clk)
.rstn		(rstn)
.instr_addr	(instr_addr)
.instr_rd	(instr_rd)
.instr_in	(instr)
.data_addr	(data_addr)
.datamem_rd	(datamem_rd)
.datamem_wr	(datamem_wr)
.data_in	(data_rd)
.data_out	(data_wr)
);

rom  r0(
.clk		(clk)
.addr_in	(instr_addr)
.data_out	(instr)
);

ram  rm0(
.clk		(clk)
.mem_wr		(datamem_wr)
.mem_en		(mem_en)
.addr		(data_addr)
.data_rd	(data_rd)
.data_wr 	(data_wr)
);

)reg [7:0] gpio_reg;

always@(posedge clk or negedge rstn)
 if (~rstn)
   gpio_reg <= 0;
 else if(datamem_wr & gpio_en)
   gpio_reg <= data_wr[7:0];
assign gpio = gpio_reg;


endmodule

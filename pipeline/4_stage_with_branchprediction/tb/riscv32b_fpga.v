//Owned by Praseeda S, Parvathy PH, Sanjana AR and Anna Sebastine
module riscv32b_fpga(
input clk,
input rstn,
output [7:0] gpio_o
);

wire [31:0] instr_addr;
wire [31:0] instr;
wire [31:0] data_addr;
wire [3:0]  datamem_wr;
wire [31:0] data_rd;
wire [7:0]  data_wr0;
wire [7:0]  data_wr1;
wire [7:0]  data_wr2;
wire [7:0]  data_wr3;

wire mem_en = 1;
wire gpio_en = (data_addr[31:10] == 1)? 1'b1:1'b0;

riscv32b cpu0(
.clk   (clk),
.rstn  (rstn),
.instr_addr (instr_addr),
.instr_in   (instr),
.data_addr  (data_addr),
.datamem_wr (datamem_wr),
.data_in    (data_rd),
.data_out0  (data_wr0),
.data_out1  (data_wr1),
.data_out2  (data_wr2),
.data_out3  (data_wr3)
);
ram  rm0(
.clk   (clk),
.rstn  (rstn),
.mem_wr     (datamem_wr),
.mem_en     (mem_en),
.addr       (data_addr),
.data_rd    (data_rd),
.data_wr0   (data_wr0),
.data_wr1   (data_wr1),
.data_wr2   (data_wr2),
.data_wr3   (data_wr3)
);

rom  r0(
.clk   (clk),
.addr_in    (instr_addr),
.data_out   (instr)
);


reg [7:0] gpio_reg;

always@(posedge clk or negedge rstn)
begin
 if (~rstn)
   gpio_reg <= 0;
 else if(datamem_wr[0] & gpio_en)
   gpio_reg <= data_wr0;
end

assign gpio_o = gpio_reg;


endmodule

module uart_tb();
  parameter clk_bit=87;
  parameter bit_period=8700;
  
  reg i_data=1'b1;
  reg i_clk=1'b0;
  wire [7:0] rx_data;
  
  
  
   task rx_check;
    input [7:0] k;
    integer i;
    
    begin
      i_data<=1'b0;
      #(bit_period);
      for(i=0;i<8;i=i+1)
        begin
          i_data<=k[i];
          #(bit_period);
        end
      i_data<=1'b1;
      #(bit_period);
    end
  endtask
  uart_rx #(.clk_bit(clk_bit)) uart_rx_inst 
  (.i_clk(i_clk),
   .i_data(i_data),
   .data(rx_data),
   .data_valid()
  );

  
  always
	  #50 i_clk<=!i_clk;
 
  initial
    begin
	    @(posedge i_clk);
	    rx_check(8'h56);
	    @(posedge i_clk);
	    
	    if(rx_data==8'h56)
		    $display("correct");
	    else
		    $display("incorrect");
	    $finish;
    end


  initial
  begin
	  $dumpfile("uart_tb.vcd");
	  $dumpvars(0,uart_tb);
  end
endmodule
      
          
          



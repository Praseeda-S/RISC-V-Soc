module uart_rx
#(parameter clk_bit=87)
  (input i_clk,
   input i_data,
   output[7:0] data,
   output reg data_valid
  );
  parameter idle=3'b000;
  parameter start_bit=3'b001;
  parameter data_bit=3'b010;
  parameter stop_bit=3'b011;
  parameter clean_up=3'b100;
  reg [7:0] op=0;
  reg [2:0] op_count=0;
  reg [7:0] clk_count=0;
  reg [2:0] state_check=0;
  
  
  always @(posedge i_clk)
    begin
      case(state_check)
        idle:
          begin
            clk_count<=0;
            data_valid<=1'b0;
            op_count<=0;
            if(i_data==1'b0)
              state_check<=start_bit;
            else
              state_check<=idle;
          end
        start_bit: /*start state*/
          begin
            if(clk_count==(clk_bit-1)/2)
              begin
                if(i_data==0)
                  begin 
                    state_check<=data_bit;
                    clk_count<=0;
                  end
                else
                  state_check<=idle;
              end
            else
              begin
                clk_count<=clk_count+1;
                state_check<=start_bit;
              end
          end
        data_bit:
          begin
            if(clk_count<clk_bit-1)
              begin 
                clk_count<=clk_count+1;
                state_check<=data_bit;
              end
            else
              begin
                clk_count<=0;
                op[op_count]<=i_data;
                if(op_count<7)
                  begin
                    op_count<=op_count+1;
                    state_check<=data_bit;
                  end
                else
                  state_check<=stop_bit;
              end
          end
        stop_bit:
          begin
            if(clk_count<clk_bit-1)
              begin
                clk_count<=clk_count+1;
                state_check<=stop_bit;
              end
            else
              begin
                clk_count<=0;
                state_check<=clean_up;
		data_valid<=1'b1;
                
              end
          end
        clean_up:
          begin
            state_check<=idle;
            data_valid<=1'b0;
            clk_count<=0;
          end
        default:
          state_check=idle;
      endcase
    end
  assign data=op;
endmodule
            
                
            
            
              
                
            
        
        
  

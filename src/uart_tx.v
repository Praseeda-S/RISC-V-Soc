module uart_tx
  #(parameter clk_bit=87)
  (input i_clk,
   input data_valid,
   input [7:0] data,
   output reg serial_op,
   output reg done,
   output reg active
  );
  parameter idle=3'b000;
  parameter start_bit=3'b001;
  parameter data_bit=3'b010;
  parameter stop_bit=3'b011;
  parameter clean_up=3'b100;
  
  reg[2:0] state_check=0;
  reg[7:0] clk_count=0;
  reg[2:0] bit_count=0;
  
  always @(posedge i_clk)
    begin
      case(state_check)
        idle:
          begin
            clk_count<=0;
            bit_count<=0;
            serial_op<=1'b1;
            done<=1'b0;
            if(data_valid==1'b1)
              begin
                active<=1'b1;//active until stop bit
                state_check<=start_bit;
              end
            else
              state_check<=idle;
          end
        start_bit:
          begin
            serial_op<=1'b0;
            if(clk_count<clk_bit-1)
              begin
                clk_count<=clk_count+1;
                state_check<=start_bit;
              end
            else
              begin
                clk_count<=0;
                state_check<=data_bit;
              end
          end
        data_bit:
          begin
            serial_op<=data[bit_count];
            if(clk_count<clk_bit-1)
              begin
                clk_count<=clk_count+1;
                state_check<=data_bit;
              end
            else
              begin
                clk_count<=0;
                if(bit_count<7)
                  begin
                    bit_count<=bit_count+1;
                    state_check<=data_bit;
                  end
                else
                  state_check<=stop_bit;
              end
          end
        stop_bit:
          begin
            serial_op<=1'b1;
            if(clk_count<clk_bit-1)
              begin
                clk_count=clk_count+1;
                state_check<=stop_bit;
              end
            else
              begin
                clk_count<=0;
                state_check<=clean_up;
                active<=1'b0;
                done<=1'b1;
              end
          end
        clean_up:
          begin
            done<=1'b1;
            state_check<=idle;
          end
        default:
          state_check<=idle;
      endcase
    end
endmodule
            
                
  

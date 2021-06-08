class alu_scbd extends uvm_scoreboard;
	`uvm_component_utils(alu_scbd)
	function new(string name="alu_scbd", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	uvm_analysis_imp#(alu_pkt, alu_scbd) m_analysis_imp;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_analysis_imp = new("m_analysis_imp",this);
	endfunction
		bit z_flag_exp;
		bit o_flag_exp;
  bit [31:0] alu_result_exp;
 // pkt.z_flag = 'b1;
  int count = 0;
      int testcase_passed = 0;
      int testcase_failed = 0;
	virtual task write(alu_pkt pkt);
    

		exp_value(pkt);
      if (pkt.o_flag == o_flag_exp && pkt.z_flag == z_flag_exp && pkt.alu_result == alu_result_exp)begin
			pkt.print();
        $display("time =%tns pkt.a =%h pkt.b =%h pkt.alu_cntr=%h",$time, pkt.a, pkt.b, pkt.alu_cntr);
          $display("time = %tns pkt.o_flag=%h o_flag_exp=%h pkt.z_flag=%h z_flag_exp=%h pkt.alu_result=%h alu_result_exp=%h",$time, pkt.o_flag, o_flag_exp,pkt.z_flag,z_flag_exp,pkt.alu_result,alu_result_exp);
        $display("\\----------------------------------------------------------\\");
        $display("//----------------------------------------------------------//");
        $display("--------------------------TEST IS PASSED----------------------");
        $display("\\----------------------------------------------------------\\");
        $display("//----------------------------------------------------------//");
		//count++
        testcase_passed++;
      end
      

		else begin
			pkt.print();
      $display("time=%tns pkt.o_flag=%h o_flag_exp=%h pkt.z_flag=%h z_flag_exp=%h pkt.alu_result=%h alu_result_exp=%h",$time, pkt.o_flag, o_flag_exp,pkt.z_flag,z_flag_exp,pkt.alu_result,alu_result_exp);
	    $display("\\----------------------------------------------------------\\");
        $display("//----------------------------------------------------------//");
          $display("----------------------TEST IS Failed------------------------");
        $display("\\----------------------------------------------------------\\");
        $display("//----------------------------------------------------------//");
		//count++;
        testcase_failed ++;
        end
     
	endtask

	task exp_value(alu_pkt pkt);
		bit [31:0] ung_a = $unsigned(pkt.a);
		bit [31:0] ung_b = $unsigned(pkt.b);
		bit reg_intern;
		count++;
		begin
			if( pkt.alu_cntr[3] ) begin
				if (pkt.alu_cntr[2:0] == 3'b000) begin
					alu_result_exp = pkt.a < pkt.b;
				end
				else if (pkt.alu_cntr[2:0] == 3'b001) begin
						alu_result_exp = pkt.a & pkt.b;
				end
				else if (pkt.alu_cntr[2:0] == 3'b010) begin
						alu_result_exp = pkt.a ^ pkt.b;
				end
				else if (pkt.alu_cntr[2:0] == 3'b011) begin
						alu_result_exp = pkt.a | pkt.b;
				end
				else if (pkt.alu_cntr[2:0] == 3'b100) begin
						alu_result_exp = pkt.a - pkt.b;
						reg_intern = pkt.a < pkt.b;
				end
				else if (pkt.alu_cntr[2:0] == 3'b101) begin
						alu_result_exp = pkt.a << pkt.b;
				end
				else if (pkt.alu_cntr[2:0] == 3'b110) begin
						alu_result_exp = pkt.a >> pkt.b;
				end
				else if (pkt.alu_cntr[2:0] == 3'b111) begin
						alu_result_exp = pkt.a >>> pkt.b;
				end
				else 	alu_result_exp = 0;
			end
			else begin
				if (pkt.alu_cntr [2:0] == 3'b100) begin
					alu_result_exp = ung_a - ung_b;
					reg_intern = ung_a < ung_b;
				end
				else begin
					alu_result_exp = 0;
					reg_intern = 0;	
				end
			end
			if (alu_result_exp==0) 
				z_flag_exp =1;
				else 
					z_flag_exp=0;

			if (pkt.alu_cntr[2:0] == 3'b100) 
				o_flag_exp = reg_intern;
			
				else 
					o_flag_exp = 0;
			//z_flag_exp = (alu_result_exp==0)?1:0;
			//o_flag_exp = (pkt.alu_cntr[2:0] == 3'b100)? reg_intern:0;
		end
	

	endtask
	 virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
   begin
     
        $display("                                                              ");
        $display("                                                              ");
        $display("                                                              ");
        $display("//---------------------FINAL RESULT-------------------------//");
        $display("\\----------------------------------------------------------\\");
        $display("-----------------------TOTAL TEST FIRED = %0d---------------",count);
        $display("-----------------------TESTCASE PASSED = %0d---------",testcase_passed);
        $display("-----------------------TESTCASE FAILED = %0d---------",testcase_failed);
        $display("\\----------------------------------------------------------\\");
        $display("//---------------------FINAL RESULT-------------------------//");
        $display("                                                              ");
        $display("                                                              ");
        $display("                                                              ");

      end
  endfunction
endclass















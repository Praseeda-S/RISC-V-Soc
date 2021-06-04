import uvm_pkg::*;
`include "uvm_macros.svh"
`include "alu.v"
`include "interface.sv"
`include "alu_tx.sv"
`include "alu_drv.sv"
`include "alu_mon.sv"
`include "alu_scbd.sv"
`include "alu_agent.sv"
`include "alu_env.sv"
`include "seq_lib.sv"
//`include "test_lib.sv"

module top;
	reg clk, rstn;

	//clk generation logic
	initial begin
		clk = 0;
		forever #5 clk = ~clk;	
	end
	
	//reset generation logic
	initial begin
		rstn = 0;//active low reset
		repeat(2) @(posedge clk); //@(posedge clk);
					  //@(posedge clk);
		rstn = 1;
	end

	alu_intf pif(clk, rstn); 

	//regestring the interface to the factory
	initial begin
		uvm_config_db#(virtual alu_intf)::set(uvm_root::get(),"*","vif",pif); //*- it should be abalible below to the hirerchy
			//pif- we are registering the interfce using the name pif
			//vif- we will use virtual interface with the name of vif
	end

	//dut inst
//	alu dut(pif);
	//dut connections
	//named mapping
	alu dut(.alu_cntr(pif.alu_cntr),
                .a(pif.a),
                .b(pif.b),
                .o_flag(pif.o_flag),
                .z_flag(pif.z_flag),
                .alu_result(pif.alu_result) );

	`include "test_lib.sv"
	initial begin
           run_test("alu_test");
	end 
        initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end


	//logic to end simulation 
	 initial begin
            #5000;
            $finish();
         end
endmodule




class alu_mon extends uvm_monitor;
	`uvm_component_utils(alu_mon)
	function new(string name ="alu_mon", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	uvm_analysis_port #(alu_pkt)mon_analysis_port;
	virtual alu_intf vif;
	alu_pkt pkt = new();

        virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
          `uvm_info(get_full_name(),$sformatf("INSIDE MONITOR BUILD PAHSE"),UVM_MEDIUM)
	   if(!uvm_config_db#(virtual alu_intf)::get(this,"","vif",vif))
	        	`uvm_fatal("mon","could not get vif")
		mon_analysis_port = new("mon_analysis_port",this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
	        `uvm_info(get_full_name(),$sformatf("INSIDE MONITOR RUN PHASE"),UVM_MEDIUM)
		@(posedge vif.rstn);
      
      forever begin
          @(posedge vif.clk);
          
        	pkt.alu_cntr <= vif.mon.alu_cntr;
            pkt.a <= vif.a;
			pkt.b <= vif.b;
			pkt.o_flag <= vif.o_flag;
			pkt.z_flag <= vif.z_flag;
			pkt.alu_result <= vif.alu_result; 	
        #1;
      //  pkt.print();
		    mon_analysis_port.write(pkt);
        
		end
	endtask
endclass





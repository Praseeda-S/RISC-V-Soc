class alu_drv extends uvm_driver #(alu_pkt);
	`uvm_component_utils(alu_drv)

	function new(string name = "alu_drv", uvm_component parent = null);
		super.new(name,parent);
	endfunction


	virtual alu_intf vif;
        alu_pkt pkt = new();

		virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE DRIVER  BUILD PHASE"),UVM_MEDIUM)
          if(!uvm_config_db#(virtual alu_intf)::get(this,"","vif",vif)) //uvm_resource_db
			`uvm_fatal("drv","could not get vif") //uvm_error
	endfunction


	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE DRIVER  RUN PHASE"),UVM_MEDIUM)
		@(posedge vif.rstn);//we are waiting for reset to come out
          forever begin
            @(posedge vif.alu_cb);
			seq_item_port.get_next_item(pkt);
			drive_dut(pkt);
            seq_item_port.item_done();
          //  $display("PRINTING FROM DRIVER:   ");
          //  pkt.print();
		end
	endtask

	task drive_dut(alu_pkt pkt);
		vif.alu_cb.alu_cntr <= pkt.alu_cntr;
		vif.alu_cb.a <= pkt.a;
		vif.alu_cb.b <= pkt.b;
	endtask
endclass




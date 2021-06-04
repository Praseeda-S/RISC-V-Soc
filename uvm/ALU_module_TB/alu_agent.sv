class alu_agent extends uvm_agent;
	`uvm_component_utils(alu_agent)

	function new(string name = "alu_agent", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	alu_drv drv;
	alu_mon mon;
	uvm_sequencer#(alu_pkt) sqr;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE AGENT  BUILD PHASE"),UVM_MEDIUM)
		drv = alu_drv::type_id::create("drv",this);
		mon = alu_mon::type_id::create("mon",this);
		sqr = uvm_sequencer#(alu_pkt)::type_id::create("sqr",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE AGENT  CONNECT PHASE"),UVM_MEDIUM)
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction

endclass


class alu_env extends uvm_env;
	`uvm_component_utils(alu_env)

	function new(string name = "alu_env", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	alu_agent agent;
	alu_scbd scbd;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE ENV  BUILD PHASE"),UVM_MEDIUM)
		agent = alu_agent::type_id::create("agent",this);
		scbd  = alu_scbd::type_id::create("scbd",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE ENV  CONNECT PHASE"),UVM_MEDIUM)
		agent.mon.mon_analysis_port.connect(scbd.m_analysis_imp);
	endfunction
endclass


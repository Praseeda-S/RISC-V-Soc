class alu_test extends uvm_test;
	`uvm_component_utils(alu_test)

	function new(string name="alu_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	alu_env env;
	alu_seq alu_seq_h;
	//uvm_table_printer printer;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE TEST BUILD PHASE"),UVM_MEDIUM)
		env = alu_env::type_id::create("env",this);
		alu_seq_h = alu_seq::type_id::create("alu_seq_h",this);
		//printer = new();
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info(get_full_name(),$sformatf("INSIDE TEST RUN PHASE"),UVM_MEDIUM)
		phase.raise_objection(this);
		`uvm_info(get_full_name(),$sformatf("INSIDE TEST RUN PHASE RAISE OBJECTION"),UVM_MEDIUM)
		alu_seq_h.start(env.agent.sqr);
		#20;
		phase.drop_objection(this);
		`uvm_info(get_full_name(),$sformatf("INSIDE TEST RUN PHASE DROP OBJECTION"),UVM_MEDIUM)
	endtask
endclass




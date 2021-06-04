//uvm have 2 types of element
//	object- tx_class, seq
//	components-
//uvm have 2 types of element
//	object- tx_class, seq
//	components-
class alu_pkt extends uvm_sequence_item;
	rand bit [3:0] alu_cntr;
	rand int  a; //32 bit signed
	rand int  b; //32 bit signed

	bit        o_flag;
	bit        z_flag;
	bit [31:0] alu_result;

	`uvm_object_utils_begin(alu_pkt)//registring the class to the factory

		//registring the fields to the factory
		`uvm_field_int(alu_cntr,UVM_DEFAULT); //copy,compare,print,pack,unpack
		`uvm_field_int(a,UVM_DEFAULT);
		`uvm_field_int(b,UVM_DEFAULT);
		`uvm_field_int(o_flag,UVM_DEFAULT);
		`uvm_field_int(z_flag,UVM_DEFAULT);
		`uvm_field_int(alu_result,UVM_DEFAULT);

	`uvm_object_utils_end

	function new(string name ="alu_pkt");
		super.new(name);
	endfunction

endclass




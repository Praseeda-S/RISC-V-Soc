class alu_seq extends uvm_sequence;
	`uvm_object_utils(alu_seq)

	function new(string name = "alu_seq");
		super.new(name);
	endfunction

	virtual task body();
      alu_pkt tx;
      `uvm_info(get_full_name, $sformatf("start seq alu_seq"),UVM_MEDIUM)
  //    $display("--------------------------------------------------------pkt = %p",tx);
      tx = new();
      start_item(tx);
      assert(tx.randomize() with {tx.alu_cntr== 4'b1000;});
        finish_item(tx);
      #10;
      repeat(25) begin
       tx=new();
      start_item(tx);
     //   `uvm_do(tx);
      assert(tx.randomize());
    //  $display("-///-------------------------------------------------------pkt = %p",tx);

	//	tx.print();
      finish_item(tx);
      end
      `uvm_info(get_full_name, $sformatf("end seq alu_seq"),UVM_MEDIUM)
	endtask
endclass





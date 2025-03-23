


// class source seq

class source_seq extends uvm_sequence#(source_xtn);

// factory registration

		`uvm_object_utils(source_seq)

// function new

		function new(string name = "source_seq");
		
			super.new(name);
		
		endfunction

endclass



// class source seq

class destin_seq extends uvm_sequence#(destin_xtn);

// factory registration

		`uvm_object_utils(destin_seq)

// function new

		function new(string name = "destin_seq");
		
			super.new(name);
		
		endfunction

endclass
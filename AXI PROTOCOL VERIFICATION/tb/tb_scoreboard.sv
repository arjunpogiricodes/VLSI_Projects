



// class score board

class score_board extends uvm_scoreboard;

// factory registration

		`uvm_component_utils(score_board)

// handle declaraiton		

// new constructor

		function new(string name = "score_board",uvm_component parent);
		
		      super.new(name,parent);
		
		endfunction


endclass
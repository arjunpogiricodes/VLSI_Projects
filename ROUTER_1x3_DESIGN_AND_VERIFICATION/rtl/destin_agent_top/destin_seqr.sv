





//destination sequencer class

class destin_seqr extends uvm_sequencer #(destin_xtn);

// factory registration

      `uvm_component_utils(destin_seqr)

// fuinction new constructor

      function new (string name="destin_seqr" , uvm_component parent= null);

               super.new(name,parent);


      endfunction 
	  
// build phase
	  
     /*    function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
                 
         endfunction
*/

endclass







// source  sequnce class

class source_seqr extends uvm_sequencer #(source_xtn);


// factory registration

     `uvm_component_utils(source_seqr)


// fcuntion new constructor


      function new(string name ="source_seqr", uvm_component parent = null);
  
              super.new(name,parent);
			  

      endfunction:new     





endclass

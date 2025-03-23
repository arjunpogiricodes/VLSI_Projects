

//---------------- ahb sequencer-----------------//

class ahb_seqr extends uvm_sequencer#(ahb_xtn);

// factory registration

           `uvm_component_utils(ahb_seqr)

// constructor new

          function new (string name = "ahb_seqr",uvm_component parent);

                      super.new(name,parent);

          endfunction



endclass


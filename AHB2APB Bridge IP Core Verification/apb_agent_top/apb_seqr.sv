

//---------------- apb sequencer-----------------//

class apb_seqr extends uvm_sequencer#(apb_xtn);

// factory registration

           `uvm_component_utils(apb_seqr)

// constructor new

          function new (string name = "apb_seqr",uvm_component parent);

                      super.new(name,parent);

          endfunction



endclass


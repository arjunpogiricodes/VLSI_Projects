

// ---------------apb sequence--------------//

class apb_seq extends uvm_sequence#(apb_xtn);

// factory registration

           `uvm_object_utils(apb_seq)


// constructor new

          function new (string name = "apb_seq");


                      super.new(name);


          endfunction

endclass


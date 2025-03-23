

// -------------- apb_configuaration------------------//

class apb_config extends uvm_object;

// factory registration

           `uvm_object_utils(apb_config)


// enum for active and passive

          uvm_active_passive_enum  is_active = UVM_ACTIVE;

// virtual interface

          virtual ahbtoapb_interface vif;
 
// constructor new

          function new (string name = "apb_config");


                      super.new(name);


          endfunction

endclass


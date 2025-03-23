

//-------------------ahb configurartion ------------------//

class ahb_config extends uvm_object;

// factory registration

           `uvm_object_utils(ahb_config)


// enum for active and passive

          uvm_active_passive_enum  is_active = UVM_ACTIVE;

// virtual interface

          virtual ahbtoapb_interface vif;

// constructor new

          function new (string name = "ahb_config");


                      super.new(name);


          endfunction

endclass


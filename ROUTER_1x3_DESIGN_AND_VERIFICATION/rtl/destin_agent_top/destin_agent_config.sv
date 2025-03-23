



// class for destinationj agetn configratoion data base object


class destin_agent_config extends uvm_object;


// factory registration 

          `uvm_object_utils(destin_agent_config)

// declare the varible required

            uvm_active_passive_enum is_active = UVM_ACTIVE;
// declare the virtual inteface handle
  
                virtual router_destin_if  vif;


// fucntion new construction

           function new(string name = "destin_agent_config");

                         super.new(name);

           endfunction
    


endclass



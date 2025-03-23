





// source  agent config  

class source_agent_config extends uvm_object;


// factory registration

        `uvm_object_utils(source_agent_config)


     uvm_active_passive_enum is_active = UVM_ACTIVE;
    

// declare virtual interfae handle

        virtual router_source_if vif;

// function new constructor


       function new(string name = "source_agent_config" );
 
             super.new(name);

       endfunction    





endclass


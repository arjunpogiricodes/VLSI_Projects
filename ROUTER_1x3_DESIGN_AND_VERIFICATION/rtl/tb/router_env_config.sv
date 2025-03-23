





// router env config class universal data base

class router_env_config extends uvm_object;

// factory registration
 
         `uvm_object_utils(router_env_config)


// declaring the  the handle for source agent config and destination agent config

         source_agent_config  m_source_agth[];
         destin_agent_config  m_destin_agth[];

// declaring the variable for give the acesss for test bench component 


         int no_of_destin = 3;
         int no_of_source = 1;

// funciton new construction



        function new(string name = "router_env_config");

              super.new(name);


        endfunction
 


endclass
  

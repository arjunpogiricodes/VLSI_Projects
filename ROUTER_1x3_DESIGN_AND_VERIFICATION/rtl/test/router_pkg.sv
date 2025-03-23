

package router_pkg;

// including the all ruoter file

import uvm_pkg ::*;

`include "uvm_macros.svh"

`include "destin_agent_config.sv"
`include "source_agent_config.sv"
`include "router_env_config.sv" 


`include "destin_xtn.sv"

`include "source_xtn.sv"

`include "source_seq.sv"
`include "source_seqr.sv"   
`include "source_driver.sv" 
`include "source_monitor.sv"  
`include "source_agent.sv"  
`include "source_agent_top.sv"  

`include "destin_seq.sv"  
`include "destin_driver.sv"  
`include "destin_monitor.sv"  
`include "destin_seqr.sv" 
`include "destin_agent.sv"  
`include "destin_agent_top.sv"  


`include "virtual_seqr.sv"  
`include "virtual_seq.sv"  
`include "tb_scoreboard.sv" 
`include "tb_env.sv"  
`include "base_test.sv"

//`include "top.sv"  

endpackage








//destination driver class

class destin_driver extends uvm_driver #(destin_xtn);

// factory registration

         `uvm_component_utils(destin_driver)

// declare the virtual interface handle

         destin_agent_config m_cfg;

         virtual router_destin_if.D_DRV vif; 

// funcion new constructor


       function new (string name = "destin_driver", uvm_component parent = null );

       
                super.new(name,parent);
                 
        endfunction
   
// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
                // `uvm_info(get_full_name(),"this is driver destin",UVM_NONE)
                 if(!uvm_config_db #(destin_agent_config) :: get(this,"","destin_agent_config",m_cfg))
                       `uvm_fatal(get_full_name(),"cannot get  the destin agetn config handle driver  m_cfg from desti agetn top")

         endfunction
// connect phase connect the virtual interface to local interface 

         function void connect_phase(uvm_phase phase);

                vif = m_cfg.vif;

         endfunction
		 
 
 // task run_phase here we send req and and then data req sended to new method for driving
  
          task run_phase(uvm_phase phase);
 
               forever 
                      begin
                             super.run_phase(phase);
                         
                             seq_item_port.get_next_item(req);
                             

                               send_to_dut();
                               //req.print();
                             
                              seq_item_port.item_done();
                             
                      end
          endtask


// task send to dut

         task send_to_dut();
               
                  while(vif.destin_drv.valid_out !== 1'b1)
	              begin
                        @(vif.destin_drv);
                      end 
				   
                   repeat(req.delay)
                          begin 
                               @(vif.destin_drv);
                          end
                   vif.destin_drv.read_enb <= 1'b1;
                  
                                 
                   while(vif.destin_drv.valid_out !== 1'b0)
		          begin
                                @(vif.destin_drv);
			  end  
					
                   vif.destin_drv.read_enb <= 1'b0;
		    @(vif.destin_drv);
                    
                 
        endtask 


       

endclass

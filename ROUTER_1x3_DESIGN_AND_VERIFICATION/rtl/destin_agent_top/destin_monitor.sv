



// destination monitor class

class destin_monitor extends uvm_monitor;

// factory registration

        `uvm_component_utils(destin_monitor)

// declare virtual interface handle

            destin_agent_config m_cfg;
            virtual router_destin_if.D_MON vif; 
// declaring the destin transaction
 
                  destin_xtn destin_mon;
				  
// tlm port for write to score board	

        uvm_analysis_port #(destin_xtn) dmon_port;			  
           
// function new constructor 


        function new(string name = "destin_monitor" , uvm_component parent = null );

                     super.new(name,parent);
		             dmon_port = new ("dmon_port",this); 
					 
         endfunction 

// build phase
         function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
                // `uvm_info(get_full_name(),"this is monitor destin",UVM_NONE)
                  if(!uvm_config_db #(destin_agent_config) :: get(this,"","destin_agent_config",m_cfg))
                       `uvm_fatal(get_full_name(),"cannot get  the destin agetn config handle monitor m_cfg from desti agetn top")

         endfunction
		 
// connect_phase connecting the virtual interfcce to local interface handle

         function void connect_phase(uvm_phase phase);
       
                  vif = m_cfg.vif;
 
         endfunction

// run phase


          task run_phase(uvm_phase phase);

               forever
                      begin
                         
                         collect_data();
                         destin_mon.print();
			 dmon_port.write(destin_mon);
                      end
					  
          endtask 

// collect the data from interface 

         task collect_data();
                
               destin_mon = destin_xtn :: type_id :: create("destin_mon");
                  
               while( vif.destin_mon.read_enb !== 1'b1)
	             begin
                            @(vif.destin_mon);                      
                     end      
            	@(vif.destin_mon);			
                destin_mon.header_byte = vif.destin_mon.data_out;
				
                @(vif.destin_mon);
                destin_mon.payload = new[destin_mon.header_byte[7:2]];				
               foreach(destin_mon.payload[i])
                   begin
                        while( vif.destin_mon.valid_out !== 1'b1)
                             begin
                                  @(vif.destin_mon);
                             end   
                        destin_mon.payload[i] = vif.destin_mon.data_out;                     
                        @(vif.destin_mon);
						
                   end
                destin_mon.parity_byte = vif.destin_mon.data_out;
                   @(vif.destin_mon);
				
         endtask


endclass



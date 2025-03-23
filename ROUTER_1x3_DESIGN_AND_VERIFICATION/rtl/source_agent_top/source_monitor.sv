




// class source monitor

class source_monitor extends uvm_monitor;

// factory registration

     `uvm_component_utils(source_monitor)

// dfeclare  virtual interface

          virtual router_source_if.S_MON vif;
          source_agent_config m_cfg;
		  source_xtn source_mon;

// declaring the anlysis port

          uvm_analysis_port #(source_xtn) smon_port;


// function new constructor

       function new (string name = "source_monitor",uvm_component parent = null );

              super.new(name,parent);
              smon_port = new("smon_port",this);			   
 
       endfunction 
	   
// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
               // `uvm_info(get_full_name(),"this is monior soruce",UVM_NONE)
                if(!uvm_config_db #(source_agent_config) :: get(this,"","source_agent_config",m_cfg))
                       `uvm_fatal(get_full_name(),"cannot get  the source agent config handle monitor m_cfg from source agent top")


         endfunction

// connect phase

          function void connect_phase(uvm_phase phase);

                    vif = m_cfg.vif;

          endfunction	   
      
// run phase

        task run_phase(uvm_phase phase);

             forever 
			       begin
				        
                        super.run_phase(phase);
                        collect_data();
                         source_mon.print();
                         smon_port.write(source_mon);						 
						
                   end
        endtask     

// collect task for from interace to monnitor 

        task collect_data();
		    source_mon = source_xtn :: type_id :: create("source_mon");
            while(vif.source_mon.busy != 1'b0)			
	              @(vif.source_mon);
            while(vif.source_mon.pkt_valid != 1'b1)
               	  @(vif.source_mon);
            source_mon.header_byte = vif.source_mon.data_in;
            @(vif.source_mon);
            source_mon.payload = new[source_mon.header_byte[7:2]];
            foreach(source_mon.payload[i])
                  begin 
				        while(vif.source_mon.busy != 1'b0)
                        begin						
						@(vif.source_mon);
						end 
                        source_mon.payload[i] = vif.source_mon.data_in;
                        @(vif.source_mon);
                  end
            source_mon.parity_byte = vif.source_mon.data_in;
			
			  @(vif.source_mon);
			  @(vif.source_mon);
			  source_mon.error = vif.source_mon.error;
			  $display("Signal Error From Source Monitor = %0b",source_mon.error);
 				  
		endtask


endclass






//class source agent


class source_agent extends uvm_agent;

// factory regstrtion

       `uvm_component_utils(source_agent)

// declarin the  hadle for the driver and monitor and sequencer
         
            source_driver drvh;
            source_monitor monh;
            source_seqr seqr;
            source_agent_config  m_cfg;


// function new constructor

           function new(string name,uvm_component parent = null);

                 super.new(name,parent);
                 
           endfunction    

// build  phase

           function void build_phase(uvm_phase phase);

               super.build_phase(phase);
               //`uvm_info(get_full_name(),"this is agt soruce",UVM_NONE)
               
               if(! uvm_config_db #(source_agent_config) :: get(this,"","source_agent_config",m_cfg))
                     `uvm_fatal(get_full_name(),"cannot get the source agent config handle m_cfg are set it in agent top?")
                monh = source_monitor :: type_id :: create("monh",this);
    
                if(m_cfg.is_active == UVM_ACTIVE)
                   begin
                        drvh = source_driver  :: type_id :: create("drvh",this);
                        seqr = source_seqr    :: type_id :: create("seqr",this);   
                   end

           endfunction

// connect phase


           function void connect_phase(uvm_phase phase);
 
                if(m_cfg.is_active == UVM_ACTIVE)
                   begin
                        drvh.seq_item_port.connect(seqr.seq_item_export);      
                   end

           endfunction


// end of elaboration phase

    /*     function void end_of_elaboration_phase(uvm_phase phase);
            
                 uvm_top.print_topology();

         endfunction
   */

endclass

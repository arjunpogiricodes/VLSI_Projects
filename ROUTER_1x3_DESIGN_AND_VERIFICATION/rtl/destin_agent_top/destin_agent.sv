




// class for destination agent

class destin_agent extends uvm_agent;

// factory registration
   
        `uvm_component_utils(destin_agent)

// declaring the handle of seqr,driver,monitor

            destin_monitor monh;
            destin_driver  drvh;
            destin_seqr    seqr;
            destin_agent_config  m_cfg;
  
// function new costructor

          function new(string name = "destin_agent" , uvm_component parent = null);

                      super.new(name,parent);
              
           endfunction


// build phase


          function void build_phase(uvm_phase phase);
              
                  super.build_phase(phase);
        	//  `uvm_info(get_full_name(),"this is agt destin",UVM_NONE)

                  if(! uvm_config_db #(destin_agent_config):: get(this,"","destin_agent_config",m_cfg) )
                       `uvm_fatal(get_full_name(),"cannot get() the destin agent config mcfg are set it in destin agent top?")

                  monh = destin_monitor :: type_id :: create ("monh",this);
                  
                  if(m_cfg.is_active == UVM_ACTIVE)
                      begin
                           drvh = destin_driver  :: type_id :: create ("drvh",this);
                           seqr = destin_seqr    :: type_id :: create ("seqr",this);
                      end

          endfunction

// connect_phase


          function void  connect_phase(uvm_phase phase);

              
                  if(m_cfg.is_active == UVM_ACTIVE)
                      begin
                           drvh.seq_item_port.connect(seqr.seq_item_export);
                          // drvh.seq_item_port.connect(seqr.seq_item_export);      

                      end


          endfunction 


endclass 




//-------------------apb monitor ---------------------//

class apb_monitor extends uvm_monitor;

// factory registration

           `uvm_component_utils(apb_monitor)

// virtual interface

          virtual ahbtoapb_interface.APB_MON vif;
          apb_config m_cfg;
          apb_xtn p_mon;

// tlm analysis port delcaration

         uvm_analysis_port #(apb_xtn) p_port;
// constructor new

          function new (string name = "apb_monitor",uvm_component parent);

                      super.new(name,parent);
                      p_port = new("p_port",this);

          endfunction

// build phase

         function void build_phase(uvm_phase phase);
                  super.build_phase(phase);
                  if(!uvm_config_db #(apb_config) :: get(this,"","apb_config",m_cfg))
                          `uvm_fatal(get_full_name(),"cannot get the m_cfg handle from apb_top in apb_monitor")
                
         endfunction 
// connect phase 

         function void connect_phase(uvm_phase phase);
                
                  vif = m_cfg.vif;

         endfunction

// task run_phase

         task run_phase(uvm_phase phase);
 
                   super.run_phase(phase);
                   forever 
                         begin
                              collect_data();
                              p_port.write(p_mon);
                              //p_mon.print();
                              
                         end

         endtask
// task collect_data

          task collect_data;
                   p_mon = apb_xtn :: type_id :: create("p_mon");
                   while(vif.apb_mon.PENABLE !== 1)
                          @(vif.apb_mon);
                   p_mon.PENABLE = vif.apb_mon.PENABLE;
                   p_mon.PADDR = vif.apb_mon.PADDR;
                   p_mon.PWRITE = vif.apb_mon.PWRITE;
                   p_mon.PSEL = vif.apb_mon.PSEL;
                         // @(vif.apb_mon);
  
                   if(vif.apb_mon.PWRITE ==1)
                         p_mon.PWDATA = vif.apb_mon.PWDATA;
                   else
                         p_mon.PRDATA  = vif.apb_mon.PRDATA;
                   
                   @(vif.apb_mon); 
                   @(vif.apb_mon); 


          endtask


endclass


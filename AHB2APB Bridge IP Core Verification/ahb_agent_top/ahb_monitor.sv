

//-------------------ahb monitor ---------------------//

class ahb_monitor extends uvm_monitor;

// factory registration

           `uvm_component_utils(ahb_monitor)

// virtual interface

          virtual ahbtoapb_interface.AHB_MON vif;
          ahb_config m_cfg; 
          ahb_xtn h_mon;

// tlm port declaration

        uvm_analysis_port #(ahb_xtn) h_port;

// constructor new

          function new (string name = "ahb_monitor",uvm_component parent);

                      super.new(name,parent);
                      h_port = new("m_port",this);

          endfunction
// build phase

         function void build_phase(uvm_phase phase);
                  super.build_phase(phase);
                  if(!uvm_config_db #(ahb_config) :: get(this,"","ahb_config",m_cfg))
                          `uvm_fatal(get_full_name(),"cannot get the m_cfg handle from ahb_top in h_monitor")
                
         endfunction 
// connect phase 

         function void connect_phase(uvm_phase phase);
                
                  vif = m_cfg.vif;

         endfunction

// task runphase

         task run_phase(uvm_phase phase);
 
                   super.run_phase(phase);
                  forever
                   begin
                             collect_data();
                             h_port.write(h_mon);
                             //h_mon.print();  
                   end
         endtask

// send to dut task

         task collect_data();
               h_mon = ahb_xtn :: type_id :: create ("h_mon");

               while(vif.ahb_mon.HREADYout !== 1)
                  @(vif.ahb_mon);
               while(vif.ahb_mon.HTRANS !== 2 && vif.ahb_mon.HTRANS !== 3)
                  @(vif.ahb_mon);
                    h_mon.HREADYin = vif.ahb_mon.HREADYin;
                    h_mon.HWRITE   = vif.ahb_mon.HWRITE;
                    h_mon.HTRANS   = vif.ahb_mon.HTRANS;
                    h_mon.HSIZE    = vif.ahb_mon.HSIZE;
                    h_mon.HADDR    = vif.ahb_mon.HADDR;
                    //h_mon.length   = vif.ahb_mon.length;
                 
                @(vif.ahb_mon);

               while(vif.ahb_mon.HREADYout !== 1)
                  @(vif.ahb_mon);
	            if(vif.ahb_mon.HWRITE == 1)
                    h_mon.HWDATA  = vif.ahb_mon.HWDATA;
                    else
                    h_mon.HRDATA  = vif.ahb_mon.HRDATA;
             
                                               
         endtask
       




endclass



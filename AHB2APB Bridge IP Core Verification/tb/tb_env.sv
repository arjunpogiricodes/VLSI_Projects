

//----------------test bench environment---------------//

class tb_env extends uvm_env;

// factory registration

           `uvm_component_utils(tb_env)


// declaring the handles

            ahb_agent_top  ahb_top;
            apb_agent_top  apb_top;
            tb_scoreboard  sb;
            virtual_seqr   v_seqr;
// constructor new

          function new (string name = "tb_env",uvm_component parent);

                      super.new(name,parent);

          endfunction

// build_phase

         function void build_phase(uvm_phase phase);

                   super.build_phase(phase);           
                    ahb_top = ahb_agent_top :: type_id :: create("ahb_top",this);
                    apb_top = apb_agent_top :: type_id :: create("apb_top",this);
                    sb      = tb_scoreboard :: type_id :: create("sb",this);
                    v_seqr  = virtual_seqr  :: type_id :: create("v_seqr",this);
         endfunction

// connect phase

       function void connect_phase(uvm_phase phase);

            /*  foreach(v_seqr.s_seqr[i])
                    begin
                       v_seqr.h_seqr[i] = ahb_top.agent_ahb[i].seqr;
                    end */
              v_seqr.h_seqr = ahb_top.agent_ahb[0].seqr;
              ahb_top.agent_ahb[0].mon.h_port.connect(sb.ahb_fifo.analysis_export);
              apb_top.agent_apb[0].mon.p_port.connect(sb.apb_fifo.analysis_export);

       endfunction




endclass


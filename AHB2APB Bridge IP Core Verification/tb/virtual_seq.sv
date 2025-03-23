
//--------------------- virtual seq ----------------------------------//

class virtual_seq extends uvm_sequence #(uvm_sequence_item);

// factory registration 

         `uvm_object_utils(virtual_seq)

// sequnce hanlde declaration
 
          single_seq    s_seq;
          incr_seq     i_seq;
          wrap_seq     w_seq;
          virtual_seqr v_seqr; 
          ahb_seqr      h_seqr;
          tb_env_config  m_cfg;     

// constructor new

         function new(string name = "virtual_seq");

                   super.new(name);

         endfunction

//task body

        task body();
          /*    if(! uvm_config_db #(tb_env_config) :: get(null,get_full_name(),"tb_env_config",m_cfg) )
                      `uvm_fatal(get_full_name(),"canot get the tb_env_config handle m_cdfg from test in virtual sequence")
                      

                       h_seqr = new[m_cfg.no_of_ahb];
*/
              assert($cast(v_seqr,m_sequencer))
                  else
                     begin
                         `uvm_error(get_full_name(),"error becuase of cast not working in the virtual sequence check that") 
                     end     
           //  foreach(h_seqr[i])
              h_seqr = v_seqr.h_seqr;

        endtask

        

endclass

// single seq virtual sequnce


class virtual_s_seq extends virtual_seq;

// factory registration

       `uvm_object_utils(virtual_s_seq)

// constructor new

        function new(string name = "virtual_s_seq");

                    super.new(name);

        endfunction 

// task body


        task body();
                  s_seq = single_seq :: type_id :: create("s_seq");
                  super.body();
                  s_seq.start(h_seqr);
                 /* for(int i=0; i < m_cfg.no_of_ahb ; i++)
                    begin
                         s_seq.start(h_seqr[i]);      
                    end */
        endtask

endclass

// incr seq virtual sequnce

class virtual_i_seq extends virtual_seq;

// factory registration

        `uvm_object_utils(virtual_i_seq)


// constructor new

        function new(string name = "virtual_i_seq");

                    super.new(name);

        endfunction 

// task body


        task body();
                  i_seq = incr_seq :: type_id :: create("i_seq");
                  super.body();
                  i_seq.start(h_seqr);
                 /* for(int i=0; i < m_cfg.no_of_ahb ; i++)
                      begin
                          i_seq.start(h_seqr[i]);      
                      end */

        endtask


endclass

// wrap seq virtual sequnce

class virtual_w_seq extends virtual_seq;

// factory registration

        `uvm_object_utils(virtual_w_seq)


// constructor new

        function new(string name = "virtual_w_seq");

                    super.new(name);

        endfunction 

// task body


        task body();
                  w_seq = wrap_seq :: type_id :: create("w_seq");
                  super.body();
                  w_seq.start(h_seqr);
                 /* for(int i=0; i < m_cfg.no_of_ahb ; i++)
                      begin
                          w_seq.start(h_seqr[i]);      
                      end */

        endtask





endclass  

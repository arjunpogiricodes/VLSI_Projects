



// virtual sequnce class

class virtual_seq extends uvm_sequence #(uvm_sequence_item);

// factory registration

      `uvm_object_utils(virtual_seq) 

// declaring the handle for sequnces

           small_seq   s_seq;
           medium_seq  m_seq;
           large_seq   l_seq;

// declaring the handle for virtual sequncer

          virtual_seqr v_seqr;

// declare dynamic handle for physical seqr

           source_seqr ps_seqr[];

// declaring the hande for env_config to getting 

          router_env_config m_cfg;

// function new constructor

                function new(string name = "virtual_seq");
                 
                     super.new(name);

                 endfunction:new
       
// task body for assging the v sequncer to m_sequncer and assingn the these handle to env_config class

               task body();

                      if(! uvm_config_db #(router_env_config) :: get(null,get_full_name(),"router_env_config",m_cfg) )
                                      `uvm_fatal(get_full_name(),"canot get the router_env_config handle m_cdfg from test in virtual sequence")
                      

                       ps_seqr = new[m_cfg.no_of_source];

// assiging the m_sequncer to physical virtual sequncer through $cast

                     assert($cast(v_seqr,m_sequencer)) 
                                else
                                    begin
                                          `uvm_error(get_full_name(),"error becuase of cast not working in the virtual sequence check that") 
                                    end              
                     foreach(ps_seqr[i])
                                 begin
                                      ps_seqr[i] = v_seqr.s_seqr[i];
                                  end
                 
               endtask:body 

endclass 


// Extended class from virtual_seq to small seq sequnce class

class virtual_small_seq extends virtual_seq;


// factory registration

           `uvm_object_utils(virtual_small_seq)

// function new constructor

         function new( string name  = "virtual_small_seq");

                   super.new(name);

         endfunction


// task body 

          task body();

             s_seq = small_seq :: type_id :: create("s_seq");
             super.body();
             for(int i=0; i < m_cfg.no_of_source ; i++)
             begin
                  
                   s_seq.start(ps_seqr[i]);      
    
             end                

          endtask


endclass


// Extended class for medium seq

class virtual_medium_seq extends virtual_seq;

// factory registration

       `uvm_object_utils(virtual_medium_seq)

// function new constructor    

       function new (string name = "virtual_medium_seq" );

                      super.new(name);

       endfunction 
//  task body

        task body();
              m_seq = medium_seq :: type_id :: create("m_seq");
              super.body();
              for(int i=0; i<m_cfg.no_of_source ; i++)
                   begin
         
                       m_seq.start(ps_seqr[i]);
             
                   end
        endtask 

endclass
   

// Extended class for large seq

class virtual_large_seq extends virtual_seq;

// factory registration

         `uvm_object_utils(virtual_large_seq)

// function new constructor

         function new(string name ="virtual_large_seq");

                 super.new(name);

         endfunction


//  task body


          task body();
                  l_seq = large_seq :: type_id :: create("l_seq");
                  super.body(); 
                   for(int i=0; i< m_cfg.no_of_source ; i++)
                         begin
                             
                             l_seq.start(ps_seqr[i]); 
                        
                          end       
          endtask

endclass



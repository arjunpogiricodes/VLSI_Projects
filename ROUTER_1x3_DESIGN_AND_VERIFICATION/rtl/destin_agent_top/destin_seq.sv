




// destin seq class 

class destin_seq extends uvm_sequence #(destin_xtn);

// factory registation

          `uvm_object_utils(destin_seq)
 
// function new constructor

        function new(string name = "destin_seq");

                 super.new(name);

        endfunction
//build phase



// task body for ganerate stimulus

       task body();
       req = destin_xtn :: type_id :: create ("req");  
       start_item(req);

        
          assert(req.randomize() with {(req.delay >0) && (req.delay < 30);})
               else
                   begin
                       `uvm_fatal(get_full_name()," randomization not  happend in destinaion  sequence  check it")
                   end
        finish_item(req);   

       endtask



endclass

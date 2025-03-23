

// ---------------------tb_ env _ config ---------------------//

class tb_env_config extends uvm_object;

// factory registration

           `uvm_object_utils(tb_env_config)

// virtual interface


// declaring the varialbles for no of ahb top and apb top


          int no_of_ahb=1;
          int no_of_apb=1;

            ahb_config ahb_cfg[];
            apb_config apb_cfg[];



// constructor new

          function new (string name = "tb_env_config");

                      super.new(name);

          endfunction



endclass


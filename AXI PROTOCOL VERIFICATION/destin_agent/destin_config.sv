


// destin_config agent config


class destin_config extends uvm_object;


// factory registration

		`uvm_object_utils(destin_config)

//enum
       uvm_active_passive_enum is_active = UVM_ACTIVE;		
// virtual interface 

        virtual axi_if vif;

// function new constructor

		function new (string name = "destin_config");
		
			super.new(name);
		
		endfunction 




endclass
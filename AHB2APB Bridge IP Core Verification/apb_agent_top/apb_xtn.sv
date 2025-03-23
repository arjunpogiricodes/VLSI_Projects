

//--------------------apb transaction-----------------//

class apb_xtn extends uvm_sequence_item;

// factory registration

           `uvm_object_utils(apb_xtn)

// proparties

        bit PENABLE;
        bit PWRITE;
        bit [31:0] PWDATA;
        rand logic [31:0]PRDATA;
        bit [31:0]PADDR;
        bit [3:0] PSEL;

// constructor new

          function new (string name = "apb_xtn");

                      super.new(name);

          endfunction
// print method 

        function void do_print(uvm_printer printer);

                 super.do_print(printer);  
                 printer.print_field("PENABLE",this.PENABLE,1,UVM_BIN);
                 printer.print_field("PWRITE",this.PWRITE,1,UVM_BIN);
                 printer.print_field("PWDATA",this.PWDATA,32,UVM_HEX);
                 printer.print_field("PRDATA",this.PRDATA,32,UVM_HEX);
                 printer.print_field("PADDR",this.PADDR,32,UVM_HEX);
                 printer.print_field("PSEL",this.PSEL,4,UVM_BIN);

        endfunction


endclass


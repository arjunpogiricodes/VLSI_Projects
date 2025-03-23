



// top 

module top;

      import uvm_pkg::*;
      import pkg::*;
	  bit clk = 1'b0;
	  always #5 clk =~clk;
 
    

// declaring the interface

      axi_if VIF(clk);
	 
	 
// declaring instant


	initial 
		begin
		    `ifdef VCS
                  $fsdbDumpvars(0,top);
            `endif 
			//interface setting to test
			uvm_config_db #(virtual axi_if) :: set(null,"*","VIF",VIF);
            run_test();

		end

endmodule
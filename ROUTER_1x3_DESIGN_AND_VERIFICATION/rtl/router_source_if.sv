


// interface for source 

interface router_source_if(input bit clk);


//  input and output declaration
//    input clk,reset,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
//    input [7:0]data_in;
//    output  [7:0]data_out_0,data_out_1,data_out_2;
//    output valid_out_0,valid_out_1,valid_out_2,error,busy;



       logic [7:0]data_in;
       bit reset; 
       bit pkt_valid;
       bit error;
       bit busy; 
 
// declaring the clocking block for source driver

       clocking source_drv@(posedge clk);
           default input#1 output#1;
      
              output reset;
              output pkt_valid;
              output data_in;
              input  busy;
              input  error;
       
       endclocking  

// declaring the clocking  block for source monitor

       clocking source_mon@(posedge clk);
           default input#1 output#1;
             
               input reset;
               input pkt_valid;
               input data_in;
               input busy;
               input error;
             
       endclocking

// modports for mon and drv 

         modport S_MON(clocking source_mon);
         modport S_DRV(clocking source_drv);

endinterface







// destination interface

interface router_destin_if(input bit clk);

//  input and output declaration
//    input clk,reset,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
//    input [7:0]data_in;
//    output  [7:0]data_out_0,data_out_1,data_out_2;
//    output valid_out_0,valid_out_1,valid_out_2,error,busy;


       logic [7:0]data_out;
       bit read_enb;
       bit valid_out;


// clocking block for destination driver

     clocking destin_drv@(posedge clk);
           default input#1 output#1;

               output read_enb;
               input  valid_out;
               input data_out;
 
     endclocking 

// clocking block for destination monitor

     clocking destin_mon@(posedge clk);
          default input #1 output #1;

            input data_out;
            input read_enb;
            input valid_out;


       endclocking

// modports for destin drv and mon

      modport D_MON(clocking destin_mon);
      modport D_DRV(clocking destin_drv);
   
endinterface

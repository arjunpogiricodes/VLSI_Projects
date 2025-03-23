
///******************************************************************//
//                                                                   //
//                   RTL  DESIGN                                     //
//                                                                   //
//*******************************************************************//

// fifo 

module fifo_16x9_router(clk,reset,data_in,write_enb,read_enb,soft_reset,lfd_state,full,empty,data_out);

// declaring the input and ouput ports

     input clk,reset,write_enb,read_enb,lfd_state,soft_reset;
     input [7:0]data_in;
     output full,empty;
     output reg [7:0]data_out;

// declaring the internal write addr read addr memory and fifi down count reg 

     reg [5:0]write_addr,read_addr;
     reg [8:0]mem[0:15];
     reg [6:0]fifo_down_counter;
     reg lfd_state_temp;
     integer i;

/* delaying the lfd state bcuz its arriving at one clock  from the fsm mean
while data header comes at 2 clock pulses  from register so we synxc the
two things so we using d flip flop to genrate 1 clk delay for lfd state */

  
     always@(posedge clk)
       begin
	    if(!reset)       
           lfd_state_temp<=0;			  
        else
		     lfd_state_temp<=lfd_state;			  
       end
				
   // assign lfd_state = lfd_state_temp;
	
	 /*always@(posedge clk)
	  begin
	      if(write_enb && (!full))
			 mem[write_addr[3:0]][8] <= lfd_state_temp;
			 else
			  mem[write_addr[3:0]][8] <=  mem[write_addr[3:0]][8] ;
		end */

// increment the write and read address
  
   /*  always@(posedge clk)
       begin
	    if(!reset )
	           {read_addr,write_addr}<=0;
            else if(soft_reset)
	           {write_addr,read_addr}<=0;
            else 
				begin
				if(write_enb && (!full))

				if (read_enb && (!empty)) 
               read_addr <= read_addr +1;
             end   					
        end */
// increment the read address

    /*always@(posedge clk)
       begin
            if(!reset)
              read_addr<=0;
            else if(soft_reset)
              read_addr<=0;
            else if(read_enb && (!empty)) 
               read_addr <= read_addr +1;
        end
*/
// writing opearion	
	        
    always@(posedge clk)
         begin
	         if(!reset)
	           begin      
	             for(i=0;i<16;i=i+1)
					    begin
	                mem[i]<=0;
						 end
					write_addr<=0;
      	      end
	         else if(soft_reset)
	             begin      
	               for(i=0;i<16;i=i+1)
						  begin
	                   mem[i]<=0;
						  end
						  write_addr<=0;
      	      end	
	         else 
				if(write_enb && (!full))
             begin				
	          mem[write_addr[3:0]]<={lfd_state_temp,data_in};
				 write_addr <= write_addr+1;
				 //mem[write_addr[3:0]][8] <= lfd_state_temp;
				end 
				 
      end

// read opearion
 
     always@(posedge clk)
           begin
	       if(!reset) begin
		         data_out<=0;
					read_addr<=0; end
	       else if(soft_reset) begin
	            data_out<=8'bzzzz_zzzz;
					read_addr<=0; end
			 else if (fifo_down_counter ==0 && data_out !=0)
       			 data_out<=8'bzzzz_zzzz;
			  else 
			  if(read_enb && (!empty)) 
					begin
	   	    data_out<=mem[read_addr[3:0]];
				 read_addr <= read_addr +1;
				  end
           end
/* fifo down count logic when hear byte recived it check that 8 bt of the byt
 it is one then fifo counte load with playload data then after ti decremented every clk pulse*/   

   
     always@(posedge clk)
           begin
	             if(!reset)
	                fifo_down_counter<=0;
                else if(soft_reset)
	                fifo_down_counter<=0;
					 
                else  if(read_enb && !empty)
									begin
									if(mem[read_addr[3:0]][8]==1'b1)
	                fifo_down_counter<=mem[read_addr[3:0]][7:2]+1;
                else if(fifo_down_counter != 0)
	                fifo_down_counter<=fifo_down_counter-1;					  
            end
				end
// fifo full signal logic and empty signal logic

     assign full = ( (write_addr[3:0] == read_addr[3:0]) && (write_addr[4] != read_addr[4]))?1'b1:1'b0;
     assign empty =( (write_addr[3:0] == read_addr[3:0]) && (write_addr[4] == read_addr[4]))?1'b1:1'b0;

endmodule


// fsmm 

module fsm_router_controller(clk,reset,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

// declaring the input and output ports

    input clk,reset,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
    input [1:0]data_in;
    output detect_add,ld_state,laf_state,full_state,rst_int_reg,lfd_state;
    output busy,write_enb_reg;	 
// parameter and internal next_state,present state regs declarations

    parameter DECODE_ADDRESS=3'b000,LOAD_FIRST_DATA=3'b001,WAIT_TILL_EMPTY=3'b010,LOAD_DATA=3'b011,FIFO_FULL_STATE=3'b100,LOAD_AFTER_FULL=3'b101,LOAD_PARITY=3'b110,CHECK_PARITY_ERROR=3'B111;
    reg [1:0]addr_data;
    reg [2:0]present,next;

// storng detecting the destination_address_signal

    always@(*)
       begin
	   if(!reset)
	      addr_data<=0;
      else 
	   	begin
		     if(detect_add)      
	          addr_data <= data_in;
		     end
		
       end

// sequntial logic for present state 

    always@(posedge clk)
        begin
             if(!reset)
               present<=DECODE_ADDRESS;
				 else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
               present<=DECODE_ADDRESS;				 
             else
	       present<=next;
        end

// combinational logic for next state 	

    always@(*)
	      begin
	      	    case(present)
		        DECODE_ADDRESS: 
		                       if((pkt_valid && addr_data == 2'd0 && fifo_empty_0) || (pkt_valid && addr_data== 2'd1 && fifo_empty_1) || (pkt_valid && addr_data == 2'd2 && fifo_empty_2))
				          begin     
			                     next=LOAD_FIRST_DATA;
				          end   
				       else if((pkt_valid && addr_data == 2'd0 && (!fifo_empty_0)) || (pkt_valid && addr_data == 2'd1 && (!fifo_empty_1)) || (pkt_valid && addr_data == 2 && (!fifo_empty_2)))		                                                          
						 begin
					     next=WAIT_TILL_EMPTY;
				           end  
				       else
				   	   begin
					     next=DECODE_ADDRESS;
				     end
		        WAIT_TILL_EMPTY: 
                                       if((addr_data == 2'd0 && fifo_empty_0) || (addr_data == 2'd1 && fifo_empty_1) || (addr_data == 2'd2 && fifo_empty_2))
				          begin     
			                     next=LOAD_FIRST_DATA;
				          end
	                               else
	                                   begin
	                                     next=WAIT_TILL_EMPTY;
                                           end
                       LOAD_FIRST_DATA:
                                            next=LOAD_DATA;
                       LOAD_DATA      :
                                       if(fifo_full)
		                         begin
		                            next=FIFO_FULL_STATE;
				          end
                                       else if ((!fifo_full) && (!pkt_valid))
				          begin
				             next=LOAD_PARITY;		  
                                          end
					else
					   begin
					     next=LOAD_DATA;
				           end
                     FIFO_FULL_STATE :
			              if(!fifo_full)
				         begin    
                                            next=LOAD_AFTER_FULL;
				         end
				      else
                                         begin
				            next=FIFO_FULL_STATE;
				         end
	             LOAD_AFTER_FULL:
                                     if((!parity_done) && (!low_pkt_valid))
		           	        begin
			                   next=LOAD_DATA;
		                        end
	                             else if((!parity_done) && low_pkt_valid)
	                                begin
	                                   next=LOAD_PARITY;
                                        end
				     else if(parity_done)
				        begin
				           next=DECODE_ADDRESS;
			                end
		      LOAD_PARITY  :
		                    next=CHECK_PARITY_ERROR;
	         CHECK_PARITY_ERROR:
                                    if(fifo_full)
		                      begin
		                        next=FIFO_FULL_STATE;
	                              end
                                    else
                                      begin
            			        next=DECODE_ADDRESS;
		                      end
	                        default:next=DECODE_ADDRESS;
            endcase
    
   end
 
// combinational logic for output

// busy is going to low at decode state and load stae other states  it was
// high bcaz it is  not
// allowing new data from the sourece
   assign  busy = (present == DECODE_ADDRESS || present == LOAD_DATA)?1'b0:1'b1;


   assign detect_add =(present == DECODE_ADDRESS)?1'b1:1'b0;
   assign ld_state   =(present == LOAD_DATA)?1'b1:1'b0;
   assign laf_state  =(present == LOAD_AFTER_FULL)? 1'b1:1'b0;
   assign full_state =(present == FIFO_FULL_STATE)?1'b1:1'b0;
   assign lfd_state  =(present == LOAD_FIRST_DATA)?1'b1:1'b0;
   assign rst_int_reg=(present == CHECK_PARITY_ERROR)?1'b1:1'b0;

// write enb reg going tp high only in these state bcaz , these stae have
// capabul for sending payload and parity data to fifo when write enb reg is
// high then only we know which fifo destinastion.neccasary to send the data
// at he particluar stae 
//

  assign write_enb_reg = (present == LOAD_DATA || present == LOAD_PARITY || present == LOAD_AFTER_FULL)? 1'b1:1'b0;

endmodule
		                        			    

// register


 module register_router(clk,reset,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,dout);

// declaring the regs and wires 

      input clk,reset,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
      input [7:0]data_in;
      output reg error,low_pkt_valid,parity_done;
      output reg [7:0]dout;

// creating 4 internal register for header byt storing,internal parity
// byte,packet parity byte,fifio full state byte each are 8 bits bcz all are bytes

     reg [7:0]header_byte,internal_parity_byte,packet_parity_byte,fifo_full_state_byte;

//  writing logic for header byte sstoring
//  header store add detect address and presetn state at load fikrst data and
//  pkt valid is high and corect address destination

   always@(posedge clk)
        begin
             if(!reset)
                begin
                     header_byte<=0;
                end
             else 
				 if(pkt_valid && detect_add && (data_in[1:0] != 2'd3))
                begin
                     header_byte <=data_in;
                end

	end
// logic for fifo sull state byte	
// stroing the data in after full state	
	
	always@(posedge clk)
	    begin
		                if(!reset)
 				   fifo_full_state_byte <= 0;
                                else if(ld_state && fifo_full)
		  		   fifo_full_state_byte <= data_in;
				else if(detect_add)
				   fifo_full_state_byte <= 0;
				else
                                   fifo_full_state_byte <=  fifo_full_state_byte ;				
  				
		  end		
				
 
// writing logic for dout 
// data out is works only at  play load data in header data writhout error 

   always@(posedge clk)
	   begin
		if(!reset)
	 	   begin
		  	dout<=0;
	    	   end
	       else if(detect_add && pkt_valid && (data_in[1:0] != 2'd3))
		   begin
		       dout <=dout;
	           end
               else if(lfd_state)
                   begin
                      dout<=header_byte;
                   end
               else if(ld_state &&(!fifo_full))
	          begin
                      dout <=data_in;
	          end
	       else if(full_state)
	          begin
	            dout <= dout;
	          end
               else if(laf_state)
                  begin
                     dout<=fifo_full_state_byte;
                  end
               else
                   begin
                     dout <=dout;
                   end
         end

// writing logic for internal parity 
// first it is ex or opeartion with header byte and then after contious ex or
// wuith each pay load data stored into internal parity


    always@(posedge clk)
           begin
		if(!reset)
		   begin
		       internal_parity_byte<=0;
	           end
                else if(detect_add)
                   begin
                      internal_parity_byte<=0;
                   end
                else if(lfd_state)
	            begin
	               internal_parity_byte <= internal_parity_byte ^ header_byte;
                    end
                else if(ld_state && !fifo_full)
                     begin
                       internal_parity_byte <= internal_parity_byte ^ data_in;
                     end
                else 
                     begin
			 internal_parity_byte <= internal_parity_byte;
	             end
	   end 	 

// writing logic for packet parity
// packet parity check wheather state uis parity_data only in this state
// only we are getting parity of packets

    always@(posedge clk)
	    begin
		  if(!reset)
		     begin
		        packet_parity_byte <= 0;
	             end
                  else if(detect_add)
                     begin
                       packet_parity_byte <=0;
                     end
                  else if(ld_state && (!pkt_valid) && (!fifo_full))
		      begin
		        packet_parity_byte <=data_in;
	              end
		  else if(!pkt_valid && rst_int_reg)
		      begin
			   packet_parity_byte<=0;
		      end
                 else
                     begin
                        packet_parity_byte <= packet_parity_byte;
                     end
           end

//parity done logic


   always@(posedge clk)
	    begin
		 if(!reset)
		     begin
		       parity_done <= 1'b0;
	             end
                else if(ld_state && (!pkt_valid) && (!fifo_full))
                     begin
                       parity_done <=1'b1;
                     end
                else if(laf_state && (!parity_done) && low_pkt_valid)
                     begin
                       parity_done <=1'b1;
                     end
                else                    
		     	parity_done <=1'b0;         
	       end


// error logic

   always@(posedge clk)
	   begin
	        if(!reset)
	             error <=1'b0;
                else if((packet_parity_byte != internal_parity_byte) && parity_done)
	             error <=1'b1;
                else if((packet_parity_byte == internal_parity_byte) && parity_done)
                     error <=1'b0;  			  
       	        else		     
		       	error <= 0;
	       
		   
            end

// low_packet_valid logic this means if ther is no packets packet goes low so
// this is negation of pkt valid 	    
     			  
   always@(*)
          begin
               if(!reset)
		    low_pkt_valid <=0;
	       else if(parity_done)
		    low_pkt_valid <=1'b1;
	       else if(!pkt_valid)    
                    low_pkt_valid <=1'b1;
	       else
		    low_pkt_valid <=0;   
                 
	   end
endmodule	   
	       

// synchronizer


module synchronizer_router(detect_add,data_in,write_enb_reg,clk,reset,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

// declaring the input and output ports

   input detect_add,write_enb_reg,clk,reset,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
   input [1:0]data_in;
   output vld_out_0,vld_out_1,vld_out_2;
   output reg [2:0]write_enb;
	output reg fifo_full;
	output reg soft_reset_0,soft_reset_1,soft_reset_2;

// creating the internal register

    reg [1:0]addr_data;
    reg [6:0]out_fifo_0_counter; 
	 reg [6:0]out_fifo_1_counter; 
	 reg [6:0]out_fifo_2_counter; 
// storng detecting the destination_address_signal

    always@(posedge clk)
       begin
	   if(!reset)
	      addr_data <=0;
      else if(detect_add)      
	      addr_data <= data_in;	
       end

// destinatoin addrss decodeing and sending write enb signal sending for
// respective fifo

    always@(*)
        begin
            if(!reset)
              write_enb=0;
            else
	      begin
			    if(write_enb_reg)
				  begin
	          case(addr_data)
	             2'b00:write_enb=3'b001;		  
	             2'b01:write_enb=3'b010;		  
	             2'b10:write_enb=3'b100;		  
	             default:write_enb=3'b000;
              endcase
				  end
				 else
                write_enb=3'b000;				 
              end		  
        end

// fifo full signal asserted based on full status of each fifo  	
	     
     always@(*)
	  begin
             if(!reset)
               fifo_full=0;
             else
	        begin
	            case(addr_data)
	              2'b00:fifo_full=full_0;
	              2'b01:fifo_full=full_1;
	              2'b10:fifo_full=full_2;
		      default:fifo_full=0;
	           endcase
	        end
	   end
// valid out signal genration

    assign vld_out_0=~empty_0;
    assign vld_out_1=~empty_1;
    assign vld_out_2=~empty_2;

// soft start signal generation foer each fifo 
// the respective     soft reset signal go high if read _ en  is not asserted
// with in colk cycle so we take colkc counter to counte clks 
// vld out being assrent being assreted and taking the reset condiotn also

wire count_0 = (out_fifo_0_counter == 6'd29) ? 1'b1:1'b0;
wire count_1 = (out_fifo_1_counter == 6'd29) ? 1'b1:1'b0;
wire count_2 = (out_fifo_2_counter == 6'd29) ? 1'b1:1'b0;

   always@(posedge clk)
	  begin
             if(!reset)
                  begin
                   soft_reset_0<=0;
		            out_fifo_0_counter<=0;
	           end
              else if(!vld_out_0)
	           begin    
                   soft_reset_0<=0;
		            out_fifo_0_counter<=0;
	           end
				  else if (read_enb_0)
				    begin
					   soft_reset_0<=0;
						out_fifo_0_counter <=0;
					  end	
              else if(count_0 )
	           begin   
	            out_fifo_0_counter <=0;
                    soft_reset_0<=1;	    
	           end
	          else 
	           begin   
	           out_fifo_0_counter <= out_fifo_0_counter+1;
	           soft_reset_0<=0;
		   end 
          end
			 
			  always@(posedge clk)
	  begin
             if(!reset)
                  begin
                   soft_reset_1<=0;
		            out_fifo_1_counter<=0;
	           end
              else if(!vld_out_1)
	           begin    
                   soft_reset_1<=0;
		            out_fifo_1_counter<=0;
	           end
				  else if (read_enb_1)
				    begin
					   soft_reset_1 <=0;
						out_fifo_1_counter <=0;
					  end	
              else if(count_1) 
	          begin   
	            out_fifo_1_counter <=0;
                    soft_reset_1<=1;	    
	           end
	          else 
	           begin   
	           out_fifo_1_counter <= out_fifo_1_counter+1;
	           soft_reset_1<=0;
		   end 
          end
			 
			  always@(posedge clk)
	  begin
             if(!reset)
                  begin
                   soft_reset_2<=0;
		            out_fifo_2_counter<=0;
	           end
              else if(!vld_out_2)
	           begin    
                   soft_reset_2<=0;
		            out_fifo_2_counter<=0;
	           end
				  else if (read_enb_2)
				    begin
					   soft_reset_2 <=0;
						out_fifo_2_counter <=0;
					  end	
              else if(count_2)
	          begin   
	            out_fifo_2_counter <=0;
                    soft_reset_2<=1;	    
	           end
	          else 
	           begin   
	           out_fifo_2_counter <= out_fifo_2_counter+1;
	           soft_reset_2<=0;
		   end 
          end
 endmodule	  

                    

// top module

module router_top(clk,reset,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,error,busy);

// input and output declaration
    input clk,reset,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
    input [7:0]data_in;
    output  [7:0]data_out_0,data_out_1,data_out_2;
    output valid_out_0,valid_out_1,valid_out_2,error,busy;
// declaring the internal wire for sub block connections
// fifo output wires

   wire empty_0,full_0,empty_1,full_1,empty_2,full_2; 

// synchronizer output wires

   wire soft_reset_0,soft_reset_1,soft_reset_2;
   wire [2:0]write_enb;

// fsm output wires

  wire detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;

// register output internal connections

  wire parity_done,low_pkt_valid;
  wire [7:0]data_out; 

/* 
module fsm_router_controller(clk,reset,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
*/

fsm_router_controller FSM(clk,reset,pkt_valid,busy,parity_done,data_in[1:0],soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,empty_0,empty_1,empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

/*
module synchronizer_router(detect_add,data_in,write_enb_reg,clk,reset,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
*/

synchronizer_router SYNCHRONIZER(
	detect_add,data_in[1:0],write_enb_reg,clk,reset,valid_out_0,valid_out_1,valid_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

/*

 module register_router(clk,reset,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,dout);
*/

register_router REGISTER(clk,reset,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,data_out);

/*

module fifo_16x9_router(clk,reset,data_in,write_enb,read_enb,soft_reset,lfd_state,full,empty,data_out);
*/
  
fifo_16x9_router FIFO1(clk,reset,data_out,write_enb[0],read_enb_0,soft_reset_0,lfd_state,full_0,empty_0,data_out_0);
fifo_16x9_router FIFO2(clk,reset,data_out,write_enb[1],read_enb_1,soft_reset_1,lfd_state,full_1,empty_1,data_out_1);
fifo_16x9_router FIFO3(clk,reset,data_out,write_enb[2],read_enb_2,soft_reset_2,lfd_state,full_2,empty_2,data_out_2);

  
endmodule

















///******************************************************************//
//                                                                   //
//                   INTERFACES                                   //
//                                                                   //
//*******************************************************************//


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

		
		
		
		
///******************************************************************//
//                                                                   //
//              UVM TB COMPONENTS                                    //
//                                                                   //
//*******************************************************************//		
		
		 
// Top module uvm


module top();

// including the  uvm file  

       import uvm_pkg :: *;
      // include "uvm_macros.svh"
 
// importing  the tb files 

       import router_pkg :: *; 

      
// generating clock
  
       bit clk = 1'b0;
       always #10 clk = ~clk;          
      
// instantiating interace

        router_source_if VIF(clk);
        router_destin_if VIF0(clk);
        router_destin_if VIF1(clk);
        router_destin_if VIF2(clk);



 // instantiating DUT
// top module
//module router_top(clk,reset,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,error,busy);


     router_top DUT(
                    .clk(clk),
                    .reset(VIF.reset),
                    .read_enb_0(VIF0.read_enb),
                    .read_enb_1(VIF1.read_enb),
                    .read_enb_2(VIF2.read_enb),
                    .data_in(VIF.data_in),
                    .pkt_valid(VIF.pkt_valid),
                    .data_out_0(VIF0.data_out),
                    .data_out_1(VIF1.data_out),
                    .data_out_2(VIF2.data_out),
                    .valid_out_0(VIF0.valid_out),
                    .valid_out_1(VIF1.valid_out),
                    .valid_out_2(VIF2.valid_out),
                    .error(VIF.error),
                    .busy(VIF.busy)

                     );


        initial begin

                 `ifdef VCS
                  $fsdbDumpvars(0,top);
                 `endif 

// setting the virtual interface  for source agent and 3 destination agents	
                 uvm_config_db #(virtual router_source_if) :: set(null,"*","vif",VIF);
                 uvm_config_db #(virtual router_destin_if) :: set(null,"*","vif0",VIF0);
                 uvm_config_db #(virtual router_destin_if) :: set(null,"*","vif1",VIF1);
                 uvm_config_db #(virtual router_destin_if) :: set(null,"*","vif2",VIF2);
// calling the runtest()

                  run_test();
            end    


endmodule



// class for destinationj agetn configratoion data base object


class destin_agent_config extends uvm_object;


// factory registration 

          `uvm_object_utils(destin_agent_config)

// declare the varible required

            uvm_active_passive_enum is_active = UVM_ACTIVE;
// declare the virtual inteface handle
  
                virtual router_destin_if  vif;


// fucntion new construction

           function new(string name = "destin_agent_config");

                         super.new(name);

           endfunction
    


endclass



// source  agent config  

class source_agent_config extends uvm_object;


// factory registration

        `uvm_object_utils(source_agent_config)


     uvm_active_passive_enum is_active = UVM_ACTIVE;
    

// declare virtual interfae handle

        virtual router_source_if vif;

// function new constructor


       function new(string name = "source_agent_config" );
 
             super.new(name);

       endfunction    





endclass





//destination driver class

class destin_driver extends uvm_driver #(destin_xtn);

// factory registration

         `uvm_component_utils(destin_driver)

// declare the virtual interface handle

         destin_agent_config m_cfg;

         virtual router_destin_if.D_DRV vif; 

// funcion new constructor


       function new (string name = "destin_driver", uvm_component parent = null );

       
                super.new(name,parent);
                 
        endfunction
   
// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
                // `uvm_info(get_full_name(),"this is driver destin",UVM_NONE)
                 if(!uvm_config_db #(destin_agent_config) :: get(this,"","destin_agent_config",m_cfg))
                       `uvm_fatal(get_full_name(),"cannot get  the destin agetn config handle driver  m_cfg from desti agetn top")

         endfunction
// connect phase connect the virtual interface to local interface 

         function void connect_phase(uvm_phase phase);

                vif = m_cfg.vif;

         endfunction
		 
 
 // task run_phase here we send req and and then data req sended to new method for driving
  
          task run_phase(uvm_phase phase);
 
               forever 
                      begin
                             super.run_phase(phase);
                         
                             seq_item_port.get_next_item(req);
                             

                               send_to_dut();
                               req.print();
                             
                              seq_item_port.item_done();
                             
                      end
          endtask


// task send to dut

         task send_to_dut();
               
                  while(vif.destin_drv.valid_out !== 1'b1)
	              begin
                        @(vif.destin_drv);
                      end 
				   
                   repeat(req.delay)
                          begin 
                               @(vif.destin_drv);
                          end
                   vif.destin_drv.read_enb <= 1'b1;
                  
                                 
                   while(vif.destin_drv.valid_out !== 1'b0)
		          begin
                                @(vif.destin_drv);
			  end  
					
                   vif.destin_drv.read_enb <= 1'b0;
		    @(vif.destin_drv);
                    
                 
        endtask 


       

endclass

           	

// destination monitor class

class destin_monitor extends uvm_monitor;

// factory registration

        `uvm_component_utils(destin_monitor)

// declare virtual interface handle

            destin_agent_config m_cfg;
            virtual router_destin_if.D_MON vif; 
// declaring the destin transaction
 
                  destin_xtn dmon;
				  
// tlm port for write to score board	

        uvm_analysis_port #(destin_xtn) dmon_port;			  
           
// function new constructor 


        function new(string name = "destin_monitor" , uvm_component parent = null );

                     super.new(name,parent);
		             dmon_port = new ("dmon_port",this); 
					 
         endfunction 

// build phase
         function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
                // `uvm_info(get_full_name(),"this is monitor destin",UVM_NONE)
                  if(!uvm_config_db #(destin_agent_config) :: get(this,"","destin_agent_config",m_cfg))
                       `uvm_fatal(get_full_name(),"cannot get  the destin agetn config handle monitor m_cfg from desti agetn top")

         endfunction
		 
// connect_phase connecting the virtual interfcce to local interface handle

         function void connect_phase(uvm_phase phase);
       
                  vif = m_cfg.vif;
 
         endfunction

// run phase


          task run_phase(uvm_phase phase);

               forever
                      begin
                         
                         collect_data();
                         dmon.print();
						 dmon_port.write(dmon);
                      end
					  
          endtask 

// collect the data from interface 

         task collect_data();
                
               dmon = destin_xtn :: type_id :: create("dmon");
                  
               while( vif.destin_mon.read_enb !== 1'b1)
	             begin
                            @(vif.destin_mon);                      
                     end      
            	@(vif.destin_mon);			
                dmon.header_byte = vif.destin_mon.data_out;
				
                @(vif.destin_mon);
                dmon.payload = new[dmon.header_byte[7:2]];				
               foreach(dmon.payload[i])
                   begin
                        while( vif.destin_mon.valid_out !== 1'b1)
                             begin
                                  @(vif.destin_mon);
                             end   
                        dmon.payload[i] = vif.destin_mon.data_out;                     
                        @(vif.destin_mon);
						
                   end
                dmon.parity_byte = vif.destin_mon.data_out;
                   @(vif.destin_mon);
				
         endtask


endclass


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


//destination sequencer class

class destin_seqr extends uvm_sequencer #(destin_xtn);

// factory registration

      `uvm_component_utils(destin_seqr)

// fuinction new constructor

      function new (string name="destin_seqr" , uvm_component parent= null);

               super.new(name,parent);


      endfunction 
	  
// build phase
	  
     /*    function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
                 
         endfunction
*/

endclass

  

// class deriver for source

class source_driver extends uvm_driver #(source_xtn);


// factory registration

      `uvm_component_utils(source_driver)
     

// declare the virtual interface

         virtual router_source_if.S_DRV vif;
          source_agent_config m_cfg;

// function new constructor 

       function new(string name = "source_driver" , uvm_component parent = null);


              super.new(name,parent);
              

       endfunction:new
	   
// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
                //`uvm_info(get_full_name(),"this is driver soruce",UVM_NONE)
                if(!uvm_config_db #(source_agent_config) :: get(this,"","source_agent_config",m_cfg))
                       `uvm_fatal(get_full_name(),"cannot get  the source agent config handle driver m_cfg from source agent top")

         endfunction

// connect phase

          function void connect_phase(uvm_phase phase);

                   vif = m_cfg.vif;

          endfunction	   

// task run phase and send to dut method calling 

        task run_phase(uvm_phase phase);
               super.run_phase(phase); 
                     @(vif.source_drv);
                    vif.source_drv.reset <= 1'b0;
                    @(vif.source_drv);
                    vif.source_drv.reset <= 1'b1;
                    

               forever begin
			                
               seq_item_port.get_next_item(req);

               send_to_dut(req); 
               seq_item_port.item_done();
               req.print();
               end  
        endtask

// send to dut 

      task send_to_dut(source_xtn req);

           while(vif.source_drv.busy != 1'b0)
		   begin
                 @(vif.source_drv);
		   end		  
           vif.source_drv.pkt_valid <= 1'b1;
           vif.source_drv.data_in   <=  req.header_byte;
           @(vif.source_drv); 
           foreach(req.payload[i])
                    begin
                        while(vif.source_drv.busy != 1'b0)
			begin
                            @(vif.source_drv);
			end 
                        vif.source_drv.data_in <= req.payload[i];
                        @(vif.source_drv);
                    end   
  
          vif.source_drv.pkt_valid <= 1'b0;
          vif.source_drv.data_in <= req.parity_byte; 
           repeat(2)
          @(vif.source_drv);
      endtask




endclass

     		    
       	       
// class source monitor

class source_monitor extends uvm_monitor;

// factory registration

     `uvm_component_utils(source_monitor)

// dfeclare  virtual interface

          virtual router_source_if.S_MON vif;
          source_agent_config m_cfg;
		  source_xtn smon;

// declaring the anlysis port

          uvm_analysis_port #(source_xtn) smon_port;


// function new constructor

       function new (string name = "source_monitor",uvm_component parent = null );

              super.new(name,parent);
              smon_port = new("smon_port",this);			   
 
       endfunction 
	   
// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase);  
               // `uvm_info(get_full_name(),"this is monior soruce",UVM_NONE)
                if(!uvm_config_db #(source_agent_config) :: get(this,"","source_agent_config",m_cfg))
                       `uvm_fatal(get_full_name(),"cannot get  the source agent config handle monitor m_cfg from source agent top")


         endfunction

// connect phase

          function void connect_phase(uvm_phase phase);

                    vif = m_cfg.vif;

          endfunction	   
      
// run phase

        task run_phase(uvm_phase phase);

             forever 
			       begin
				        
                        super.run_phase(phase);
                        collect_data();
                         smon.print();
                         smon_port.write(smon);						 
						
                   end
        endtask     

// collect task for from interace to monnitor 

        task collect_data();
		    smon = source_xtn :: type_id :: create("smon");
            while(vif.source_mon.busy != 1'b0)			
	              @(vif.source_mon);
            while(vif.source_mon.pkt_valid != 1'b1)
               	  @(vif.source_mon);
            smon.header_byte = vif.source_mon.data_in;
            @(vif.source_mon);
            smon.payload = new[smon.header_byte[7:2]];
            foreach(smon.payload[i])
                  begin 
				        while(vif.source_mon.busy != 1'b0)
                        begin						
						@(vif.source_mon);
						end 
                        smon.payload[i] = vif.source_mon.data_in;
                        @(vif.source_mon);
                  end
            smon.parity_byte = vif.source_mon.data_in;
			
			  @(vif.source_mon);
			  @(vif.source_mon);
			  smon.error = vif.source_mon.error;
			  $display("Signal Error From Source Monitor = %0b",smon.error);
 				  
		endtask


endclass


// source sequence class

class source_seq extends uvm_sequence #(source_xtn);

// factory registration

     `uvm_object_utils(source_seq)

// addres declaration

      bit [1:0] addr;

// function new constructor

      function new(string name = "source_seq");

            super.new(name);
	//`uvm_info(get_full_name(),"this is sequence soruce",UVM_NONE)

      endfunction    

endclass
 
//---------------- Extended class  Small packets-----------//

class small_seq extends source_seq;

// factory registration

     `uvm_object_utils(small_seq)

// function new constructor

     function new (string name = "small_seq");

         super.new(name);

     endfunction 

// body task =generate 1 to 20 packets payload generates

      task body();
         if(!uvm_config_db #(bit[2])::get(null,get_full_name(),"bit",addr))
                  `uvm_fatal(get_full_name(),"cannot get the address from test class are set it check")

         req = source_xtn :: type_id :: create("req");
         start_item(req);
         assert(req.randomize() with {req.header_byte[1:0] == addr;req.header_byte[7:2] inside{[1:21]};} )
             else 
                begin
                      `uvm_info(get_full_name(),"!!!!!!!!!!!randomization is failed in source seqs at small seq!!!!!!!!!",UVM_LOW)
                end

          
         finish_item(req);

      endtask

endclass


// -------------- Extended clas of Medium packets ---------//


class medium_seq extends source_seq;

// factory registration
     `uvm_object_utils(medium_seq)

// function new constructor

       function new(string name = "medium_seq");

               super.new(name);

       endfunction

// task body for packets stimulus 22 to 41

       task body();
         if(!uvm_config_db #(bit[2])::get(null,get_full_name(),"bit",addr))
                  `uvm_fatal(get_full_name(),"cannot get the address from test class are set it check")

           req = source_xtn :: type_id :: create("req");
           start_item(req);
           assert(req.randomize() with {req.header_byte[7:2] inside {[22:41]};
                                      req.header_byte[1:0] == addr; } ) 
                else 
                    begin
                         `uvm_info(get_full_name(),"!!!!!!!!randomization is failed in source seqs at medium seq!!!!!!!!!!!",UVM_LOW)
                     end 
            finish_item(req);
         
       endtask

endclass


// large sequnce for generating the from 42 to 63

class large_seq extends source_seq;

// factory registration
   
     `uvm_object_utils(large_seq)

// function new constructor
 
        function new(string name = "large_seq" );
  
                   super.new(name); 
 
         endfunction 
// task body for 42 to 63


       task body();
        if(!uvm_config_db #(bit[2])::get(null,get_full_name(),"bit",addr))
                  `uvm_fatal(get_full_name(),"cannot get the address from test class are set it check")

           req = source_xtn :: type_id :: create("req");
           start_item(req);
           assert(req.randomize() with {req.header_byte[7:2] inside {[42:63]};
                                      req.header_byte[1:0] == addr; } ) 
                else 
                    begin
                         `uvm_info(get_full_name(),"!!!!!!!!randomization is failed in source seqs at medium seq!!!!!!!!!!!",UVM_LOW)
                     end 
            finish_item(req);
       endtask

endclass



// source  sequnce class

class source_seqr extends uvm_sequencer #(source_xtn);


// factory registration

     `uvm_component_utils(source_seqr)


// fcuntion new constructor


      function new(string name ="source_seqr", uvm_component parent = null);
  
              super.new(name,parent);
			  

      endfunction:new     





endclass


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


// virtual sequncer class

class virtual_seqr extends uvm_sequencer #(uvm_sequence_item);

// factory registration 
   
        `uvm_component_utils(virtual_seqr)


// declaring the handle for source and destination sequencer
         router_env_config m_cfg;
         source_seqr s_seqr[];


// fuunction new construction 

         function new(string name= "virtual_seqr" , uvm_component parent = null);
 
                          super.new(name,parent);

        endfunction

// build phase

         function void build_phase(uvm_phase phase);

                 super.build_phase(phase); 
                 if(!uvm_config_db #(router_env_config) :: get(this,"","router_env_config",m_cfg))
                       `uvm_fatal(get_full_name()," cannot get the router_env_config handle mcfg from tesdt class in virtual sequncerr") 
  
                 s_seqr = new[m_cfg.no_of_source]; 
         endfunction




endclass:virtual_seqr





class tb_scoreboard extends uvm_scoreboard;


// factory registration
 
          `uvm_component_utils(tb_scoreboard)

// declaring the  handle for env_config 
 
          router_env_config m_cfg;
		  
// declaring the handle for tlm ports

         uvm_tlm_analysis_fifo #(source_xtn) source_fifo[];
         uvm_tlm_analysis_fifo #(destin_xtn) destin_fifo[];	

// declaring the source and destination transaction class

        source_xtn s_xtn;
        source_xtn source_cov_xtn;

        destin_xtn d_xtn;
        destin_xtn destin_cov_xtn;
 		

// write fucntion covrage cover group

      covergroup source_cg;
	  
	    ADDER:   coverpoint s_xtn.header_byte[1:0]{
                                                             
                                                            bins b1 = {2'b00};
															bins b2 = {2'b01};
                                                            bins b3 = {2'b10};															

                                                          }	
        DATA_IN: coverpoint s_xtn.header_byte[7:2]{

                                                           bins b1 = {[1:21]};
														   bins b2 = {[22:41]};
														   bins b3 = {[42:63]}; 
		
	                                                        }   
        ERROR: 	 coverpoint s_xtn.error {
          
                                                           bins b1 = { 1'b1 };
                                                           bins b2 = { 1'b0 };

                                                  } 

       /* BUSY:     coverpoint s_xtn.busy {

                                                           bins b1 = { 1'b1 };
                                                           bins b2 = { 1'b0	};													   
	  
	                                             } */
												 
	   // CROSS_ALL: cross ADDER,DATA_IN,ERROR,BUSY;											 
												 
	  endgroup
	  
	  covergroup destin_cg;
	  
	       VALID_OUT: coverpoint d_xtn.valid_out{
		   
		                                                    bins b1 = {1'b1};
															bins b2 = {1'b0};
															
														  }
           DATA_OUT: coverpoint d_xtn.header_byte[7:2]{

                                                           bins b1 = {[1:21]};
														   bins b2 = {[22:41]};
														   bins b3 = {[42:63]}; 
		
	                                                        }														  
	  
	  endgroup


// we have to implement check method  for comparing the data 


// function new constructor

          function new(string name = "tb_scoreboard",uvm_component parent= null );

                super.new(name,parent);
                source_cg = new();
                destin_cg = new(); 				
                
          endfunction:new
 

// build_phase

         function void build_phase(uvm_phase phase);

                    super.build_phase(phase);
					
				    if(!uvm_config_db #(router_env_config) :: get (this,"","router_env_config",m_cfg))
					     begin
				        `uvm_fatal(get_full_name(),"cannot get he router_env_config handle m_cg in scoreboard ")
                         end 
						 
					
					source_fifo = new [m_cfg.no_of_source];
					
					foreach(source_fifo[i])
					      begin
                               source_fifo[i] = new ("source_fifo",this);
						   end	
						   
                    destin_fifo = new[m_cfg.no_of_destin];
				
					foreach(destin_fifo[i]) 
					      begin
						      destin_fifo[i] = new($sformatf("destin_fifo[%0d]",i),this);
						  end 
         endfunction		 


        task run_phase(uvm_phase phase);
              super.run_phase(phase);
              forever
			         begin
					      fork
                             begin
							 
			                      source_fifo[0].get(s_xtn);
				                  source_cg.sample();
								  
							 end 
                             fork
                                 begin
								 
								      destin_fifo[0].get(d_xtn);
				                      destin_cg.sample();

								 end
                                 begin
								 
								      destin_fifo[1].get(d_xtn);
				                      destin_cg.sample();
									  
								 end
                                 begin
								 
								      destin_fifo[2].get(d_xtn);
				                      destin_cg.sample();
		  
								 end
                             join_any
                             disable fork;							                   
                          join
						  compare(s_xtn,d_xtn); 
                   $display("\n=========================================================================\n");
		           $display("\n source  side functional coverage = %.3f \n",source_cg.get_coverage);
				   $display("\n destin  side functional coverage = %.3f \n",destin_cg.get_coverage);	
                   $display("\n=========================================================================\n");						  
                     end

        endtask:run_phase  


// task for comparing the source and destination packets

        task compare(source_xtn s_xtn,destin_xtn d_xtn);
		
		       bit check;
			   
		       if(s_xtn.header_byte == d_xtn.header_byte)
			        begin 
					     $display("\n===================== Header_Byte Matched SuccessFull =====================\n");
						 check  = 1'b1;
				    end
               else
                    begin
					     $display("\n===================== Header_Byte Not Matched =====================\n");
						 check  = 1'b0;
					end	
					
                if(s_xtn.payload == d_xtn.payload)
			        begin 
					     $display("\n===================== Payload Matched SuccessFull =====================\n");
						 check  = 1'b1;
				    end
               else
                    begin
					     $display("\n===================== Payload Not Matched =====================\n");
						 check  = 1'b0;
					end	
                if(s_xtn.parity_byte == d_xtn.parity_byte)
			        begin 
					     $display("\n===================== Parity_Byte Matched SuccessFull =====================\n");
						 check  = 1'b1;
				    end
               else
                    begin
					     $display("\n===================== Parity_Byte Not Matched =====================\n");
						 check  = 1'b0;
					end	
					
				if(check == 1'b1)
                     begin
					 
                        $display("\n=========================================================================\n");
                        $display("\n     SUCCESSFULLY MATCHED    \n");
						$display("\n=========================================================================\n");
 						
                     end	
                else
                    begin
					 
                        $display("\n=========================================================================\n");
                        $display("\n     PACKETS NOT MATCHED    \n");
						$display("\n=========================================================================\n");
 	                end	

				   
							
		endtask




endclass:tb_scoreboard




// environment class 

class tb_env extends uvm_env;

// factory registration

           `uvm_component_utils(tb_env)

// declaring the handle for vritual seqr and source agent top and destin agent top i dont know 

         source_agent_top  source_agth;
         destin_agent_top  destin_agth;
         tb_scoreboard     sb;


// declaring the int varialbles for no of wr agent and  no of read agent - idont know


// declaring for the scoreboard and virtual sequencer no  i dont know

         virtual_seqr  v_seqr;
 
// declaring the  handle for the env_config class to get and 

       router_env_config m_cfg;

// construction new function
 
         function new(string name = "tb_env", uvm_component parent = null);

                       super.new(name,parent);

         endfunction:new
        
// build phase 

        function void build_phase(uvm_phase phase);
              super.build_phase(phase);
               if(! uvm_config_db #(router_env_config) :: get(this,"","router_env_config",m_cfg))
                     `uvm_fatal(get_full_name(),"cannot get the router_env_config handle m_cfg from test in env_tb ")
               source_agth = source_agent_top :: type_id :: create("source_agth",this);
               destin_agth = destin_agent_top :: type_id :: create("destin_agth",this);
               sb          = tb_scoreboard    :: type_id :: create("sb",this); 
               v_seqr      = virtual_seqr     :: type_id :: create("v_seqr",this);      

        endfunction
         

// connect phase

       function void connect_phase(uvm_phase phase);

              foreach(v_seqr.s_seqr[i])
                    begin
                       v_seqr.s_seqr[i] = source_agth.agth[i].seqr;
                    end
					
			  for(int j = 0; j < m_cfg.no_of_source;j++)
                    begin			  
			             source_agth.agth[j].monh.smon_port.connect(sb.source_fifo[j].analysis_export);
			        end
					
              for(int i = 0; i < m_cfg.no_of_destin ; i++)
                    begin
                         destin_agth.agth[i].monh.dmon_port.connect(sb.destin_fifo[i].analysis_export);
                    end						 

       endfunction:connect_phase



endclass:tb_env





// test class 

class base_test extends uvm_test;

// factory registration 
 
         `uvm_component_utils(base_test)

// declaring the test bench env class handle and env_config handles

           tb_env envh;
           router_env_config m_cfg;

           source_agent_config  m_source_agth[];
           destin_agent_config  m_destin_agth[];

            int no_of_source = 1;
            int no_of_destin = 3;

// header byte destination address setting 
 
           bit [2]addr;

// funciton new constructor 

          function new(string name = "base_test",uvm_component parent = null );

                   super.new(name,parent);

          endfunction
// config function

               function void config_data();

                            m_source_agth = new[no_of_source];
                            m_destin_agth = new[no_of_destin];

                            foreach(m_source_agth[i]) 
                                   begin
                                        m_source_agth[i] = source_agent_config :: type_id :: create($sformatf("m_source_agth[%0d]",i));
                                        m_source_agth[i].is_active = UVM_ACTIVE;
                                        if(!uvm_config_db #(virtual router_source_if) :: get(this,"","vif",m_source_agth[i].vif))
                                             `uvm_fatal(get_full_name(),"cannot get the interface handle from source are set in top")

                                   end
                            foreach(m_destin_agth[i])
                                   begin
                                        m_destin_agth[i] = destin_agent_config :: type_id :: create($sformatf("m_destin_agth[%0d]",i));
                                        m_destin_agth[i].is_active = UVM_ACTIVE;
                                        if(!uvm_config_db #(virtual router_destin_if) :: get(this,"",$sformatf("vif%0d",i),m_destin_agth[i].vif))
                                             `uvm_fatal(get_full_name(),"cannot get the interface handle from destination are set in top")

                                   end
                            m_cfg.no_of_source = no_of_source;
                            m_cfg.no_of_destin = no_of_destin;
                

               endfunction                  

// fucniton build_phase


         function void build_phase(uvm_phase phase);
                      
               super.build_phase(phase);
               m_cfg = router_env_config :: type_id :: create("m_cfg");

               m_cfg.m_source_agth = new[no_of_source];
               m_cfg.m_destin_agth = new[no_of_destin];
               
               config_data();
   
               foreach(m_source_agth[i])
                          m_cfg.m_source_agth[i] = m_source_agth[i]; 

               foreach(m_destin_agth[i])
                          m_cfg.m_destin_agth[i] = m_destin_agth[i]; 
               
                uvm_config_db #(router_env_config) :: set(this,"*","router_env_config",m_cfg);
                envh = tb_env :: type_id :: create("envh",this);


         endfunction:build_phase
		 
// function void end o elaboration 		 

        function void end_of_elaboration_phase(uvm_phase phase);


               uvm_top.print_topology();
			   


       endfunction 
	   
	   

endclass

//-------------Extended base test class to small test class ---------------//

class small_seq_test extends base_test;

// factory regisdtration

          `uvm_component_utils(small_seq_test)

// declaring the virtual smal_seq class handle

              //small_seq seqh;
       virtual_small_seq s_seqh;
       destin_seq  dseq;
// function new constructor

       function new(string name = "small_seq_test",uvm_component parent);

              super.new(name,parent);
              addr = 2'd0;

              uvm_config_db #(bit[2])::set(this,"*","bit",addr);

       endfunction 

// build phase

         function void build_phase(uvm_phase phase);

                super.build_phase(phase);
         
         endfunction

// run phase of small test seq

// task run phase

           task run_phase(uvm_phase phase);
                  phase.raise_objection(this);
                         super.run_phase(phase);
		                s_seqh = virtual_small_seq :: type_id :: create("s_seqh");
                        dseq  = destin_seq        :: type_id :: create("dseq");
                        repeat(5)
                        begin 
                        fork
                        s_seqh.start(envh.v_seqr);
                        dseq.start(envh.destin_agth.agth[addr].seqr);
                        join
                        end  
		  phase.drop_objection(this);

           endtask	

endclass

//----------Extended base test class to medium test class -------------//

class medium_seq_test extends base_test;

// factory registration

      `uvm_component_utils(medium_seq_test)


// declaring the handle for medum sdeq generater

         // medium_seq seqh;

       virtual_medium_seq m_seqh;
       destin_seq  dseq;

      
// build phase

         function void build_phase(uvm_phase phase);

                super.build_phase(phase);
         
         endfunction

// function new constructor

       function new(string name = "medium_seq_test", uvm_component parent );

                  super.new(name,parent);
              addr = 2'd1;

              uvm_config_db #(bit[2])::set(this,"*","bit",addr);


       endfunction

// run phase of medium test seq


          task run_phase(uvm_phase phase);
                  phase.raise_objection(this);
                         super.run_phase(phase);
                         m_seqh = virtual_medium_seq :: type_id :: create("m_seqh");
                         dseq  = destin_seq        :: type_id :: create("dseq");
                         repeat(5)
                         begin
                        fork
                        m_seqh.start(envh.v_seqr);
                        dseq.start(envh.destin_agth.agth[addr].seqr);
                        join
                        end
                  phase.drop_objection(this);
          endtask

endclass


// --------------- Extended base test class to Large test class ---------//

class large_seq_test extends base_test;

// factory registration

       `uvm_component_utils(large_seq_test)

// declare the handle of large seq

         //large_seq seqh;

          virtual_large_seq l_seqh;
          destin_seq  dseq;


// build phase

         function void build_phase(uvm_phase phase);

                super.build_phase(phase);
         
         endfunction


// function new constructor

         function new(string name = "large_seq_test" , uvm_component parent);

                 super.new(name,parent);  
              addr = 2'd2;

              uvm_config_db #(bit[2])::set(this,"*","bit",addr);
  

         endfunction     

// run_phase of large test seq


         task run_phase(uvm_phase phase);
                     phase.raise_objection(this);
                          super.run_phase(phase);
                          l_seqh = virtual_large_seq :: type_id :: create("l_seqh");
                          dseq  = destin_seq        :: type_id :: create("dseq");
                         repeat(5)
                          begin
                        fork
                        l_seqh.start(envh.v_seqr);
                        dseq.start(envh.destin_agth.agth[addr].seqr);
                        join
                         end

                    phase.drop_objection(this);                
         endtask



endclass


// packaGES files


package router_pkg;

// including the all ruoter file

import uvm_pkg ::*;

`include "uvm_macros.svh"

`include "destin_agent_config.sv"
`include "source_agent_config.sv"
`include "router_env_config.sv" 


`include "destin_xtn.sv"

`include "source_xtn.sv"

`include "source_seq.sv"
`include "source_seqr.sv"   
`include "source_driver.sv" 
`include "source_monitor.sv"  
`include "source_agent.sv"  
`include "source_agent_top.sv"  

`include "destin_seq.sv"  
`include "destin_driver.sv"  
`include "destin_monitor.sv"  
`include "destin_seqr.sv" 
`include "destin_agent.sv"  
`include "destin_agent_top.sv"  


`include "virtual_seqr.sv"  
`include "virtual_seq.sv"  
`include "tb_scoreboard.sv" 
`include "tb_env.sv"  
`include "base_test.sv"

//`include "top.sv"  

endpackage


// MAKE files

/*

#Makefile for UVM Testbench - Lab 10

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = VCS


FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64


RTL= ../rtl/*
work= work #library name
SVTB1= ../tb/top.sv
INC = +incdir+../tb +incdir+../test +incdir+../source_agent_top +incdir+../destin_agent_top
SVTB2 = ../test/router_pkg.sv
VSIMOPT= -vopt -voptargs=+acc 
VSIMCOV= -coverage -sva 
VSIMBATCH1= -c -do  " log -r /* ;coverage save -onexit mem_cov1;run -all; exit"
VSIMBATCH2= -c -do  " log -r /* ;coverage save -onexit mem_cov2;run -all; exit"
VSIMBATCH3= -c -do  " log -r /* ;coverage save -onexit mem_cov3;run -all; exit"
VSIMBATCH4= -c -do  " log -r /* ;coverage save -onexit mem_cov4;run -all; exit"


help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                  								!"
	@echo "! clean   	=>  clean the earlier log and intermediate files.  						!"
	@echo "! sv_cmp    	=>  Create library and compile the code.           						!"
	@echo "! run_test	=>  clean, compile & run the simulation for small packets in batch mode.		!" 
	@echo "! run_test1	=>  clean, compile & run the simulation for medium packets in batch mode.			!" 
	@echo "! run_test2	=>  clean, compile & run the simulation for large packets in batch mode.			!"
	@echo "! run_test3	=>  clean, compile & run the simulation for ram_even_addr_test in batch mode.			!" 
	@echo "! view_wave1 =>  To view the waveform of small packets	    						!" 
	@echo "! view_wave2 =>  To view the waveform of medium packets	    						!" 
	@echo "! view_wave3 =>  To view the waveform of large packets 	  						!" 
	@echo "! view_wave4 =>  To view the waveform of ram_even_addr_test    							!" 
	@echo "! regress    =>  clean, compile and run all testcases in batch mode.		    				!"
	@echo "! report     =>  To merge coverage reports for all testcases and  convert to html format.			!"
	@echo "! cov        =>  To open merged coverage report in html format.							!"
	@echo ====================================================================================================================

clean : clean_$(SIMULATOR)
sv_cmp : sv_cmp_$(SIMULATOR)
run_test : run_test_$(SIMULATOR)
run_test1 : run_test1_$(SIMULATOR)
run_test2 : run_test2_$(SIMULATOR)
run_test3 : run_test3_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
view_wave4 : view_wave4_$(SIMULATOR)
regress : regress_$(SIMULATOR)
report : report_$(SIMULATOR)
cov : cov_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1) 	
	
run_test_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf wave_file1.wlf -l test1.log  -sv_seed random  work.top +UVM_TESTNAME=small_seq_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1
	
run_test1_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2)  -wlf wave_file2.wlf -l test2.log  -sv_seed random  work.top +UVM_TESTNAME=medium_seq_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2
	
run_test2_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3)  -wlf wave_file3.wlf -l test3.log  -sv_seed random  work.top +UVM_TESTNAME=large_seq_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov3
	
run_test3_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave_file4.wlf -l test4.log  -sv_seed random  work.top +UVM_TESTNAME=ram_even_addr_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov4
	
view_wave1_Questa:
	vsim -view wave_file1.wlf
	
view_wave2_Questa:
	vsim -view wave_file2.wlf
	
view_wave3_Questa:
	vsim -view wave_file3.wlf
	
view_wave4_Questa:
	vsim -view wave_file4.wlf

report_Questa:
	vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3 mem_cov4
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov

regress_Questa: clean_Questa run_test_Questa run_test1_Questa run_test2_Questa run_test3_Questa report_Questa cov_Questa

cov_Questa:
	firefox covhtmlreport/index.html&
	
clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear

# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#

# ----------------------------- Start of Definitions for Synopsys's VCS Specific Targets -------------------------------#

sv_cmp_VCS:
	vcs -l vcs.log -timescale=1ns/1ps -sverilog -ntb_opts uvm -debug_access+all -full64 -kdb  -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1)
		      
run_test_VCS:	
	./simv -a vcs.log +fsdbfile+wave1.fsdb -cm_dir ./mem_cov1 +ntb_random_seed_automatic +UVM_TESTNAME=small_seq_test 
	urg -dir mem_cov1.vdb -format both -report urgReport1
	
run_test1_VCS:	
	./simv -a vcs.log +fsdbfile+wave2.fsdb -cm_dir ./mem_cov2 +ntb_random_seed_automatic +UVM_TESTNAME=medium_seq_test 
	urg -dir mem_cov2.vdb -format both -report urgReport2
	
run_test2_VCS:	
	./simv -a vcs.log +fsdbfile+wave3.fsdb -cm_dir ./mem_cov3 +ntb_random_seed_automatic +UVM_TESTNAME=large_seq_test 
	urg -dir mem_cov3.vdb -format both -report urgReport3
	
run_test3_VCS:	
	./simv -a vcs.log +fsdbfile+wave4.fsdb -cm_dir ./mem_cov4 +ntb_random_seed_automatic +UVM_TESTNAME=ram_even_addr_test 
	urg -dir mem_cov4.vdb -format both -report urgReport4
	
view_wave1_VCS: 
	verdi -ssf wave1.fsdb
	
view_wave2_VCS: 
	verdi -ssf wave2.fsdb

view_wave3_VCS: 
	verdi -ssf wave3.fsdb

view_wave4_VCS: 
	verdi -ssf wave4.fsdb		
	
report_VCS:
	urg -dir mem_cov1.vdb mem_cov2.vdb mem_cov3.vdb mem_cov4.vdb -dbname merged_dir/merged_test -format both -report urgReport

regress_VCS: clean_VCS sv_cmp_VCS run_test_VCS run_test1_VCS run_test2_VCS run_test3_VCS report_VCS

cov_VCS:
	verdi -cov -covdir merged_dir.vdb

clean_VCS:
	rm -rf simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h urgReport* *.fsdb novas* verdi*
	clear

# ----------------------------- END of Definitions for Synopsys's VCS Specific Targets -------------------------------#

*/


// OUTPUT ::: FOR 3 TEST CASES Small,Medium,Large

// Small PACKETS


UVM_INFO @ 0: reporter [RNTST] Running test small_seq_test...
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
--------------------------------------------------------------------
Name                         Type                        Size  Value
--------------------------------------------------------------------
uvm_test_top                 small_seq_test              -     @474
  envh                       tb_env                      -     @499
    destin_agth              destin_agent_top            -     @516
      agth[0]                destin_agent                -     @660
        drvh                 destin_driver               -     @708
          rsp_port           uvm_analysis_port           -     @725
          seq_item_port      uvm_seq_item_pull_port      -     @716
        monh                 destin_monitor              -     @691
          dmon_port          uvm_analysis_port           -     @699
        seqr                 destin_seqr                 -     @734
          rsp_export         uvm_analysis_export         -     @742
          seq_item_export    uvm_seq_item_pull_imp       -     @848
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
      agth[1]                destin_agent                -     @669
        drvh                 destin_driver               -     @886
          rsp_port           uvm_analysis_port           -     @903
          seq_item_port      uvm_seq_item_pull_port      -     @894
        monh                 destin_monitor              -     @869
          dmon_port          uvm_analysis_port           -     @877
        seqr                 destin_seqr                 -     @912
          rsp_export         uvm_analysis_export         -     @920
          seq_item_export    uvm_seq_item_pull_imp       -     @1026
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
      agth[2]                destin_agent                -     @678
        drvh                 destin_driver               -     @1064
          rsp_port           uvm_analysis_port           -     @1081
          seq_item_port      uvm_seq_item_pull_port      -     @1072
        monh                 destin_monitor              -     @1047
          dmon_port          uvm_analysis_port           -     @1055
        seqr                 destin_seqr                 -     @1090
          rsp_export         uvm_analysis_export         -     @1098
          seq_item_export    uvm_seq_item_pull_imp       -     @1204
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
    sb                       tb_scoreboard               -     @524
      destin_fifo[0]         uvm_tlm_analysis_fifo #(T)  -     @1274
        analysis_export      uvm_analysis_imp            -     @1318
        get_ap               uvm_analysis_port           -     @1309
        get_peek_export      uvm_get_peek_imp            -     @1291
        put_ap               uvm_analysis_port           -     @1300
        put_export           uvm_put_imp                 -     @1282
      destin_fifo[1]         uvm_tlm_analysis_fifo #(T)  -     @1327
        analysis_export      uvm_analysis_imp            -     @1371
        get_ap               uvm_analysis_port           -     @1362
        get_peek_export      uvm_get_peek_imp            -     @1344
        put_ap               uvm_analysis_port           -     @1353
        put_export           uvm_put_imp                 -     @1335
      destin_fifo[2]         uvm_tlm_analysis_fifo #(T)  -     @1380
        analysis_export      uvm_analysis_imp            -     @1424
        get_ap               uvm_analysis_port           -     @1415
        get_peek_export      uvm_get_peek_imp            -     @1397
        put_ap               uvm_analysis_port           -     @1406
        put_export           uvm_put_imp                 -     @1388
      source_fifo            uvm_tlm_analysis_fifo #(T)  -     @1221
        analysis_export      uvm_analysis_imp            -     @1265
        get_ap               uvm_analysis_port           -     @1256
        get_peek_export      uvm_get_peek_imp            -     @1238
        put_ap               uvm_analysis_port           -     @1247
        put_export           uvm_put_imp                 -     @1229
    source_agth              source_agent_top            -     @508
      agth[0]                source_agent                -     @1438
        drvh                 source_driver               -     @1468
          rsp_port           uvm_analysis_port           -     @1485
          seq_item_port      uvm_seq_item_pull_port      -     @1476
        monh                 source_monitor              -     @1451
          smon_port          uvm_analysis_port           -     @1459
        seqr                 source_seqr                 -     @1494
          rsp_export         uvm_analysis_export         -     @1502
          seq_item_export    uvm_seq_item_pull_imp       -     @1608
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
    v_seqr                   virtual_seqr                -     @532
      rsp_export             uvm_analysis_export         -     @540
      seq_item_export        uvm_seq_item_pull_imp       -     @646
      arbitration_queue      array                       0     -
      lock_queue             array                       0     -
      num_last_reqs          integral                    32    'd1
      num_last_rsps          integral                    32    'd1
--------------------------------------------------------------------

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1648
  destin_address  integral    2     'd0
  pay_lenth       integral    6     'd20
  header_byte     integral    8     'd80
  payload[0]      integral    8     157
  payload[1]      integral    8     'd15
  payload[2]      integral    8     'd66
  payload[3]      integral    8     'd39
  payload[4]      integral    8     'd13
  payload[5]      integral    8     207
  payload[6]      integral    8     173
  payload[7]      integral    8     158
  payload[8]      integral    8     'd91
  payload[9]      integral    8     'd0
  payload[10]     integral    8     220
  payload[11]     integral    8     230
  payload[12]     integral    8     'd113
  payload[13]     integral    8     'd40
  payload[14]     integral    8     130
  payload[15]     integral    8     'd93
  payload[16]     integral    8     'd55
  payload[17]     integral    8     'd18
  payload[18]     integral    8     'd78
  payload[19]     integral    8     188
  parity_byte     integral    8     'd102
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1630
  des_address  integral    2     'd0
  pay_lenth    integral    6     'd20
  header_byte  integral    8     'd80
  payload[0]   integral    8     157
  payload[1]   integral    8     'd15
  payload[2]   integral    8     'd66
  payload[3]   integral    8     'd39
  payload[4]   integral    8     'd13
  payload[5]   integral    8     207
  payload[6]   integral    8     173
  payload[7]   integral    8     158
  payload[8]   integral    8     'd91
  payload[9]   integral    8     'd0
  payload[10]  integral    8     220
  payload[11]  integral    8     230
  payload[12]  integral    8     'd113
  payload[13]  integral    8     'd40
  payload[14]  integral    8     130
  payload[15]  integral    8     'd93
  payload[16]  integral    8     'd55
  payload[17]  integral    8     'd18
  payload[18]  integral    8     'd78
  payload[19]  integral    8     188
  parity_byte  integral    8     'd102
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1803
  destin_address  integral    2     'd0
  pay_lenth       integral    6     'd8
  header_byte     integral    8     'd32
  payload[0]      integral    8     205
  payload[1]      integral    8     'd57
  payload[2]      integral    8     251
  payload[3]      integral    8     251
  payload[4]      integral    8     232
  payload[5]      integral    8     147
  payload[6]      integral    8     'd78
  payload[7]      integral    8     188
  parity_byte     integral    8     'd93
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1807
  des_address  integral    2     'd0
  pay_lenth    integral    6     'd8
  header_byte  integral    8     'd32
  payload[0]   integral    8     205
  payload[1]   integral    8     'd57
  payload[2]   integral    8     251
  payload[3]   integral    8     251
  payload[4]   integral    8     232
  payload[5]   integral    8     147
  payload[6]   integral    8     'd78
  payload[7]   integral    8     188
  parity_byte  integral    8     'd93
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1826
  destin_address  integral    2     'd0
  pay_lenth       integral    6     'd2
  header_byte     integral    8     'd8
  payload[0]      integral    8     129
  payload[1]      integral    8     186
  parity_byte     integral    8     'd51
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1830
  des_address  integral    2     'd0
  pay_lenth    integral    6     'd2
  header_byte  integral    8     'd8
  payload[0]   integral    8     129
  payload[1]   integral    8     186
  parity_byte  integral    8     'd51
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1848
  destin_address  integral    2     'd0
  pay_lenth       integral    6     'd18
  header_byte     integral    8     'd72
  payload[0]      integral    8     203
  payload[1]      integral    8     191
  payload[2]      integral    8     'd123
  payload[3]      integral    8     182
  payload[4]      integral    8     174
  payload[5]      integral    8     158
  payload[6]      integral    8     'd92
  payload[7]      integral    8     138
  payload[8]      integral    8     'd116
  payload[9]      integral    8     'd90
  payload[10]     integral    8     'd95
  payload[11]     integral    8     159
  payload[12]     integral    8     190
  payload[13]     integral    8     189
  payload[14]     integral    8     'd66
  payload[15]     integral    8     'd101
  payload[16]     integral    8     'd6
  payload[17]     integral    8     136
  parity_byte     integral    8     'd83
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1852
  des_address  integral    2     'd0
  pay_lenth    integral    6     'd18
  header_byte  integral    8     'd72
  payload[0]   integral    8     203
  payload[1]   integral    8     191
  payload[2]   integral    8     'd123
  payload[3]   integral    8     182
  payload[4]   integral    8     174
  payload[5]   integral    8     158
  payload[6]   integral    8     'd92
  payload[7]   integral    8     138
  payload[8]   integral    8     'd116
  payload[9]   integral    8     'd90
  payload[10]  integral    8     'd95
  payload[11]  integral    8     159
  payload[12]  integral    8     190
  payload[13]  integral    8     189
  payload[14]  integral    8     'd66
  payload[15]  integral    8     'd101
  payload[16]  integral    8     'd6
  payload[17]  integral    8     136
  parity_byte  integral    8     'd83
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1870
  destin_address  integral    2     'd0
  pay_lenth       integral    6     'd11
  header_byte     integral    8     'd44
  payload[0]      integral    8     128
  payload[1]      integral    8     'd61
  payload[2]      integral    8     'd12
  payload[3]      integral    8     'd90
  payload[4]      integral    8     193
  payload[5]      integral    8     'd56
  payload[6]      integral    8     131
  payload[7]      integral    8     255
  payload[8]      integral    8     229
  payload[9]      integral    8     139
  payload[10]     integral    8     'd14
  parity_byte     integral    8     'd34
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1874
  des_address  integral    2     'd0
  pay_lenth    integral    6     'd11
  header_byte  integral    8     'd44
  payload[0]   integral    8     128
  payload[1]   integral    8     'd61
  payload[2]   integral    8     'd12
  payload[3]   integral    8     'd90
  payload[4]   integral    8     193
  payload[5]   integral    8     'd56
  payload[6]   integral    8     131
  payload[7]   integral    8     255
  payload[8]   integral    8     229
  payload[9]   integral    8     139
  payload[10]  integral    8     'd14
  parity_byte  integral    8     'd34
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

UVM_INFO /home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_objection.svh(1274) @ 3650000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase

--- UVM Report Summary ---

** Report counts by severity
UVM_INFO :    3
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
** Report counts by id
[RNTST]     1
[TEST_DONE]     1
[UVMTOP]     1
$finish called from file "/home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_root.svh", line 437.
$finish at simulation time              3650000
           V C S   S i m u l a t i o n   R e p o r t
Time: 3650000 ps


// Medium PACKETS

UVM_INFO @ 0: reporter [RNTST] Running test medium_seq_test...
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
--------------------------------------------------------------------
Name                         Type                        Size  Value
--------------------------------------------------------------------
uvm_test_top                 medium_seq_test             -     @474
  envh                       tb_env                      -     @499
    destin_agth              destin_agent_top            -     @516
      agth[0]                destin_agent                -     @660
        drvh                 destin_driver               -     @708
          rsp_port           uvm_analysis_port           -     @725
          seq_item_port      uvm_seq_item_pull_port      -     @716
        monh                 destin_monitor              -     @691
          dmon_port          uvm_analysis_port           -     @699
        seqr                 destin_seqr                 -     @734
          rsp_export         uvm_analysis_export         -     @742
          seq_item_export    uvm_seq_item_pull_imp       -     @848
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
      agth[1]                destin_agent                -     @669
        drvh                 destin_driver               -     @886
          rsp_port           uvm_analysis_port           -     @903
          seq_item_port      uvm_seq_item_pull_port      -     @894
        monh                 destin_monitor              -     @869
          dmon_port          uvm_analysis_port           -     @877
        seqr                 destin_seqr                 -     @912
          rsp_export         uvm_analysis_export         -     @920
          seq_item_export    uvm_seq_item_pull_imp       -     @1026
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
      agth[2]                destin_agent                -     @678
        drvh                 destin_driver               -     @1064
          rsp_port           uvm_analysis_port           -     @1081
          seq_item_port      uvm_seq_item_pull_port      -     @1072
        monh                 destin_monitor              -     @1047
          dmon_port          uvm_analysis_port           -     @1055
        seqr                 destin_seqr                 -     @1090
          rsp_export         uvm_analysis_export         -     @1098
          seq_item_export    uvm_seq_item_pull_imp       -     @1204
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
    sb                       tb_scoreboard               -     @524
      destin_fifo[0]         uvm_tlm_analysis_fifo #(T)  -     @1274
        analysis_export      uvm_analysis_imp            -     @1318
        get_ap               uvm_analysis_port           -     @1309
        get_peek_export      uvm_get_peek_imp            -     @1291
        put_ap               uvm_analysis_port           -     @1300
        put_export           uvm_put_imp                 -     @1282
      destin_fifo[1]         uvm_tlm_analysis_fifo #(T)  -     @1327
        analysis_export      uvm_analysis_imp            -     @1371
        get_ap               uvm_analysis_port           -     @1362
        get_peek_export      uvm_get_peek_imp            -     @1344
        put_ap               uvm_analysis_port           -     @1353
        put_export           uvm_put_imp                 -     @1335
      destin_fifo[2]         uvm_tlm_analysis_fifo #(T)  -     @1380
        analysis_export      uvm_analysis_imp            -     @1424
        get_ap               uvm_analysis_port           -     @1415
        get_peek_export      uvm_get_peek_imp            -     @1397
        put_ap               uvm_analysis_port           -     @1406
        put_export           uvm_put_imp                 -     @1388
      source_fifo            uvm_tlm_analysis_fifo #(T)  -     @1221
        analysis_export      uvm_analysis_imp            -     @1265
        get_ap               uvm_analysis_port           -     @1256
        get_peek_export      uvm_get_peek_imp            -     @1238
        put_ap               uvm_analysis_port           -     @1247
        put_export           uvm_put_imp                 -     @1229
    source_agth              source_agent_top            -     @508
      agth[0]                source_agent                -     @1438
        drvh                 source_driver               -     @1468
          rsp_port           uvm_analysis_port           -     @1485
          seq_item_port      uvm_seq_item_pull_port      -     @1476
        monh                 source_monitor              -     @1451
          smon_port          uvm_analysis_port           -     @1459
        seqr                 source_seqr                 -     @1494
          rsp_export         uvm_analysis_export         -     @1502
          seq_item_export    uvm_seq_item_pull_imp       -     @1608
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
    v_seqr                   virtual_seqr                -     @532
      rsp_export             uvm_analysis_export         -     @540
      seq_item_export        uvm_seq_item_pull_imp       -     @646
      arbitration_queue      array                       0     -
      lock_queue             array                       0     -
      num_last_reqs          integral                    32    'd1
      num_last_rsps          integral                    32    'd1
--------------------------------------------------------------------

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1648
  destin_address  integral    2     'd1
  pay_lenth       integral    6     'd27
  header_byte     integral    8     'd109
  payload[0]      integral    8     195
  payload[1]      integral    8     218
  payload[2]      integral    8     227
  payload[3]      integral    8     'd122
  payload[4]      integral    8     'd64
  payload[5]      integral    8     191
  payload[6]      integral    8     'd24
  payload[7]      integral    8     138
  payload[8]      integral    8     'd22
  payload[9]      integral    8     235
  payload[10]     integral    8     139
  payload[11]     integral    8     'd42
  payload[12]     integral    8     197
  payload[13]     integral    8     'd44
  payload[14]     integral    8     249
  payload[15]     integral    8     141
  payload[16]     integral    8     198
  payload[17]     integral    8     220
  payload[18]     integral    8     'd93
  payload[19]     integral    8     224
  payload[20]     integral    8     235
  payload[21]     integral    8     'd45
  payload[22]     integral    8     'd42
  payload[23]     integral    8     214
  payload[24]     integral    8     149
  payload[25]     integral    8     196
  payload[26]     integral    8     'd31
  parity_byte     integral    8     146
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1636
  des_address  integral    2     'd1
  pay_lenth    integral    6     'd27
  header_byte  integral    8     'd109
  payload[0]   integral    8     195
  payload[1]   integral    8     218
  payload[2]   integral    8     227
  payload[3]   integral    8     'd122
  payload[4]   integral    8     'd64
  payload[5]   integral    8     191
  payload[6]   integral    8     'd24
  payload[7]   integral    8     138
  payload[8]   integral    8     'd22
  payload[9]   integral    8     235
  payload[10]  integral    8     139
  payload[11]  integral    8     'd42
  payload[12]  integral    8     197
  payload[13]  integral    8     'd44
  payload[14]  integral    8     249
  payload[15]  integral    8     141
  payload[16]  integral    8     198
  payload[17]  integral    8     220
  payload[18]  integral    8     'd93
  payload[19]  integral    8     224
  payload[20]  integral    8     235
  payload[21]  integral    8     'd45
  payload[22]  integral    8     'd42
  payload[23]  integral    8     214
  payload[24]  integral    8     149
  payload[25]  integral    8     196
  payload[26]  integral    8     'd31
  parity_byte  integral    8     146
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1803
  destin_address  integral    2     'd1
  pay_lenth       integral    6     'd29
  header_byte     integral    8     'd117
  payload[0]      integral    8     'd107
  payload[1]      integral    8     'd22
  payload[2]      integral    8     250
  payload[3]      integral    8     133
  payload[4]      integral    8     'd106
  payload[5]      integral    8     'd88
  payload[6]      integral    8     'd61
  payload[7]      integral    8     'd16
  payload[8]      integral    8     194
  payload[9]      integral    8     'd56
  payload[10]     integral    8     237
  payload[11]     integral    8     'd37
  payload[12]     integral    8     156
  payload[13]     integral    8     'd34
  payload[14]     integral    8     194
  payload[15]     integral    8     210
  payload[16]     integral    8     'd115
  payload[17]     integral    8     152
  payload[18]     integral    8     242
  payload[19]     integral    8     'd105
  payload[20]     integral    8     237
  payload[21]     integral    8     246
  payload[22]     integral    8     175
  payload[23]     integral    8     'd14
  payload[24]     integral    8     249
  payload[25]     integral    8     'd44
  payload[26]     integral    8     'd104
  payload[27]     integral    8     186
  payload[28]     integral    8     162
  parity_byte     integral    8     155
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1807
  des_address  integral    2     'd1
  pay_lenth    integral    6     'd29
  header_byte  integral    8     'd117
  payload[0]   integral    8     'd107
  payload[1]   integral    8     'd22
  payload[2]   integral    8     250
  payload[3]   integral    8     133
  payload[4]   integral    8     'd106
  payload[5]   integral    8     'd88
  payload[6]   integral    8     'd61
  payload[7]   integral    8     'd16
  payload[8]   integral    8     194
  payload[9]   integral    8     'd56
  payload[10]  integral    8     237
  payload[11]  integral    8     'd37
  payload[12]  integral    8     156
  payload[13]  integral    8     'd34
  payload[14]  integral    8     194
  payload[15]  integral    8     210
  payload[16]  integral    8     'd115
  payload[17]  integral    8     152
  payload[18]  integral    8     242
  payload[19]  integral    8     'd105
  payload[20]  integral    8     237
  payload[21]  integral    8     246
  payload[22]  integral    8     175
  payload[23]  integral    8     'd14
  payload[24]  integral    8     249
  payload[25]  integral    8     'd44
  payload[26]  integral    8     'd104
  payload[27]  integral    8     186
  payload[28]  integral    8     162
  parity_byte  integral    8     155
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1826
  destin_address  integral    2     'd1
  pay_lenth       integral    6     'd25
  header_byte     integral    8     'd101
  payload[0]      integral    8     'd76
  payload[1]      integral    8     238
  payload[2]      integral    8     216
  payload[3]      integral    8     'd123
  payload[4]      integral    8     'd86
  payload[5]      integral    8     'd7
  payload[6]      integral    8     243
  payload[7]      integral    8     220
  payload[8]      integral    8     130
  payload[9]      integral    8     156
  payload[10]     integral    8     142
  payload[11]     integral    8     132
  payload[12]     integral    8     150
  payload[13]     integral    8     'd13
  payload[14]     integral    8     142
  payload[15]     integral    8     195
  payload[16]     integral    8     'd5
  payload[17]     integral    8     239
  payload[18]     integral    8     'd119
  payload[19]     integral    8     159
  payload[20]     integral    8     'd69
  payload[21]     integral    8     162
  payload[22]     integral    8     235
  payload[23]     integral    8     'd74
  payload[24]     integral    8     202
  parity_byte     integral    8     'd86
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1830
  des_address  integral    2     'd1
  pay_lenth    integral    6     'd25
  header_byte  integral    8     'd101
  payload[0]   integral    8     'd76
  payload[1]   integral    8     238
  payload[2]   integral    8     216
  payload[3]   integral    8     'd123
  payload[4]   integral    8     'd86
  payload[5]   integral    8     'd7
  payload[6]   integral    8     243
  payload[7]   integral    8     220
  payload[8]   integral    8     130
  payload[9]   integral    8     156
  payload[10]  integral    8     142
  payload[11]  integral    8     132
  payload[12]  integral    8     150
  payload[13]  integral    8     'd13
  payload[14]  integral    8     142
  payload[15]  integral    8     195
  payload[16]  integral    8     'd5
  payload[17]  integral    8     239
  payload[18]  integral    8     'd119
  payload[19]  integral    8     159
  payload[20]  integral    8     'd69
  payload[21]  integral    8     162
  payload[22]  integral    8     235
  payload[23]  integral    8     'd74
  payload[24]  integral    8     202
  parity_byte  integral    8     'd86
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1848
  destin_address  integral    2     'd1
  pay_lenth       integral    6     'd25
  header_byte     integral    8     'd101
  payload[0]      integral    8     205
  payload[1]      integral    8     215
  payload[2]      integral    8     185
  payload[3]      integral    8     'd37
  payload[4]      integral    8     229
  payload[5]      integral    8     'd89
  payload[6]      integral    8     148
  payload[7]      integral    8     'd118
  payload[8]      integral    8     151
  payload[9]      integral    8     182
  payload[10]     integral    8     'd76
  payload[11]     integral    8     'd54
  payload[12]     integral    8     'd48
  payload[13]     integral    8     177
  payload[14]     integral    8     'd26
  payload[15]     integral    8     211
  payload[16]     integral    8     'd39
  payload[17]     integral    8     'd43
  payload[18]     integral    8     'd26
  payload[19]     integral    8     'd5
  payload[20]     integral    8     'd17
  payload[21]     integral    8     181
  payload[22]     integral    8     'd99
  payload[23]     integral    8     196
  payload[24]     integral    8     244
  parity_byte     integral    8     'd74
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1852
  des_address  integral    2     'd1
  pay_lenth    integral    6     'd25
  header_byte  integral    8     'd101
  payload[0]   integral    8     205
  payload[1]   integral    8     215
  payload[2]   integral    8     185
  payload[3]   integral    8     'd37
  payload[4]   integral    8     229
  payload[5]   integral    8     'd89
  payload[6]   integral    8     148
  payload[7]   integral    8     'd118
  payload[8]   integral    8     151
  payload[9]   integral    8     182
  payload[10]  integral    8     'd76
  payload[11]  integral    8     'd54
  payload[12]  integral    8     'd48
  payload[13]  integral    8     177
  payload[14]  integral    8     'd26
  payload[15]  integral    8     211
  payload[16]  integral    8     'd39
  payload[17]  integral    8     'd43
  payload[18]  integral    8     'd26
  payload[19]  integral    8     'd5
  payload[20]  integral    8     'd17
  payload[21]  integral    8     181
  payload[22]  integral    8     'd99
  payload[23]  integral    8     196
  payload[24]  integral    8     244
  parity_byte  integral    8     'd74
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1870
  destin_address  integral    2     'd1
  pay_lenth       integral    6     'd22
  header_byte     integral    8     'd89
  payload[0]      integral    8     254
  payload[1]      integral    8     184
  payload[2]      integral    8     226
  payload[3]      integral    8     'd56
  payload[4]      integral    8     254
  payload[5]      integral    8     'd69
  payload[6]      integral    8     'd109
  payload[7]      integral    8     232
  payload[8]      integral    8     232
  payload[9]      integral    8     'd57
  payload[10]     integral    8     139
  payload[11]     integral    8     185
  payload[12]     integral    8     230
  payload[13]     integral    8     175
  payload[14]     integral    8     'd85
  payload[15]     integral    8     'd123
  payload[16]     integral    8     240
  payload[17]     integral    8     166
  payload[18]     integral    8     'd104
  payload[19]     integral    8     167
  payload[20]     integral    8     240
  payload[21]     integral    8     'd27
  parity_byte     integral    8     'd13
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1874
  des_address  integral    2     'd1
  pay_lenth    integral    6     'd22
  header_byte  integral    8     'd89
  payload[0]   integral    8     254
  payload[1]   integral    8     184
  payload[2]   integral    8     226
  payload[3]   integral    8     'd56
  payload[4]   integral    8     254
  payload[5]   integral    8     'd69
  payload[6]   integral    8     'd109
  payload[7]   integral    8     232
  payload[8]   integral    8     232
  payload[9]   integral    8     'd57
  payload[10]  integral    8     139
  payload[11]  integral    8     185
  payload[12]  integral    8     230
  payload[13]  integral    8     175
  payload[14]  integral    8     'd85
  payload[15]  integral    8     'd123
  payload[16]  integral    8     240
  payload[17]  integral    8     166
  payload[18]  integral    8     'd104
  payload[19]  integral    8     167
  payload[20]  integral    8     240
  payload[21]  integral    8     'd27
  parity_byte  integral    8     'd13
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

UVM_INFO /home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_objection.svh(1274) @ 4850000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase

--- UVM Report Summary ---

** Report counts by severity
UVM_INFO :    3
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
** Report counts by id
[RNTST]     1
[TEST_DONE]     1
[UVMTOP]     1
$finish called from file "/home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_root.svh", line 437.
$finish at simulation time              4850000
           V C S   S i m u l a t i o n   R e p o r t
Time: 4850000 ps



// Large PACKETS


UVM_INFO @ 0: reporter [RNTST] Running test large_seq_test...
UVM_INFO @ 0: reporter [UVMTOP] UVM testbench topology:
--------------------------------------------------------------------
Name                         Type                        Size  Value
--------------------------------------------------------------------
uvm_test_top                 large_seq_test              -     @474
  envh                       tb_env                      -     @499
    destin_agth              destin_agent_top            -     @516
      agth[0]                destin_agent                -     @660
        drvh                 destin_driver               -     @708
          rsp_port           uvm_analysis_port           -     @725
          seq_item_port      uvm_seq_item_pull_port      -     @716
        monh                 destin_monitor              -     @691
          dmon_port          uvm_analysis_port           -     @699
        seqr                 destin_seqr                 -     @734
          rsp_export         uvm_analysis_export         -     @742
          seq_item_export    uvm_seq_item_pull_imp       -     @848
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
      agth[1]                destin_agent                -     @669
        drvh                 destin_driver               -     @886
          rsp_port           uvm_analysis_port           -     @903
          seq_item_port      uvm_seq_item_pull_port      -     @894
        monh                 destin_monitor              -     @869
          dmon_port          uvm_analysis_port           -     @877
        seqr                 destin_seqr                 -     @912
          rsp_export         uvm_analysis_export         -     @920
          seq_item_export    uvm_seq_item_pull_imp       -     @1026
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
      agth[2]                destin_agent                -     @678
        drvh                 destin_driver               -     @1064
          rsp_port           uvm_analysis_port           -     @1081
          seq_item_port      uvm_seq_item_pull_port      -     @1072
        monh                 destin_monitor              -     @1047
          dmon_port          uvm_analysis_port           -     @1055
        seqr                 destin_seqr                 -     @1090
          rsp_export         uvm_analysis_export         -     @1098
          seq_item_export    uvm_seq_item_pull_imp       -     @1204
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
    sb                       tb_scoreboard               -     @524
      destin_fifo[0]         uvm_tlm_analysis_fifo #(T)  -     @1274
        analysis_export      uvm_analysis_imp            -     @1318
        get_ap               uvm_analysis_port           -     @1309
        get_peek_export      uvm_get_peek_imp            -     @1291
        put_ap               uvm_analysis_port           -     @1300
        put_export           uvm_put_imp                 -     @1282
      destin_fifo[1]         uvm_tlm_analysis_fifo #(T)  -     @1327
        analysis_export      uvm_analysis_imp            -     @1371
        get_ap               uvm_analysis_port           -     @1362
        get_peek_export      uvm_get_peek_imp            -     @1344
        put_ap               uvm_analysis_port           -     @1353
        put_export           uvm_put_imp                 -     @1335
      destin_fifo[2]         uvm_tlm_analysis_fifo #(T)  -     @1380
        analysis_export      uvm_analysis_imp            -     @1424
        get_ap               uvm_analysis_port           -     @1415
        get_peek_export      uvm_get_peek_imp            -     @1397
        put_ap               uvm_analysis_port           -     @1406
        put_export           uvm_put_imp                 -     @1388
      source_fifo            uvm_tlm_analysis_fifo #(T)  -     @1221
        analysis_export      uvm_analysis_imp            -     @1265
        get_ap               uvm_analysis_port           -     @1256
        get_peek_export      uvm_get_peek_imp            -     @1238
        put_ap               uvm_analysis_port           -     @1247
        put_export           uvm_put_imp                 -     @1229
    source_agth              source_agent_top            -     @508
      agth[0]                source_agent                -     @1438
        drvh                 source_driver               -     @1468
          rsp_port           uvm_analysis_port           -     @1485
          seq_item_port      uvm_seq_item_pull_port      -     @1476
        monh                 source_monitor              -     @1451
          smon_port          uvm_analysis_port           -     @1459
        seqr                 source_seqr                 -     @1494
          rsp_export         uvm_analysis_export         -     @1502
          seq_item_export    uvm_seq_item_pull_imp       -     @1608
          arbitration_queue  array                       0     -
          lock_queue         array                       0     -
          num_last_reqs      integral                    32    'd1
          num_last_rsps      integral                    32    'd1
    v_seqr                   virtual_seqr                -     @532
      rsp_export             uvm_analysis_export         -     @540
      seq_item_export        uvm_seq_item_pull_imp       -     @646
      arbitration_queue      array                       0     -
      lock_queue             array                       0     -
      num_last_reqs          integral                    32    'd1
      num_last_rsps          integral                    32    'd1
--------------------------------------------------------------------

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1648
  destin_address  integral    2     2
  pay_lenth       integral    6     57
  header_byte     integral    8     230
  payload[0]      integral    8     'd16
  payload[1]      integral    8     161
  payload[2]      integral    8     'd50
  payload[3]      integral    8     245
  payload[4]      integral    8     'd74
  payload[5]      integral    8     'd71
  payload[6]      integral    8     202
  payload[7]      integral    8     'd23
  payload[8]      integral    8     'd73
  payload[9]      integral    8     241
  payload[10]     integral    8     'd80
  payload[11]     integral    8     'd8
  payload[12]     integral    8     'd79
  payload[13]     integral    8     199
  payload[14]     integral    8     'd54
  payload[15]     integral    8     'd103
  payload[16]     integral    8     192
  payload[17]     integral    8     138
  payload[18]     integral    8     'd125
  payload[19]     integral    8     'd104
  payload[20]     integral    8     157
  payload[21]     integral    8     'd86
  payload[22]     integral    8     'd112
  payload[23]     integral    8     'd11
  payload[24]     integral    8     'd118
  payload[25]     integral    8     133
  payload[26]     integral    8     'd24
  payload[27]     integral    8     171
  payload[28]     integral    8     133
  payload[29]     integral    8     'd120
  payload[30]     integral    8     'd9
  payload[31]     integral    8     'd0
  payload[32]     integral    8     'd83
  payload[33]     integral    8     210
  payload[34]     integral    8     224
  payload[35]     integral    8     204
  payload[36]     integral    8     'd14
  payload[37]     integral    8     'd106
  payload[38]     integral    8     'd122
  payload[39]     integral    8     'd5
  payload[40]     integral    8     'd119
  payload[41]     integral    8     'd116
  payload[42]     integral    8     'd23
  payload[43]     integral    8     'd43
  payload[44]     integral    8     'd91
  payload[45]     integral    8     'd60
  payload[46]     integral    8     'd91
  payload[47]     integral    8     252
  payload[48]     integral    8     'd42
  payload[49]     integral    8     'd94
  payload[50]     integral    8     154
  payload[51]     integral    8     'd71
  payload[52]     integral    8     'd67
  payload[53]     integral    8     251
  payload[54]     integral    8     'd75
  payload[55]     integral    8     214
  payload[56]     integral    8     'd117
  parity_byte     integral    8     146
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1642
  des_address  integral    2     2
  pay_lenth    integral    6     57
  header_byte  integral    8     230
  payload[0]   integral    8     'd16
  payload[1]   integral    8     161
  payload[2]   integral    8     'd50
  payload[3]   integral    8     245
  payload[4]   integral    8     'd74
  payload[5]   integral    8     'd71
  payload[6]   integral    8     202
  payload[7]   integral    8     'd23
  payload[8]   integral    8     'd73
  payload[9]   integral    8     241
  payload[10]  integral    8     'd80
  payload[11]  integral    8     'd8
  payload[12]  integral    8     'd79
  payload[13]  integral    8     199
  payload[14]  integral    8     'd54
  payload[15]  integral    8     'd103
  payload[16]  integral    8     192
  payload[17]  integral    8     138
  payload[18]  integral    8     'd125
  payload[19]  integral    8     'd104
  payload[20]  integral    8     157
  payload[21]  integral    8     'd86
  payload[22]  integral    8     'd112
  payload[23]  integral    8     'd11
  payload[24]  integral    8     'd118
  payload[25]  integral    8     133
  payload[26]  integral    8     'd24
  payload[27]  integral    8     171
  payload[28]  integral    8     133
  payload[29]  integral    8     'd120
  payload[30]  integral    8     'd9
  payload[31]  integral    8     'd0
  payload[32]  integral    8     'd83
  payload[33]  integral    8     210
  payload[34]  integral    8     224
  payload[35]  integral    8     204
  payload[36]  integral    8     'd14
  payload[37]  integral    8     'd106
  payload[38]  integral    8     'd122
  payload[39]  integral    8     'd5
  payload[40]  integral    8     'd119
  payload[41]  integral    8     'd116
  payload[42]  integral    8     'd23
  payload[43]  integral    8     'd43
  payload[44]  integral    8     'd91
  payload[45]  integral    8     'd60
  payload[46]  integral    8     'd91
  payload[47]  integral    8     252
  payload[48]  integral    8     'd42
  payload[49]  integral    8     'd94
  payload[50]  integral    8     154
  payload[51]  integral    8     'd71
  payload[52]  integral    8     'd67
  payload[53]  integral    8     251
  payload[54]  integral    8     'd75
  payload[55]  integral    8     214
  payload[56]  integral    8     'd117
  parity_byte  integral    8     146
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1803
  destin_address  integral    2     2
  pay_lenth       integral    6     56
  header_byte     integral    8     226
  payload[0]      integral    8     167
  payload[1]      integral    8     212
  payload[2]      integral    8     211
  payload[3]      integral    8     'd71
  payload[4]      integral    8     227
  payload[5]      integral    8     'd91
  payload[6]      integral    8     188
  payload[7]      integral    8     207
  payload[8]      integral    8     'd47
  payload[9]      integral    8     'd0
  payload[10]     integral    8     'd117
  payload[11]     integral    8     148
  payload[12]     integral    8     206
  payload[13]     integral    8     190
  payload[14]     integral    8     'd39
  payload[15]     integral    8     173
  payload[16]     integral    8     206
  payload[17]     integral    8     205
  payload[18]     integral    8     'd76
  payload[19]     integral    8     'd58
  payload[20]     integral    8     143
  payload[21]     integral    8     'd20
  payload[22]     integral    8     128
  payload[23]     integral    8     195
  payload[24]     integral    8     'd50
  payload[25]     integral    8     'd79
  payload[26]     integral    8     'd29
  payload[27]     integral    8     'd31
  payload[28]     integral    8     236
  payload[29]     integral    8     137
  payload[30]     integral    8     245
  payload[31]     integral    8     185
  payload[32]     integral    8     152
  payload[33]     integral    8     'd110
  payload[34]     integral    8     239
  payload[35]     integral    8     205
  payload[36]     integral    8     234
  payload[37]     integral    8     'd69
  payload[38]     integral    8     171
  payload[39]     integral    8     172
  payload[40]     integral    8     212
  payload[41]     integral    8     134
  payload[42]     integral    8     194
  payload[43]     integral    8     'd121
  payload[44]     integral    8     231
  payload[45]     integral    8     231
  payload[46]     integral    8     'd21
  payload[47]     integral    8     'd50
  payload[48]     integral    8     'd41
  payload[49]     integral    8     'd89
  payload[50]     integral    8     'd24
  payload[51]     integral    8     'd6
  payload[52]     integral    8     'd103
  payload[53]     integral    8     143
  payload[54]     integral    8     208
  payload[55]     integral    8     'd91
  parity_byte     integral    8     190
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1807
  des_address  integral    2     2
  pay_lenth    integral    6     56
  header_byte  integral    8     226
  payload[0]   integral    8     167
  payload[1]   integral    8     212
  payload[2]   integral    8     211
  payload[3]   integral    8     'd71
  payload[4]   integral    8     227
  payload[5]   integral    8     'd91
  payload[6]   integral    8     188
  payload[7]   integral    8     207
  payload[8]   integral    8     'd47
  payload[9]   integral    8     'd0
  payload[10]  integral    8     'd117
  payload[11]  integral    8     148
  payload[12]  integral    8     206
  payload[13]  integral    8     190
  payload[14]  integral    8     'd39
  payload[15]  integral    8     173
  payload[16]  integral    8     206
  payload[17]  integral    8     205
  payload[18]  integral    8     'd76
  payload[19]  integral    8     'd58
  payload[20]  integral    8     143
  payload[21]  integral    8     'd20
  payload[22]  integral    8     128
  payload[23]  integral    8     195
  payload[24]  integral    8     'd50
  payload[25]  integral    8     'd79
  payload[26]  integral    8     'd29
  payload[27]  integral    8     'd31
  payload[28]  integral    8     236
  payload[29]  integral    8     137
  payload[30]  integral    8     245
  payload[31]  integral    8     185
  payload[32]  integral    8     152
  payload[33]  integral    8     'd110
  payload[34]  integral    8     239
  payload[35]  integral    8     205
  payload[36]  integral    8     234
  payload[37]  integral    8     'd69
  payload[38]  integral    8     171
  payload[39]  integral    8     172
  payload[40]  integral    8     212
  payload[41]  integral    8     134
  payload[42]  integral    8     194
  payload[43]  integral    8     'd121
  payload[44]  integral    8     231
  payload[45]  integral    8     231
  payload[46]  integral    8     'd21
  payload[47]  integral    8     'd50
  payload[48]  integral    8     'd41
  payload[49]  integral    8     'd89
  payload[50]  integral    8     'd24
  payload[51]  integral    8     'd6
  payload[52]  integral    8     'd103
  payload[53]  integral    8     143
  payload[54]  integral    8     208
  payload[55]  integral    8     'd91
  parity_byte  integral    8     190
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1826
  destin_address  integral    2     2
  pay_lenth       integral    6     44
  header_byte     integral    8     178
  payload[0]      integral    8     'd39
  payload[1]      integral    8     'd125
  payload[2]      integral    8     216
  payload[3]      integral    8     215
  payload[4]      integral    8     'd0
  payload[5]      integral    8     'd125
  payload[6]      integral    8     'd42
  payload[7]      integral    8     173
  payload[8]      integral    8     'd0
  payload[9]      integral    8     'd1
  payload[10]     integral    8     'd63
  payload[11]     integral    8     'd89
  payload[12]     integral    8     149
  payload[13]     integral    8     200
  payload[14]     integral    8     203
  payload[15]     integral    8     'd43
  payload[16]     integral    8     212
  payload[17]     integral    8     'd113
  payload[18]     integral    8     215
  payload[19]     integral    8     134
  payload[20]     integral    8     'd106
  payload[21]     integral    8     215
  payload[22]     integral    8     241
  payload[23]     integral    8     'd2
  payload[24]     integral    8     'd113
  payload[25]     integral    8     135
  payload[26]     integral    8     'd115
  payload[27]     integral    8     225
  payload[28]     integral    8     'd27
  payload[29]     integral    8     190
  payload[30]     integral    8     255
  payload[31]     integral    8     171
  payload[32]     integral    8     181
  payload[33]     integral    8     247
  payload[34]     integral    8     208
  payload[35]     integral    8     'd120
  payload[36]     integral    8     'd56
  payload[37]     integral    8     147
  payload[38]     integral    8     191
  payload[39]     integral    8     225
  payload[40]     integral    8     'd14
  payload[41]     integral    8     'd43
  payload[42]     integral    8     158
  payload[43]     integral    8     221
  parity_byte     integral    8     145
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1830
  des_address  integral    2     2
  pay_lenth    integral    6     44
  header_byte  integral    8     178
  payload[0]   integral    8     'd39
  payload[1]   integral    8     'd125
  payload[2]   integral    8     216
  payload[3]   integral    8     215
  payload[4]   integral    8     'd0
  payload[5]   integral    8     'd125
  payload[6]   integral    8     'd42
  payload[7]   integral    8     173
  payload[8]   integral    8     'd0
  payload[9]   integral    8     'd1
  payload[10]  integral    8     'd63
  payload[11]  integral    8     'd89
  payload[12]  integral    8     149
  payload[13]  integral    8     200
  payload[14]  integral    8     203
  payload[15]  integral    8     'd43
  payload[16]  integral    8     212
  payload[17]  integral    8     'd113
  payload[18]  integral    8     215
  payload[19]  integral    8     134
  payload[20]  integral    8     'd106
  payload[21]  integral    8     215
  payload[22]  integral    8     241
  payload[23]  integral    8     'd2
  payload[24]  integral    8     'd113
  payload[25]  integral    8     135
  payload[26]  integral    8     'd115
  payload[27]  integral    8     225
  payload[28]  integral    8     'd27
  payload[29]  integral    8     190
  payload[30]  integral    8     255
  payload[31]  integral    8     171
  payload[32]  integral    8     181
  payload[33]  integral    8     247
  payload[34]  integral    8     208
  payload[35]  integral    8     'd120
  payload[36]  integral    8     'd56
  payload[37]  integral    8     147
  payload[38]  integral    8     191
  payload[39]  integral    8     225
  payload[40]  integral    8     'd14
  payload[41]  integral    8     'd43
  payload[42]  integral    8     158
  payload[43]  integral    8     221
  parity_byte  integral    8     145
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1848
  destin_address  integral    2     2
  pay_lenth       integral    6     61
  header_byte     integral    8     246
  payload[0]      integral    8     'd81
  payload[1]      integral    8     'd100
  payload[2]      integral    8     'd82
  payload[3]      integral    8     169
  payload[4]      integral    8     203
  payload[5]      integral    8     'd49
  payload[6]      integral    8     201
  payload[7]      integral    8     244
  payload[8]      integral    8     'd13
  payload[9]      integral    8     'd5
  payload[10]     integral    8     'd112
  payload[11]     integral    8     'd105
  payload[12]     integral    8     'd32
  payload[13]     integral    8     216
  payload[14]     integral    8     158
  payload[15]     integral    8     'd68
  payload[16]     integral    8     156
  payload[17]     integral    8     179
  payload[18]     integral    8     'd69
  payload[19]     integral    8     'd64
  payload[20]     integral    8     'd109
  payload[21]     integral    8     130
  payload[22]     integral    8     'd13
  payload[23]     integral    8     'd14
  payload[24]     integral    8     172
  payload[25]     integral    8     153
  payload[26]     integral    8     'd65
  payload[27]     integral    8     207
  payload[28]     integral    8     'd57
  payload[29]     integral    8     'd71
  payload[30]     integral    8     251
  payload[31]     integral    8     'd59
  payload[32]     integral    8     'd21
  payload[33]     integral    8     'd88
  payload[34]     integral    8     255
  payload[35]     integral    8     'd55
  payload[36]     integral    8     'd53
  payload[37]     integral    8     135
  payload[38]     integral    8     203
  payload[39]     integral    8     189
  payload[40]     integral    8     170
  payload[41]     integral    8     226
  payload[42]     integral    8     243
  payload[43]     integral    8     'd111
  payload[44]     integral    8     180
  payload[45]     integral    8     168
  payload[46]     integral    8     'd2
  payload[47]     integral    8     141
  payload[48]     integral    8     'd92
  payload[49]     integral    8     'd90
  payload[50]     integral    8     'd57
  payload[51]     integral    8     'd4
  payload[52]     integral    8     'd18
  payload[53]     integral    8     'd76
  payload[54]     integral    8     176
  payload[55]     integral    8     'd108
  payload[56]     integral    8     215
  payload[57]     integral    8     'd86
  payload[58]     integral    8     235
  payload[59]     integral    8     'd98
  payload[60]     integral    8     175
  parity_byte     integral    8     'd23
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1852
  des_address  integral    2     2
  pay_lenth    integral    6     61
  header_byte  integral    8     246
  payload[0]   integral    8     'd81
  payload[1]   integral    8     'd100
  payload[2]   integral    8     'd82
  payload[3]   integral    8     169
  payload[4]   integral    8     203
  payload[5]   integral    8     'd49
  payload[6]   integral    8     201
  payload[7]   integral    8     244
  payload[8]   integral    8     'd13
  payload[9]   integral    8     'd5
  payload[10]  integral    8     'd112
  payload[11]  integral    8     'd105
  payload[12]  integral    8     'd32
  payload[13]  integral    8     216
  payload[14]  integral    8     158
  payload[15]  integral    8     'd68
  payload[16]  integral    8     156
  payload[17]  integral    8     179
  payload[18]  integral    8     'd69
  payload[19]  integral    8     'd64
  payload[20]  integral    8     'd109
  payload[21]  integral    8     130
  payload[22]  integral    8     'd13
  payload[23]  integral    8     'd14
  payload[24]  integral    8     172
  payload[25]  integral    8     153
  payload[26]  integral    8     'd65
  payload[27]  integral    8     207
  payload[28]  integral    8     'd57
  payload[29]  integral    8     'd71
  payload[30]  integral    8     251
  payload[31]  integral    8     'd59
  payload[32]  integral    8     'd21
  payload[33]  integral    8     'd88
  payload[34]  integral    8     255
  payload[35]  integral    8     'd55
  payload[36]  integral    8     'd53
  payload[37]  integral    8     135
  payload[38]  integral    8     203
  payload[39]  integral    8     189
  payload[40]  integral    8     170
  payload[41]  integral    8     226
  payload[42]  integral    8     243
  payload[43]  integral    8     'd111
  payload[44]  integral    8     180
  payload[45]  integral    8     168
  payload[46]  integral    8     'd2
  payload[47]  integral    8     141
  payload[48]  integral    8     'd92
  payload[49]  integral    8     'd90
  payload[50]  integral    8     'd57
  payload[51]  integral    8     'd4
  payload[52]  integral    8     'd18
  payload[53]  integral    8     'd76
  payload[54]  integral    8     176
  payload[55]  integral    8     'd108
  payload[56]  integral    8     215
  payload[57]  integral    8     'd86
  payload[58]  integral    8     235
  payload[59]  integral    8     'd98
  payload[60]  integral    8     175
  parity_byte  integral    8     'd23
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

Signal Error From Source Monitor = 1
-----------------------------------------
Name              Type        Size  Value
-----------------------------------------
source_mon        source_xtn  -     @1870
  destin_address  integral    2     2
  pay_lenth       integral    6     53
  header_byte     integral    8     214
  payload[0]      integral    8     'd87
  payload[1]      integral    8     247
  payload[2]      integral    8     228
  payload[3]      integral    8     210
  payload[4]      integral    8     248
  payload[5]      integral    8     168
  payload[6]      integral    8     'd18
  payload[7]      integral    8     'd71
  payload[8]      integral    8     'd83
  payload[9]      integral    8     'd104
  payload[10]     integral    8     184
  payload[11]     integral    8     243
  payload[12]     integral    8     'd25
  payload[13]     integral    8     247
  payload[14]     integral    8     'd24
  payload[15]     integral    8     'd19
  payload[16]     integral    8     'd57
  payload[17]     integral    8     'd52
  payload[18]     integral    8     136
  payload[19]     integral    8     182
  payload[20]     integral    8     'd42
  payload[21]     integral    8     191
  payload[22]     integral    8     150
  payload[23]     integral    8     'd94
  payload[24]     integral    8     186
  payload[25]     integral    8     'd126
  payload[26]     integral    8     'd78
  payload[27]     integral    8     'd126
  payload[28]     integral    8     252
  payload[29]     integral    8     'd28
  payload[30]     integral    8     'd8
  payload[31]     integral    8     'd113
  payload[32]     integral    8     242
  payload[33]     integral    8     'd74
  payload[34]     integral    8     251
  payload[35]     integral    8     'd39
  payload[36]     integral    8     'd92
  payload[37]     integral    8     201
  payload[38]     integral    8     151
  payload[39]     integral    8     195
  payload[40]     integral    8     192
  payload[41]     integral    8     132
  payload[42]     integral    8     198
  payload[43]     integral    8     'd52
  payload[44]     integral    8     252
  payload[45]     integral    8     'd116
  payload[46]     integral    8     233
  payload[47]     integral    8     'd46
  payload[48]     integral    8     'd109
  payload[49]     integral    8     'd57
  payload[50]     integral    8     'd46
  payload[51]     integral    8     'd86
  payload[52]     integral    8     189
  parity_byte     integral    8     'd30
-----------------------------------------
--------------------------------------
Name           Type        Size  Value
--------------------------------------
destin_mon     destin_xtn  -     @1874
  des_address  integral    2     2
  pay_lenth    integral    6     53
  header_byte  integral    8     214
  payload[0]   integral    8     'd87
  payload[1]   integral    8     247
  payload[2]   integral    8     228
  payload[3]   integral    8     210
  payload[4]   integral    8     248
  payload[5]   integral    8     168
  payload[6]   integral    8     'd18
  payload[7]   integral    8     'd71
  payload[8]   integral    8     'd83
  payload[9]   integral    8     'd104
  payload[10]  integral    8     184
  payload[11]  integral    8     243
  payload[12]  integral    8     'd25
  payload[13]  integral    8     247
  payload[14]  integral    8     'd24
  payload[15]  integral    8     'd19
  payload[16]  integral    8     'd57
  payload[17]  integral    8     'd52
  payload[18]  integral    8     136
  payload[19]  integral    8     182
  payload[20]  integral    8     'd42
  payload[21]  integral    8     191
  payload[22]  integral    8     150
  payload[23]  integral    8     'd94
  payload[24]  integral    8     186
  payload[25]  integral    8     'd126
  payload[26]  integral    8     'd78
  payload[27]  integral    8     'd126
  payload[28]  integral    8     252
  payload[29]  integral    8     'd28
  payload[30]  integral    8     'd8
  payload[31]  integral    8     'd113
  payload[32]  integral    8     242
  payload[33]  integral    8     'd74
  payload[34]  integral    8     251
  payload[35]  integral    8     'd39
  payload[36]  integral    8     'd92
  payload[37]  integral    8     201
  payload[38]  integral    8     151
  payload[39]  integral    8     195
  payload[40]  integral    8     192
  payload[41]  integral    8     132
  payload[42]  integral    8     198
  payload[43]  integral    8     'd52
  payload[44]  integral    8     252
  payload[45]  integral    8     'd116
  payload[46]  integral    8     233
  payload[47]  integral    8     'd46
  payload[48]  integral    8     'd109
  payload[49]  integral    8     'd57
  payload[50]  integral    8     'd46
  payload[51]  integral    8     'd86
  payload[52]  integral    8     189
  parity_byte  integral    8     'd30
  delay        integral    6     'd0
--------------------------------------

===================== Header_Byte Matched SuccessFull =====================


===================== Payload Matched SuccessFull =====================


===================== Parity_Byte Matched SuccessFull =====================


=========================================================================


     SUCCESSFULLY MATCHED


=========================================================================


=========================================================================


 source  side functional coverage = 38.889


 destin  side functional coverage = 41.667


=========================================================================

UVM_INFO /home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_objection.svh(1274) @ 8110000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase

--- UVM Report Summary ---

** Report counts by severity
UVM_INFO :    3
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
** Report counts by id
[RNTST]     1
[TEST_DONE]     1
[UVMTOP]     1
$finish called from file "/home/cad/eda/SYNOPSYS/VCS/vcs/T-2022.06-SP1/etc/uvm/base/uvm_root.svh", line 437.
$finish at simulation time              8110000
           V C S   S i m u l a t i o n   R e p o r t
Time: 8110000 ps

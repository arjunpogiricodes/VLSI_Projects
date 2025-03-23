
//msrv32_immediate_addr

module msrv32_immediate_adder(input [31:0]pc_in,imm_in,rs_1_in,input iadder_src_in,output reg[31:0] iadder_out);

		reg [31:0] temp;
		always@(*)
		   begin
		       begin 
			        if(iadder_src_in)
							temp = rs_1_in;
					else
							temp = pc_in;
				end
       
                iadder_out = imm_in + temp;
            end  				
					
endmodule


// msrv32_immediate_adder(

module msrv32_immediate_adder_tb();

		reg [31:0]pc_in,imm_in,rs_1_in;
		reg iadder_src_in;
		wire[31:0] iadder_out;

// instantitation
		msrv32_immediate_adder DUT(pc_in,imm_in,rs_1_in,iadder_src_in,iadder_out);
		
		task initialize;
			begin
				iadder_src_in = 0;
				pc_in = 0;
                imm_in = 0;
                rs_1_in = 0;				
			end
		endtask	
		task set;
			begin
				iadder_src_in = 1;
				pc_in = 32'hffff;
                imm_in = 32'hffff;
                rs_1_in = 32'hffff;
			end
		endtask	
		task stim(input [31:0] a,b,c,input d);
			begin
				pc_in = a;
                imm_in = b;
                rs_1_in = c;		
				iadder_src_in = d;				
			end
		endtask	

// stim

			initial begin
			      initialize;
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);	
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  stim({$random}%165430,{$random}%165430,{$random}%165430,{$random}%2);
				  #10;
				  set;
                   #10 $finish;
                end				   
				  
endmodule
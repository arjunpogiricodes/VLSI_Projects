


// msrv32_imm_generator

module msrv32_imm_generator_tb();

		reg [31:7] instr_in;
		reg [2:0] imm_type_in;
		wire [31:0] imm_out;

// instantiation

		msrv32_imm_generator DUT(instr_in,imm_type_in,imm_out);

		task initialize;
			begin
				instr_in = 0;
				imm_type_in = 0;		
			end
		endtask	
		task set;
			begin
				instr_in = 25'hffff;
				imm_type_in = 3'b111;
			end
		endtask	
		task stim(input [31:7] a,input [2:0] b);
			begin
				instr_in = a;
				imm_type_in = b;				
			end
		endtask	
		
// stim

			initial begin
			      initialize;
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  stim({$random}%165430,{$random}%8);
				  #10;
				  set;
				  #10;
				  $finish;
				  end
				
endmodule
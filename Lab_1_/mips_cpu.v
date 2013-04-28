module mips_cpu
  (
   input clk,
   input rst   
   );



   wire [1:0] alu_op,
	    alu_src_b,
	    pc_source,
	    wreg_dst,
	    wreg_data_sel;
										  
   wire     mem_read,
	    mem_write,
	    i_or_dor_d,
	    reg_write,
	    ir_write,
	    pc_write,
	    pc_write_cond,
	    alu_src_a,
	    imm_com;

   wire [5:0] opcode;
   

   control_unit ctrl_inst  (
			    .clk          (clk),
			    .rst          (rst),
			    .alu_op       (alu_op),
			    .alu_src_b    (alu_src_b),
			    .pc_source    (pc_source),
			    .wreg_dst     (wreg_dst),
			    .wreg_data_sel(wreg_data_sel),
			    .mem_read     (mem_read),
			    .mem_write    (mem_write),
			    .i_or_d       (i_or_d),
			    .reg_write    (reg_write),
			    .ir_write     (ir_write),
			    .pc_write     (pc_write),
			    .pc_write_cond(pc_write_cond),
			    .alu_src_a    (alu_src_a),
			    .imm_com      (imm_com),
			    .opcode       (opcode)
			    );
   

   datapath datapath_inst (
			   .clk    (clk),	       
			   .rst    (rst ),	       
			   .alu_op (alu_op ),	       
			   .alu_src_b(alu_src_b),	  
			   .pc_source(pc_source),	  
			   .wreg_dst(wreg_dst),	  
			   .wreg_data_sel(wreg_data_sel),				  
			   .mem_read(mem_read),	  
			   .mem_write(mem_write),	  
			   .i_or_d(i_or_d),	       
			   .reg_write(reg_write),	  
			   .ir_write(ir_write),	  
			   .pc_write(pc_write),	  
			   .pc_write_cond(pc_write_cond), 
			   .alu_src_a(alu_src_a),	  
			   .imm_com(imm_com),	  
			   .opcode(opcode)	       
			   );
   

endmodule

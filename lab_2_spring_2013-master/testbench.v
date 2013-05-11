`timescale 1ns / 1ps


module testbench;

   // Inputs
   reg        clk;
   reg        rst;
   reg [31:0] ext_data_in;

   // Outputs
   wire        ext_write_en;
   wire        ext_read_en;
   wire [31:0] ext_addr;
   wire [31:0] ext_write_data;

   // Instantiate the Unit Under Test (UUT)
   mips_system uut (
		    .clk(clk), 
		    .rst(rst), 
		    .ext_write_en(ext_write_en), 
		    .ext_read_en(ext_read_en), 
		    .ext_addr(ext_addr), 
		    .ext_write_data(ext_write_data), 
		    .ext_data_in(ext_data_in)
	            );

   initial begin
      rst = 1;
      ext_data_in = 0;
      
      // Wait 100 ns for global reset to finish
      #100;
      rst = 0;
      
   end // initial begin


   initial begin
      clk = 0;
      forever
        #10 clk = !clk;      
   end


	integer i;
   initial begin

      for (i = 0; i < 1000; i=i+1)
        @(posedge clk);


      $stop();      
   end

   initial
   begin
        $display("Trace register $t0");
        @(negedge rst);

        forever
         begin
           @(posedge clk);
           $display("$t0 (REG8) = %x",uut.pipeline_inst.idecode_inst.regfile_inst.rf[8]);           
         end



   end
   
   
endmodule


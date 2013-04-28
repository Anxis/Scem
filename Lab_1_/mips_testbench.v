module mips_testbench();

   reg clk;
   reg rst;
   
   mips_cpu dut ( .clk(clk), .rst(rst) );

   initial begin
      clk = 0;
      forever
        #10 clk = ~clk;              
   end


   initial begin
      rst = 1;
      
      repeat (4)
        @(posedge clk);

      rst = 0;

      repeat (1000)
        @(posedge clk);

      $stop();
      
   end

   initial begin
      forever
        begin
           @(posedge clk);
           $display("$t0 (REG8) = %x",dut.datapath_inst.regfile_inst.rf[8]);           
        end
   end
   

endmodule

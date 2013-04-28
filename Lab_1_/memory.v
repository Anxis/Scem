`timescale 1ns / 1ps

/**
 Asynchronous memory 
      (asynchronous read, synchronous write)
 */
module memory(
	      input wire 	 clk,            // clock to trigger write
	      input wire 	 r_en,           // read enable
	      input wire 	 w_en,           // write enable
	      input wire [31:0]  addr,           // read/write address
	      input wire [31:0]  wdata,          // data to write
	      output wire [31:0] rdata         // data read
	      );

   reg [31:0] 			 mem[0:1023];  // 1024 32-bit words : 4 Kb


   initial begin
      $readmemh("./sw/test.rom", mem);      
   end
   
   
   assign rdata = r_en ? mem[addr] : 0;

   always @(posedge clk)
     begin
        if(w_en)
	  mem[addr] <= wdata;
     end
   
endmodule

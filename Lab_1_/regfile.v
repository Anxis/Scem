`timescale 1ns / 1ps

/**
 Register file: 
     * 2 asyncrhonous read ports
     * 1 synchronous write port
 */
module regfile(
               input wire         clk,                   // clock to trigger write
               input wire         rst,                   // reset
               input wire [4:0]   raddr1, raddr2, waddr, // the registers numbers to read or write
               input wire [31:0]  wdata,                 // data to write
               input wire         w_en,                  // write enable
               output wire [31:0] rdata1, rdata2         // the register values read
               );    

   
   reg [31:0]                        rf [31:0];          // 32 registers each 32 bits long

	reg [31:0] rdata1_reg; 
	reg [31:0] rdata2_reg; 
	always @(posedge clk)
	  begin
	    rdata1_reg <= rf [raddr1];
	    rdata2_reg <= rf [raddr2];
	  end
   assign rdata1 = rdata1_reg;
   assign rdata2 = rdata2_reg;	
	
   always @(posedge clk)
     begin
        if (rst)
          rf[0] <= 0;
        else
          if(w_en)
            rf [waddr] <= wdata;
     end

endmodule

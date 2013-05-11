`timescale 1ns / 1ps

/**
 Dual-port Instrcution/Data memory
 */

module dp_memory(
                 input wire          clk,
                 
                 input  wire         i_read_en,
                 input  wire [31:0]  i_addr,
                 output wire [31:0]  i_instr_out,

                 input  wire         d_read_en,
                 input  wire         d_write_en,
                 input  wire [31:0]  d_addr,
                 input  wire [31:0]  d_write_data,
                 output wire [31:0]  d_data_out                 
                 );

   reg [31:0]                        mem[0:1023];

   initial begin
      $readmemh("./sw/test.rom", mem);      
   end

   
   always @(posedge clk) begin
      if (d_write_en)
        mem [d_addr] <= d_write_data;      
   end
   
   assign i_instr_out = i_read_en ? mem[i_addr] : 0;
   assign d_data_out  = d_read_en ? mem[d_addr] : 0;
   
endmodule
     

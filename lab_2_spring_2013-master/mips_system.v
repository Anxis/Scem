/*
 MIPS System: CPU Core + Memory 
 */

module mips_system 
  (
   input wire    clk,
   input wire    rst,

   output        ext_write_en,
   output        ext_read_en,
   output [31:0] ext_addr,
   output [31:0] ext_write_data,
   input  [31:0] ext_data_in
   ) ;

   wire          i_read_en;   
   wire [31:0]   i_addr;
   wire [31:0]   i_instr;
   wire          d_read_en;   
   wire          d_write_en;   
   wire [31:0]   d_addr;   
   wire [31:0]   d_write_data;   
   wire [31:0]   d_read_data;
   
   pipeline pipeline_inst 
     (
      .clk(clk),
      .rst(rst),
      .i_read_en(i_read_en),
      .i_addr(i_addr),
      .i_instr_in(i_instr),
      .d_read_en(d_read_en),
      .d_write_en(d_write_en),
      .d_addr(d_addr),
      .d_write_data(d_write_data),
      .d_data_in(d_read_data)
      );
   

   dp_memory memory_inst
     (
      .clk(clk),
      .i_read_en(i_read_en),
      .i_addr(i_addr),
      .i_instr_out(i_instr),
      .d_read_en(d_read_en),
      .d_write_en(d_write_en),
      .d_addr(d_addr),
      .d_write_data(d_write_data),
      .d_data_out(d_read_data)
      );
   
   
endmodule // mips_system

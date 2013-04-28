`timescale 1ns / 1ps

/**
 Processor datapath
 */
module datapath(

                input wire        clk,           // system clock
                input wire        rst,           // system reset
                                                 
                input wire [1:0]  alu_op,        // ALU opcode override
                                  alu_src_b,     // Select second operand source
                                  pc_source,     // Select PC source
                                  wreg_dst,      // Select destination register addr
                                  wreg_data_sel, // Select data to write in register
                                                                                                          
                input wire        mem_read,      // Memory read enable
                                  mem_write,     // Memory write enable
                                  i_or_d,        // Select instruction or data address
                                  reg_write,     // Register file write enable
                                  ir_write,      // IR write enable
                                  pc_write,      // PC write enable
                                  pc_write_cond, // PC conditional write (in case of branch instruction)
                                  alu_src_a,     // Select first operand source
                                  imm_com,       // Command with immidiate operand
                
                output wire [5:0] opcode         // opcode for ctrl unit
                );
   


   /********************************************************************************************
    Signal declarations
    ********************************************************************************************/
   
   // Program Counter
   reg [31:0]            pc_reg;

   // Memory data register
   reg [31:0]            mdr_reg;

   // Instruction register
   reg [31:0]            ir_reg;

   // ALU output register
   reg [31:0]            alu_out_reg;

   // regfile output registers
   reg [31:0]            a_reg, b_reg;
   

   wire                  zero;              // Zero signal from ALU
   wire [31:0]           mem_out, 
                         addr,
                         write_data,
                         a_out,
                         b_out,
                         pc_value,
                         sing_extend_offset,
                         pc_offset, 
                         alu_b_in,
                         alu_a_in,
                         alu_result_out;
   
   wire [4:0]            write_reg;
   wire [4:0]            alu_ctl;        // ALU control lines
   wire [5:0]            func_code;      // Func code for ALU control
   wire                  overflow;

   /********************************************************************************************
    Combinational signals assignments used in the datapath
    ********************************************************************************************/

   assign addr               = i_or_d ? alu_out_reg : ( pc_reg >> 2);   
   assign opcode             = ir_reg[31:26];
   assign sing_extend_offset = { { 16{ir_reg[15]} } , ir_reg[15:0] }; // sign-extend lower 16 bits
   
   assign pc_offset          = sing_extend_offset << 2;
   assign alu_a_in           = alu_src_a ? a_reg : pc_reg;         // ALU input is PC or A


   /*
    Description of FuncCode signal
    Regularity of immediate commands which use ALU:

    Opcode ADDI  - 001_000
    FuncCode ADD - 100_000
    Opcode ANDI  - 001_100
    FuncCode AND - 100_100
    Opcode ORI   - 001_101
    FuncCode OR  - 100_101
    Opcode XORI  - 001_110
    FuncCode XOR - 100_110
    Opcode SLTI  - 001_010
    FuncCode SLT - 101_010

    Results:
    opcode[2:0] equals funcode[2:0] for all commands
    funccode[3] equals (~opcode[2] & opcode[1] & ~opcode[0])
    funcode[5:0] always equals 2'b10
    */

   // ALU Contol func code
   assign func_code = imm_com ? 
                      { {2'b10} , {~opcode[2] & opcode[1] & ~opcode[0]} , opcode[2:0] } 
                      : ir_reg [5:0];
 

   // ****************************************************************************
   // create an instance of the memory Unit
   // ****************************************************************************
   memory mem_inst(
                   .clk     (clk), 
                   .r_en    (mem_read),
                   .w_en    (mem_write),
                   .addr    (addr),
                   .wdata   (b_reg),
                   .rdata   (mem_out)
                   );
   
   // ****************************************************************************
   // create an instance of register file
   // ****************************************************************************
   regfile regfile_inst(
                        .clk    (clk),
                        .rst    (rst),
                        .raddr1 (ir_reg [25:21]),
                        .raddr2 (ir_reg [20:16]),
                        .waddr  (write_reg),
                        .wdata  (write_data),
                        .w_en   (reg_write),
                        .rdata1 (a_out),
                        .rdata2 (b_out)
                        );    
   

   // ****************************************************************************
   // create a 3-to-1 multiplexor used to select the source of the next PC
   // ****************************************************************************
   mux3_1 #( .WIDTH (32) ) 
   pc_source_mux(
                 .in0(alu_result_out),                        // Incremented PC 
                 .in1(alu_out_reg),                           // the branch address 
                 .in2({pc_reg[31:28], ir_reg[25:0], 2'b00}),  // Jump target address
                 .sel(pc_source),                             // PC Source selector signal        
                 .out(pc_value)                               // 32-bit output
                 );
   
   // ****************************************************************************
   // create a 3-to-1 multiplexor used to select the address of write register
   // ****************************************************************************
   mux3_1 #( .WIDTH(5) ) 
   write_reg_addr_mux(    
                          .in0(ir_reg [20:16]),                      
                          .in1(ir_reg [15:11]),                      
                          .in2(5'd31),                         // Reg with return address (for jal)
                          .sel(wreg_dst),                      // Reg Address selector signal        
                          .out(write_reg)                      // 5-bit output
                          );

   // ****************************************************************************
   // create a 3-to-1 multiplexor used to select the source of data to write in register file
   // ****************************************************************************
   mux3_1 #( .WIDTH (32) ) 
   write_reg_data_mux(    
                          .in0(alu_out_reg),                      
                          .in1(mdr_reg),                      
                          .in2(pc_reg),                        // PC (for jal)
                          .sel(wreg_data_sel),                 // Data write reg source selector signal        
                          .out(write_data)                     // 32-bit output
                          );
   
   // ****************************************************************************
   // create an instance of ALU control unit
   // ****************************************************************************
   alu_ctrl aluctl_inst(
                       .alu_op    (alu_op),
                       .func_code (func_code),
                       .alu_ctl   (alu_ctl)
                       );


   // ****************************************************************************
   // create a 4-to-1 multiplexor used to select the B input of the ALU
   // ****************************************************************************
   mux4_1 #( .WIDTH(32) ) 
   alu_b_mux(
             .in0(b_reg),
             .in1(32'd4),                // For PC + 4 Operation
             .in2(sing_extend_offset),
             .in3(pc_offset),            //four 32-bit inputs
             .sel(alu_src_b),            //selector signal        
             .out(alu_b_in)              // 32-bit output
             );


   // ****************************************************************************
   // create ALU
   // ****************************************************************************
   alu alu_inst (
                 .alu_ctl   (alu_ctl), 
                 .a_in      (alu_a_in), 
                 .b_in      (alu_b_in), 
                 .result    (alu_result_out), 
                 .zero_flag (zero)
                 );
   
   

   always @(posedge clk)
     begin
        if (rst)
          begin
             alu_out_reg <= 0;
             pc_reg      <= 0;
             ir_reg      <= 0;
             mdr_reg     <= 0;
          end
        else
          begin
             alu_out_reg <= alu_result_out;            // Save the ALU result for use on a latter clock cycle
             
             if (ir_write)
               ir_reg <= mem_out;                      // Write the IR if an instruction fetch
             
             mdr_reg  <= mem_out;                      // Always save the memory read value

             a_reg <= a_out;
             
             b_reg <= b_out;

             
             if ( pc_write || (pc_write_cond & zero) ) 
               pc_reg <= pc_value;           
          end
     end
   
endmodule

module control_unit(

                input wire        clk,           // system clock
                input wire        rst,           // system reset
                                                 
                output reg [1:0]  alu_op,        // ALU opcode override
                                  alu_src_b,     // Select second operand source
                                  pc_source,     // Select PC source
                                  wreg_dst,      // Select destination register addr
                                  wreg_data_sel, // Select data to write in register
                                                                                                          
                output reg        mem_read,      // Memory read enable
                                  mem_write,     // Memory write enable
                                  i_or_d,        // Select instruction or data address
                                  reg_write,     // Register file write enable
                                  ir_write,      // IR write enable
                                  pc_write,      // PC write enable
                                  pc_write_cond, // PC conditional write (in case of branch instruction)
                                  alu_src_a,     // Select first operand source
                                  imm_com,       // Command with immidiate operand
                
                input  wire [5:0] opcode         // opcode for ctrl unit

);


   localparam
     LW    = 6'b100011, 
     SW    = 6'b101011, 
     BEQ   = 6'b000100, 
     RTYPE = 6'b0, 
     J     = 6'd2, 
     JAL   = 6'd3,                       
     ADDI  = 6'b001000, 
     ANDI  = 6'b001100, 
     ORI   = 6'b001101, 
     XORI  = 6'b001110, 
     SLTI  = 6'b001010;     //opcode constants
   

   localparam  // FSM States
     FETCH                     = 1, 
     DECODE                    = 2, 
     EXECUTION                 = 3, 
     MEM_ACCESS_REG_COMPLETION = 4, 
     MEM_READ_COMPLETION       = 5;



   
   reg [2:0]                      state, nextstate;

   // auxiliary signals
   reg                            memory_op, branch_op, r_type_op, immidiate_op;
   

   // Combinatorial part of control FSM
   // Generate nextstate code and set control ouputs
   always @(state or opcode)
     begin
        //default signal values
        //multiplexers signals or comb logic control
        wreg_data_sel = 'bx;
        alu_op        = 'bx;
        wreg_dst      = 'bx;
        i_or_d        = 'bx;     
        alu_src_a     = 'bx;
        alu_src_b     = 'bx;
        pc_source     = 'bx;
        imm_com       = immidiate_op;
                                       
        //regs or mem signals
        ir_write      = 0;
        mem_read      = 0;
        mem_write     = 0;
        reg_write     = 0;
        pc_write      = 0;
        pc_write_cond = 0;
        
        //aux singals
        memory_op    = ( (opcode == LW) | ( opcode == SW) );
        branch_op    = ( opcode == BEQ );
        r_type_op    = ( opcode == RTYPE );    // RR Type
        immidiate_op = ( (  opcode == ADDI ) 
                         | (opcode == ANDI) 
                         | (opcode == ORI) 
                         | (opcode == XORI) 
                         | (opcode == SLTI));  // RI-type
        
        case (state)
          // first stage (general for all)
          FETCH: begin
             nextstate = DECODE;
             
             ir_write  = 1;   // IR <= Memory[PC]
             i_or_d    = 0;   // Instructions, for address used PC value
             mem_read  = 1;
             
             // PC <= PC + 4
             pc_write  = 1;
             pc_source = 'b00;  // PC source is alu_result_out
             alu_op    = 'b00;  // add operation
             alu_src_a = 0;     // alu_a <- PC
             alu_src_b = 'b01;  // alu_b <- 4
          end
          
          // second stage (general for all)
          DECODE: begin
             nextstate = EXECUTION;
             /* A <= Reg [IR[25:21]] and B <= Reg [IR[20:16]] */
             
             //alu_out <= PC + (sign-extend(IR[15:0]) << 2)
             alu_op    = 'b00; // add op
             alu_src_a = 0;    // alu_a <- PC
             alu_src_b = 'b11; // alu_b <- sign-extend(IR[15:00]) << 2
          end
          
          // third stage
          EXECUTION: begin
             if (memory_op)
               begin
                  nextstate = MEM_ACCESS_REG_COMPLETION;
                  // alu_out <= a + sign-extend (IR[15:0])
                  alu_op    = 'b00; // add op
                  alu_src_a = 1;    // alu_a <- a
                  alu_src_b = 'b10; // alu_b <- sign-extend (IR[15:0])
               end
             else if (opcode == J)  // if jump
               begin
                  nextstate = FETCH;
                  // PC <- jump_address
                  pc_write  = 1;
                  pc_source = 'b10;  // Jump target address {PC[31:28], IR[25:0], 2'b00}
               end
             else if (opcode == JAL) // if jump and link
               begin
                  nextstate     = FETCH;
                  // PC <- jump_address
                  pc_write      = 1;
                  pc_source     = 'b10; // Jump target address {PC[31:28], IR[25:0], 2'b00}
                  // Reg[31] <- PC - Save return address to Reg[31]
                  wreg_dst      = 'b10; // write reg - Reg[31]
                  wreg_data_sel = 'b10; // PC value on write_data lines of regfile
                  reg_write     = 1; 
               end
             else if (branch_op) 
               begin
                  nextstate = FETCH; // non-delayed branch
                  // if (A == B) PC <- alu_out
                  pc_write_cond = 1;
                  pc_source     = 'b01; // PC source is alu_out_reg
                  // check on zero by substract
                  alu_op        = 'b01; // sub op
                  alu_src_a     = 1;    // alu_b <- a
                  alu_src_b     = 'b00; // alu_b <- b
               end
             else if (r_type_op)
               begin
                  nextstate = MEM_ACCESS_REG_COMPLETION;
                  //alu_out = A op B
                  alu_op =  'b10;    // Operation defined by function code
                  alu_src_a = 1;     // alu_a <- A
                  alu_src_b = 'b00;  // alu_b <- B
               end
             else if (immidiate_op)
               begin
                  nextstate = MEM_ACCESS_REG_COMPLETION;
                  //alu_out = A op Immediate_operand
                  alu_op    = 'b10; // Operation defined by command (see signal func_code in Datapath)
                  alu_src_a = 1;    // alu_a <- A
                  alu_src_b = 'b10; // alu_b <- sign-extend immediate (IR[15:0])
               end
             else nextstate = FETCH; // non-valid opcode
             
          end
          
          // forth stage
          MEM_ACCESS_REG_COMPLETION: begin
             if (r_type_op)
               begin
                  nextstate     = FETCH;
                  // Reg[IR[15:11]] <= alu_out
                  wreg_dst      = 'b01;   // write reg number defined by rd field (IR[15:11])
                  reg_write     = 1;      // write in register file
                  wreg_data_sel = 'b00;   // alu_out value on write_data lines of regfile
               end
             else if (immidiate_op)
               begin
                  nextstate = FETCH;
                  // Reg[IR[20:16]] <= ALUOut
                  wreg_dst      = 'b00; // write reg number defined by rt field (IR[20:16])
                  reg_write     = 1;    // write in register file
                  wreg_data_sel = 'b00; // alu_out value on write_data lines of regfile
               end
             else begin // memory_op
                if (opcode == LW)
                  begin
                     nextstate = MEM_READ_COMPLETION;
                     // MDR <= Mem[ALUOut]
                     i_or_d    = 1; // Data, for address used alu_out value
                     mem_read  = 1;
                  end
                else begin // opcode == SW
                   nextstate = FETCH;
                   // Mem[ALUOut] <= B
                   // B connected with mem write lines in datapath
                   i_or_d    = 1; // Data, alu_out as address
                   mem_write = 1;
                end
             end
          end
          
          // fifth stage
          MEM_READ_COMPLETION: begin
             /* This stage only for completetion of load word (LW opcode) 
              command and without any checks
              */
             nextstate     = FETCH;
             // Reg[IR[20:16]] <= MDR
             reg_write     = 1;
             wreg_dst      = 'b00; // write reg number defined by rt field (IR[20:16])
             wreg_data_sel = 'b01; // MDR value on WriteData lines of RegFile
          end
          
          default: nextstate = FETCH;
        endcase
     end // always @ (state or opcode)


   
   // Control FSM state reg
   always @(posedge clk)
     begin
        if (rst) 
          state <= FETCH;
        else 
          state <= nextstate;
     end
   
endmodule

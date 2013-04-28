module mux3_1 #( parameter WIDTH = 32)
   (
    input wire [WIDTH - 1 : 0] in0, in1, in2,
    input wire [1 : 0] 	       sel,
    output reg [WIDTH - 1 : 0] out
    );
   
   always @*
     begin
	case (sel)
	  2'b00 : out = in0;	  
	  2'b01 : out = in1;	  
	  2'b10 : out = in2;	  
	  default: out = 'hx; // should not happen	  
	endcase
     end
   
endmodule

module mux4_1 #( parameter WIDTH = 32)
   (
    input wire [WIDTH - 1 : 0] in0, in1, in2, in3,
    input wire [1 : 0] 	       sel,
    output reg [WIDTH - 1 : 0] out
    );


   always @*
     begin
	case (sel)
	  2'b00 : out = in0;	  
	  2'b01 : out = in1;	  
	  2'b10 : out = in2;
	  2'b11 : out = in3;
	endcase
     end


   
endmodule

module mux5_1 #( parameter WIDTH = 32)
   (
    input wire [WIDTH - 1 : 0] in0, in1, in2, in3, in4,
    input wire [2 : 0] 	       sel,
    output reg [WIDTH - 1 : 0] out
    );

   always @*
     begin
	case (sel)
	  3'b000 : out = in0;	  
	  3'b001 : out = in1;	  
	  3'b010 : out = in2;
	  3'b011 : out = in3;
	  3'b100 : out = in4;
	  default: out = 'hx; // should not happen 
	endcase
	
     end

   
endmodule

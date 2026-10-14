/*
module divider (
  input wire [31:0]  a,
  input wire [31:0]  b,
  input wire unsigned_instr,

  output reg [63:0] out 
);
wire signed_op = ~unsigned_instr;

wire [31:0] a_div;
wire [31:0] b_div;
reg  [63:0] out_div;

assign a_div = (signed_op & a[31])? -a : a;
assign b_div = (signed_op & b[31])? -b : b;

assign out_div = a_div / b_div; //preform an absolute division

assign out = ((signed_op & a[31] & ~b[31]) || (signed_op & ~a[31] & b[31]))
             ? -out_div 
             : out_div;



endmodule

*/
module divider (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire unsigned_instr,

    output wire [63:0] out
);

wire signed [31:0] signed_a = $signed(a);
wire signed [31:0] signed_b = $signed(b);

wire [31:0] signed_quotient  = signed_a / signed_b;
wire [31:0] signed_remainder = signed_a % signed_b;

wire [31:0] unsigned_quotient  = a / b;
wire [31:0] unsigned_remainder = a % b;

wire [31:0] quotient =
    unsigned_instr ? unsigned_quotient : signed_quotient;

wire [31:0] remainder =
    unsigned_instr ? unsigned_remainder : signed_remainder;

// Upper 32 = remainder (HI)
// Lower 32 = quotient  (LO)
assign out = {remainder, quotient};

endmodule

module multiplier (
  input wire [31:0]  a,
  input wire [31:0]  b,
  input wire unsigned_instr,

  output reg [63:0] out 
);
wire signed_op = ~unsigned_instr;

wire [31:0] a_mul;
wire [31:0] b_mul;
reg  [63:0] out_mul;

assign a_mul = (signed_op & a[31])? -a : a;
assign b_mul = (signed_op & b[31])? -b : b;

assign out_mul = a_mul * b_mul; //preform an absolute multiplication

assign out = ((signed_op & a[31] & ~b[31]) || (signed_op & ~a[31] & b[31]))
             ? -out_mul 
             : out_mul;



endmodule


/*
module multiplier (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire unsigned_instr,

    output wire [63:0] out
);

wire signed [63:0] signed_a = {{32{a[31]}}, a};
wire signed [63:0] signed_b = {{32{b[31]}}, b};

wire [63:0] unsigned_a = {32'b0, a};
wire [63:0] unsigned_b = {32'b0, b};

wire [63:0] signed_product   = signed_a * signed_b;
wire [63:0] unsigned_product = unsigned_a * unsigned_b;

assign out = unsigned_instr ? unsigned_product : signed_product;

endmodule
*/
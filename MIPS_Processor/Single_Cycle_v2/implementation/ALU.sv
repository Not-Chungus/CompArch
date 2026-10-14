import mips_pkg::*;

module alu (
  input wire signed [31:0]  src_a,
  input wire signed [31:0]  src_b,
  input ALU_Cntrl_e  alu_control, //4 bit enum
  input              unsigned_instr,
  input wire        [4:0]   shamt,

  output flags_t           flags, //3 bits packed struct
  output reg signed [31:0] alu_result 
);


always @(*) begin
    case(alu_control)
        ADD : alu_result = src_a + src_b ;
        SUB : alu_result = src_a - src_b ;

        AND : alu_result = src_a & src_b ;
        OR  : alu_result = src_a | src_b ;
        XOR : alu_result = src_a ^ src_b ;
        NOR : alu_result = ~(src_a | src_b );

        COMPARE : 
        alu_result = unsigned_instr ? 
                     ($unsigned(src_a) < $unsigned(src_b)) :
                     (src_a < src_b);
        
        //should better implement a shifting unit
        SLL : alu_result = src_b << shamt ;
        SRL : alu_result = src_b >> shamt ;
        SRA : alu_result = src_b >>> shamt;

        SLLV : alu_result = src_b << src_a[4:0] ;
        SRV  : alu_result = src_b >> src_a[4:0] ;
        SRAV : alu_result = src_b >>> src_a[4:0];

        default: alu_result = src_a; 
    endcase 
end

//Flags
assign flags.zero = ~(|alu_result);
assign flags.gt = (src_a > src_b); //should check unsigned or not?
assign flags.lt = (src_a < src_b); //should check unsigned or not?

//overflow exception
always @(*) begin
    case(alu_control)
        ADD: begin
            if(unsigned_instr)
                flags.OF = 0;
            else
                flags.OF = (src_a[31] & src_b[31] & ~alu_result[31])
                          |(~src_a[31]& ~src_b[31] & alu_result[31]);end

        default : flags.OF = 0;
    endcase

end



endmodule

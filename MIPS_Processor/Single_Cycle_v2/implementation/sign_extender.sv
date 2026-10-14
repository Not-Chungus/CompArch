module sign_extend (
input [15:0]  instruction_imm,
input zero_extend,

output [31:0] sign_imm 
);

    assign sign_imm = zero_extend ? 
                {{16{1'b0}},                 instruction_imm } :
                {{16{instruction_imm [15]}}, instruction_imm } ;

endmodule
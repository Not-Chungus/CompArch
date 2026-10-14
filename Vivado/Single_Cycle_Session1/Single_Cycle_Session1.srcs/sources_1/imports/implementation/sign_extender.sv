module sign_extend (
input [15:0]  instruction_imm,

output [31:0] sign_imm 
);

    assign sign_imm = {{16{instruction_imm [15]}}, instruction_imm } ;

endmodule
//may get more complex later...
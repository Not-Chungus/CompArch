`ifndef MIPS_DEFS_SVH
`define MIPS_DEFS_SVH

typedef enum logic [5:0] {
    R_type = 0,
    bltz = 1,
    j = 2, jal = 3,
    beq = 4, bne = 5, blez = 6, bgtz = 7,

    addi = 8, addiu = 9, slti = 10, sltiu = 11,
    andi = 12, ori = 13, xori = 14, lui = 15,

    mul = 28,

    lb = 32, lh = 33, lw = 35,
    lbu = 36, lhu = 37,

    sb = 40, sh = 41, sw = 43
} opcode_e;

localparam opcode_e bgez = bltz; // Same opcode
//this aliasing is only useful when verifying allowing to use either numeration




typedef enum logic [5:0] { //make it wire?
    sll = 0, srl = 2, sra = 3,
    sllv = 4, srlv = 6, srav = 7,

    jr = 8, jalr = 9,

    mfhi = 16, mthi = 17, mflo = 18, mtlo = 19,

    mult  = 24, multu = 25, div = 26, divu = 27,

    add   = 32, addu  = 33, sub = 34, subu = 35,

    and_  = 36, or_   = 37, xor_= 38, nor_ = 39,

    slt   = 42, sltu  = 43

} funct_e;


typedef enum logic [3:0] { //make it wire?
    ADD = 0, SUB = 1,

    AND = 2 ,OR = 3, XOR = 4, NOR = 5,

    COMPARE = 6,

    SLL = 7, SRL = 8, SRA = 9,
    SLLV = 10, SRV = 11, SRAV = 12

} ALU_Cntrl_e;

typedef struct packed {
    logic zero;
    logic gt;
    logic lt;

    logic OF;
} flags_t;


`endif
import mips_pkg::*;

module ctrl_unit (
input opcode_e   opcode, //logic [5:0] enum
input funct_e    funct,  //[logic 5:0] enum
input flags_t flags, //4 bits packed struct
input wire rt_0, //need to check the other bits?


output ALU_Cntrl_e alu_control,
output reg [1:0] alu_src,
output reg       reg_write, 
output reg [1:0] reg_dst,    
output reg [2:0] mem_to_reg,

output reg [1:0] mem_data_size,
output reg       mem_write,

output reg [1:0] pc_src,

output reg [1:0] hi_src,
output reg [1:0] lo_src,
output reg hi_write,
output reg lo_write,

output reg unsigned_instr,

output reg zero_extend
);

localparam ALU_Cntrl_e X = ADD;

//hi lo control signals=======================================
always @(*) begin
  if (opcode == R_type) begin
    case (funct)
      mthi  : begin hi_src=0; lo_src=0; hi_write=1; lo_write=0; end
      mtlo  : begin hi_src=0; lo_src=0; hi_write=0; lo_write=1; end
      mult  : begin hi_src=1; lo_src=1; hi_write=1; lo_write=1; end
      multu : begin hi_src=1; lo_src=1; hi_write=1; lo_write=1; end
      div   : begin hi_src=2; lo_src=2; hi_write=1; lo_write=1; end
      divu  : begin hi_src=2; lo_src=2; hi_write=1; lo_write=1; end
      default : begin hi_src=0; lo_src=0; hi_write=0; lo_write=0; end
    endcase
  end else begin
    hi_src=0; lo_src=0; hi_write=0; lo_write=0;
  end
end



//zero extend signal=========================================
always @(*) begin //
  case (opcode) 
   andi    : zero_extend = 1; // andi
   ori     : zero_extend = 1; // ori
   xori    : zero_extend = 1; // xori
   //lbu     : zero_extend = 1; // lbu not needed?
   //lhu     : zero_extend = 1; // lhu not needed?
   
   default : zero_extend = 0;
  endcase  
end


//Unsigned Instruction signal=========================================
always @(*) begin //
  case (opcode) 
   R_type: case (funct)
      multu   : unsigned_instr = 1;
      divu    : unsigned_instr = 1;
      addu    : unsigned_instr = 1;
      subu    : unsigned_instr = 1;
      sltu    : unsigned_instr = 1;
      default : unsigned_instr = 0;
   endcase
  
   addiu   : unsigned_instr = 1;
   sltiu   : unsigned_instr = 1;
   lbu     : unsigned_instr = 1;
   lhu     : unsigned_instr = 1;
   default : unsigned_instr = 0;
  endcase  
end

   
    
//ALU, ALUSrc, RegWrite, RegDst and MemtoReg------------------

always @(*) begin
  case (opcode)
   R_type  : begin
    case (funct)
      sll     : begin alu_control=SLL;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      srl     : begin alu_control=SRL;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      sra     : begin alu_control=SRA;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      sllv    : begin alu_control=SLLV;    alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      srlv    : begin alu_control=SRV;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      srav    : begin alu_control=SRAV;    alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end

      jr      : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
      jalr    : begin alu_control=X;       alu_src=0; reg_write=1; reg_dst=2; mem_to_reg=4; end
  
      mfhi    : begin alu_control=X;       alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=2; end
      mthi    : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
      mflo    : begin alu_control=X;       alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=3; end
      mtlo    : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
  
      mult    : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
      multu   : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
      div     : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
      divu    : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end

      add     : begin alu_control=ADD;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      addu    : begin alu_control=ADD;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      sub     : begin alu_control=SUB;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      subu    : begin alu_control=SUB;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end

      and_    : begin alu_control=AND;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      or_     : begin alu_control=OR;      alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      xor_    : begin alu_control=XOR;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      nor_    : begin alu_control=NOR;     alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end

      slt     : begin alu_control=COMPARE; alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end
      sltu    : begin alu_control=COMPARE; alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=0; end

      default : begin alu_control=ADD;     alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
    endcase end

   bltz    : begin alu_control=COMPARE; alu_src=2; reg_write=0; reg_dst=0; mem_to_reg=0; end
   j       : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
   jal     : begin alu_control=X;       alu_src=0; reg_write=1; reg_dst=2; mem_to_reg=4; end
   beq     : begin alu_control=SUB;     alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
   bne     : begin alu_control=SUB;     alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
   blez    : begin alu_control=COMPARE; alu_src=2; reg_write=0; reg_dst=0; mem_to_reg=0; end
   bgtz    : begin alu_control=COMPARE; alu_src=2; reg_write=0; reg_dst=0; mem_to_reg=0; end

   addi    : begin alu_control=ADD;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=0; end
   addiu   : begin alu_control=ADD;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=0; end
   slti    : begin alu_control=COMPARE; alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=0; end
   sltiu   : begin alu_control=COMPARE; alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=0; end
   andi    : begin alu_control=AND;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=0; end
   ori     : begin alu_control=OR;      alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=0; end
   xori    : begin alu_control=XOR;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=0; end
   lui     : begin alu_control=X;       alu_src=0; reg_write=1; reg_dst=0; mem_to_reg=5; end 

   mul     : begin alu_control=X;       alu_src=0; reg_write=1; reg_dst=1; mem_to_reg=6; end //should check for funct =2 ?

   lb      : begin alu_control=ADD;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=1; end
   lh      : begin alu_control=ADD;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=1; end
   lw      : begin alu_control=ADD;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=1; end
   lbu     : begin alu_control=ADD;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=1; end
   lhu     : begin alu_control=ADD;     alu_src=1; reg_write=1; reg_dst=0; mem_to_reg=1; end

   sb      : begin alu_control=ADD;     alu_src=1; reg_write=0; reg_dst=0; mem_to_reg=0; end
   sh      : begin alu_control=ADD;     alu_src=1; reg_write=0; reg_dst=0; mem_to_reg=0; end
   sw      : begin alu_control=ADD;     alu_src=1; reg_write=0; reg_dst=0; mem_to_reg=0; end

   default : begin alu_control=X;       alu_src=0; reg_write=0; reg_dst=0; mem_to_reg=0; end
  endcase
end


//Memory Control-------------------
always @(*) begin
  case (opcode) 
   lb      : begin mem_data_size = 2'b00; mem_write = 0; end 
   lh      : begin mem_data_size = 2'b01; mem_write = 0; end 
   lw      : begin mem_data_size = 2'b10; mem_write = 0; end
   lbu     : begin mem_data_size = 2'b00; mem_write = 0; end
   lhu     : begin mem_data_size = 2'b01; mem_write = 0; end
   sb      : begin mem_data_size = 2'b00; mem_write = 1; end 
   sh      : begin mem_data_size = 2'b01; mem_write = 1; end 
   sw      : begin mem_data_size = 2'b10; mem_write = 1; end 

   default : begin mem_data_size = 2'b00; mem_write = 0; end 
  endcase  
end

//PC Control-------------------
always @(*) begin //
  case (opcode) 
   R_type  : pc_src = 
        (funct == jr || funct == jalr) ?  2'b11 : 2'b00;


   bltz    : pc_src = (~rt_0) ? ((flags.lt) ? 2'b01 : 2'b00)   //bltz
                    : ((!flags.lt) ? 2'b01 : 2'b00); //bgez
   j       : pc_src = 2'b10;
   jal     : pc_src = 2'b10;
   beq     : pc_src = (flags.zero)  ? 2'b01 : 2'b00;
   bne     : pc_src = (!flags.zero) ? 2'b01 : 2'b00;
   blez    : pc_src = (!flags.gt)   ? 2'b01 : 2'b00;
   bgtz    : pc_src = (flags.gt)    ? 2'b01 : 2'b00;
   
   default : pc_src = 2'b00;
  endcase  
end
    



endmodule
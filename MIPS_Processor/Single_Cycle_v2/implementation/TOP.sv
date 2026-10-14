import mips_pkg::*;

module MIPS_single_cycle(
    input wire clk,
    input wire rst_n,
    output wire [3:0] out_led //to prevent optimization by vivado
);
    reg  [31:0] hi, lo;
    wire [31:0] hi_in, lo_in;

    wire [31:0] pc_next, pc, pc_plus_4, pc_offset;
    wire [31:0] instruction;

    //Control Nets
    wire opcode_e opcode = opcode_e'(instruction[31:26]);
    wire funct_e funct = funct_e'(instruction[5:0]);
    flags_t flags;
    wire rt_0;

    ALU_Cntrl_e alu_control;
    wire [1:0]  alu_src;
    wire        reg_write;
    wire [1:0]  reg_dst;
    wire [2:0]  mem_to_reg;
    wire [1:0]  mem_data_size;
    wire        mem_write;
    wire [1:0]  pc_src;  
    wire [1:0]  hi_src;  
    wire [1:0]  lo_src;  
    wire        hi_write;      
    wire        lo_write;      
    wire        unsigned_instr;
    wire        zero_extend;
    

    wire [4:0]  reg_to_write_to;
    wire [31:0] Reg_WData;
    wire [31:0] rs, rt;


    wire [31:0] srcB;
    wire [4:0]  shamt = instruction[10:6];
    wire [31:0] alu_result;

    wire [63:0] mul_result;
    wire [63:0] div_result;

    wire [31:0] Read_Data;

    wire [31:0] sign_imm;


    pc_reg PC (.clk(clk), .pc_next(pc_next), .pc(pc), .rst(rst_n));

    ram_memory #(.depth(2048), .width(8)) Instr_mem (
        .clk(clk),
        .wr_en(1'b0), //could maybe connect to top to stop synthesis optimization
        .mem_data_size(2'b10),
        .unsigned_instr(1'b1),
        .addr(pc[$clog2(2048)-1:0]), 
        .wr_data(32'b0),//will use $readmemh

        .rd_data(instruction));
    
    ctrl_unit Control_unit (
        .opcode(opcode),
        .funct(funct),
        .flags(flags),
        .rt_0(instruction[16]), //check all the 5 bits?

        .alu_control(alu_control),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg),
        .mem_data_size(mem_data_size),
        .mem_write(mem_write),
        .pc_src(pc_src),
        .hi_src(hi_src),
        .lo_src(lo_src),
        .hi_write(hi_write),
        .lo_write(lo_write),
        .unsigned_instr(unsigned_instr),
        .zero_extend(zero_extend)
    );



    register_file Reg_file (
        .clk(clk),
        .wr_en3(reg_write),
        .rd_addr1(instruction[25:21]),
        .rd_addr2(instruction[20:16]),
        .wr_addr3(reg_to_write_to), 
        .wr_data3(Reg_WData),
        .rd_data1(rs),
        .rd_data2(rt)
        //,.s0_reg(out_led)
    );

    assign reg_to_write_to = 
            (reg_dst==0) ? instruction[20:16] : 
            (reg_dst==1) ? instruction[15:11] : 
            (reg_dst==2) ? 5'd31:
                          5'd0;

    alu ALU (
        .src_a(rs),
        .src_b(srcB),
        .alu_control(alu_control),
        .unsigned_instr(unsigned_instr),
        .shamt(shamt),

        .flags(flags),
        .alu_result(alu_result)
    );

    multiplier multiplier (
        .a(rs),
        .b(rt),
        .unsigned_instr(unsigned_instr),
        .out(mul_result)
    );

    divider divider (
        .a(rs),
        .b(rt),
        .unsigned_instr(unsigned_instr),
        .out(div_result)
    );

    assign srcB =
            (alu_src==0) ? rt : 
            (alu_src==1) ? sign_imm : 
            (alu_src==2) ? 32'd0:
                           32'd0;

    ram_memory #(.depth(256), .width(8)) Data_mem(
    .clk(clk),
    .wr_en(mem_write),
    .mem_data_size(mem_data_size),
    .unsigned_instr(unsigned_instr),
    .addr(alu_result[$clog2(256)-1:0]), 
    .wr_data(rt),
    .rd_data(Read_Data));

    sign_extend sign_extender (
    .instruction_imm(instruction[15:0]),
    .zero_extend(zero_extend),
    .sign_imm(sign_imm)
    );


    assign pc_plus_4 = pc + 4;
    assign pc_offset = (sign_imm<<2) + pc_plus_4;
    assign pc_next = 
            (pc_src==0) ? pc_plus_4 : 
            (pc_src==1) ? pc_offset : 
            (pc_src==2) ? {pc_plus_4[31:28],instruction[25:0],2'b00}:
                          rs;  


    assign Reg_WData = 
            (mem_to_reg==0) ? alu_result: 
            (mem_to_reg==1) ? Read_Data: 
            (mem_to_reg==2) ? hi:
            (mem_to_reg==3) ? lo:
            (mem_to_reg==4) ? pc_plus_4:              
            (mem_to_reg==5) ? {instruction[15:0],{16{1'b0}}}:
            (mem_to_reg==6) ? mul_result[31:0]:              
                              32'b0;
    

    assign hi_in = 
            (hi_src==0) ? rs: 
            (hi_src==1) ? mul_result[63:32]: 
            (hi_src==2) ? div_result[63:32]:
                          32'b0;
    assign lo_in = 
            (lo_src==0) ? rs: 
            (lo_src==1) ? mul_result[31:0]: 
            (lo_src==2) ? div_result[31:0] :
                          32'b0;

    //HI, LO Registers
    always @(posedge clk) begin
        if(hi_write)
            hi <= hi_in;
        if(lo_write)
            lo <= lo_in;
    end








    assign out_led = Reg_file.register_file[16][3:0];
endmodule
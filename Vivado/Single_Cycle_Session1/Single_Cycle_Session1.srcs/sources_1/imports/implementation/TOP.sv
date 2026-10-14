module MIPS_single_cycle(
    input wire clk,
    input wire rst_n,
    //,input wire instr_wr_en
    output [3:0] out_led 
);
    parameter depth = 1024;
    parameter width = 8;

    wire [31:0] pc_next, pc, pc_plus_4, pc_branch;
    wire [31:0] instruction;
    wire pc_src;

    wire mem_to_reg;
    wire branch;
    wire mem_write;
    wire [2:0] alu_control;
    wire alu_src;
    wire reg_dst;
    wire reg_write;
    wire jump; //unused right now
    

    wire [4:0] reg_to_write_to;
    wire [31:0] Reg_WData;
    wire [31:0] rt_data;

    wire [31:0] srcA,srcB;
    wire zero_flag;
    wire [31:0] alu_result;

    wire [31:0] Read_Data;

    wire [31:0] sign_imm;


    pc_reg PC (.clk(clk), .pc_next(pc_next), .pc(pc), .rst(rst_n));

    ram_memory #(.depth(depth), .width(width)) Instr_mem (
    .clk(clk),
    .wr_en(1'b0), 
    .addr(pc[$clog2(depth)-1:0]), 
    .wr_data(32'b0),//will use $readmemh
    .rd_data(instruction));
    
    ctrl_unit Control_unit (
    .funct(instruction[5:0]),
    .opcode(instruction[31:26]),

    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .mem_write(mem_write),
    .alu_control(alu_control),
    .alu_src(alu_src),
    .reg_dst(reg_dst),
    .reg_write(reg_write),
    .jump(jump));

    register_file Reg_file (
    .clk(clk),
    .wr_en3(reg_write),
    .rd_addr1(instruction[25:21]),
    .rd_addr2(instruction[20:16]),
    .wr_addr3(reg_to_write_to), 
    .wr_data3(Reg_WData),
    .rd_data1(srcA),
    .rd_data2(rt_data) 
    );

    assign reg_to_write_to = reg_dst ? instruction [15:11] : instruction [20:16];

    alu ALU (
    .src_a(srcA),
    .src_b(srcB),
    .alu_control(alu_control),
    .zero(zero_flag),
    .alu_result(alu_result));

    assign srcB = alu_src ? sign_imm : rt_data;

    ram_memory #(.depth(depth), .width(width)) Data_mem(
    .clk(clk),
    .wr_en(mem_write), 
    .addr(alu_result[$clog2(depth)-1:0]), 
    .wr_data(rt_data),
    .rd_data(Read_Data));

    sign_extend sign_extender (
    .instruction_imm(instruction[15:0]),
    .sign_imm(sign_imm)
    );

    assign Reg_WData = mem_to_reg ? Read_Data : alu_result;
    assign pc_plus_4 = pc + 4;
    assign pc_branch = (sign_imm<<2) + pc_plus_4;
    assign pc_src = branch & zero_flag;
    assign pc_next = 
            jump ? {pc_plus_4[31:28],instruction[25:0],2'b00} : 
            pc_src ? pc_branch : 
            pc_plus_4;
            
    assign out_led = Reg_file.register_file[16][3:0];



endmodule
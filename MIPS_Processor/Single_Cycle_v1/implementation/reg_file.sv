module register_file (
  input wire        clk,
  input wire        wr_en3,
  input wire [4:0]   rd_addr1,
  input wire [4:0]   rd_addr2,
  input wire [4:0]   wr_addr3,   
  input wire [31:0]  wr_data3,

  output wire [31:0]  rd_data1,
  output wire [31:0]  rd_data2
  //,output wire [3:0] s0_reg  //only for FPGA LEDs 
);

reg [31:0] register_file [0:31];

//two combinational READ Ports
assign  rd_data1  =  (rd_addr1 != 0)? register_file[rd_addr1]:0;
assign  rd_data2  =  (rd_addr2 != 0)? register_file[rd_addr2]:0;




//assign   s0_reg = register_file[16][3:0]; //only for FPGA LEDs 

//one synchronus WRITE Port with enable
always @(posedge clk) begin
        if (wr_en3)
             register_file[wr_addr3] <= wr_data3;
end
endmodule

//no reset?
//need to not allow writing to $0 register

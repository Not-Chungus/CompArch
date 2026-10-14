module ram_memory #(parameter depth = 1024,  parameter width = 8) (
    input clk,
    input wr_en,
    input [1:0] mem_data_size,
    input unsigned_instr,
    input [$clog2(depth)-1:0] addr,   
    input [(4*width)-1:0] wr_data,

    output reg [(4*width)-1:0] rd_data
);

    reg [width-1:0] mem [0:depth-1];

    initial begin //initialization   
     for(integer i = 0; i < depth; i = i+1 ) 
            mem [i] <= 0;    
    end


    always @(posedge(clk)) begin  //synchronus write with enable  
     if(wr_en)        
        if(mem_data_size==0)        {mem [addr]} <= wr_data[7:0];
        else if (mem_data_size==1)  {mem [addr+1], mem [addr]} <= wr_data[15:0];
        else if (mem_data_size ==2) {mem [addr+3], mem [addr+2],mem [addr+1], mem [addr]} <= wr_data;    
    end

    //combinational read with no enable  -- leads to incapability of using FPGA's LUT memory
    always @(*) begin  //synchronus write with enable 
    rd_data = 32'b0; 
      if (unsigned_instr) begin
        if(mem_data_size ==0)        rd_data = {{24{1'b0}} , mem [addr]};
        else if (mem_data_size ==1)  rd_data = {{16{1'b0}} , mem [addr+1], mem [addr]};
        else if (mem_data_size ==2)  rd_data = {mem [addr+3], mem [addr+2], mem [addr+1], mem [addr]};

      end else begin //sign extend
        if(mem_data_size ==0)        rd_data = {{24{mem [addr][7]}}  , mem [addr]};
        else if (mem_data_size ==1)  rd_data = {{16{mem [addr+1][7]}} , mem [addr+1], mem [addr]};
        else if (mem_data_size ==2)  rd_data = {mem [addr+3], mem [addr+2], mem [addr+1], mem [addr]};
      end
      
    end
endmodule
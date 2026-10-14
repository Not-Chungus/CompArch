module ram_memory #(parameter depth = 1024,  parameter width = 8) (
    input clk,
    input wr_en,
    input [$clog2(depth)-1:0] addr,   
    input [(4*width)-1:0] wr_data,

    output [(4*width)-1:0] rd_data
);

    reg [width-1:0] mem [0:depth-1];

    initial begin //initialization   
     for(integer i = 0; i < depth; i = i+1 ) 
            mem [i] <= 0;    
    end


    always @(posedge(clk)) begin  //synchronus write with enable  
     if(wr_en)        
        {mem [addr+3], mem [addr+2], mem [addr+1], mem [addr]} <= wr_data;    
    end

    //combinational read with no enable  -- leads to incapability of using FPGA's LUT memory
    assign  rd_data = {mem [addr+3], mem [addr+2], mem [addr+1], mem [addr]};
endmodule
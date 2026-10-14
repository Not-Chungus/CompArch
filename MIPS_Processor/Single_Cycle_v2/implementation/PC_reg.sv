module pc_reg ( 
    input clk,
    input rst, 
    input [31:0] pc_next, 

    output reg [31:0] pc
);

    always @(posedge clk or negedge rst) begin
        if(~rst)
            pc <= '0;
        else begin
            pc <= pc_next; 
        end
    end

endmodule
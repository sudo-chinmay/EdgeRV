module register_4bit (
    input logic clk,
    input logic rst,
    input logic en,
    output logic [3:0] q_out,       //3-MSB | 0-LSB | :-Range 
    input logic [3:0] d_in 
);

    always @(posedge clk or negedge rst) begin       //Asynchronous reset (i.e immediate rst goes low doen't wait for clk)
        if (rst) begin        //Resets when rst_n==1 (i.e Active high reset) => not standard (used in xilinx fpga's)
            q_out <= 4'b0000;
        end else if (en) begin
            q_out <= d_in;
        end
    end
    
endmodule
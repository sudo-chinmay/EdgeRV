module dff (
    input logic clk,        //Clock signal
    input logic d,          //Data input
    input logic rst,        //Active-low asynchronous Reset
    output logic q          //Registered output
);

    always_ff @(posedge clk) begin
        if (!rst) begin
            q <= 1'b0;  //sv uses "<=" for non-blocking assignments inside sequential block (always_ff @(...)) to avoid race condition.
        end else begin 
            q <= d;
        end
    end    
    
endmodule
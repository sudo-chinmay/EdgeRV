module dff (
    input logic clk,        //Clock signal
    input logic d,          //Data input
    input logic rst_n,        //Active-low asynchronous Reset (standard)
    output logic q          //Registered output
);

    always_ff @(posedge clk) begin      
        if (!rst_n) begin       //Synchronous reset as negedge of rst_n is not in sensitivity list (i.e rst will require next clk to go low) 
            q <= 1'b0;  //sv uses "<=" for non-blocking assignments inside sequential block (always_ff @(...)) to avoid race condition.
        end else begin 
            q <= d;
        end
    end    
    
endmodule
module counter_4bitUp (
    input logic clk,
    input logic rst,
    input logic en,
    output logic[3:0] q
);
    // 4-Bit Synchronous Up-Counter
    always_ff @( posedge clk ) begin
        if (rst) begin      //Synchronous + Active high reset
            q <= 4'b0000;
        end else if (en) begin
            q <= q+4'b0001;     //Increment by 1 on rising clk edge

            //Natuarlly wraps 1111->0000 by dropping 1 of 10000 as beacuse of defined size [3:0]            
        end

        // When en=0 the output value is hold to previous value.
    end
    
endmodule
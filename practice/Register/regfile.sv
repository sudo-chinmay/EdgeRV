`timescale 1ns/1ps

module regfile (
    input logic clk,             
    input logic rst,            //Asynchronous reset
    input logic we,             //Write enable
    input logic[4:0]  waddr,    //Write address
    input logic[31:0] wdata,    //Write data
    input logic[4:0] raddr1,    //Read address 1
    input logic[4:0] raddr2,    //Read address 2
    output logic[31:0] rdata1,  //Read data 1
    output logic[31:0] rdata2   //Read data 2
);
    //Creating a 32x32 Register File 
    logic [31:0] rf [31:0];

    //Snychronous Write with Asnyschronus reset
    always_ff @( posedge clk ) begin
        if (rst) begin 
            for (int i=0; i<32; i++) begin
                rf[i] <= 32'b0;
            end    
        end else if(!rst && we==1 && (waddr != 5'b0)) begin   //x0 hardwired to 0 and cannot be overwritten
            rf[waddr] <= wdata;
        end
    end

    //Asynchronous Read register file | Concurrent read using 2 seperate ports
    assign rdata1 = rf[raddr1];
    assign rdata2 = rf[raddr2];

endmodule

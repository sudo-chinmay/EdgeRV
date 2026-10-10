`timescale 1ns/1ps

module alu_4bit (
    input logic [3:0] a,
    input logic [3:0] b,
    input logic [2:0] sel,
    output logic [3:0] op
);
    always_comb begin 
        unique case (sel)
            3'b000 : op = a + b;             //Addition
            3'b001 : op = a - b;             //Subtraction
            3'b010 : op = a & b;             //bit-wise AND
            3'b011 : op = a | b;             //bit-wise OR
            3'b100 : op = a ^ b;             //bit-wise XOR    
            3'b101 : op = a << b[1:0];       //Shift Left Logical (SLL) | Slicing to 2 bits (0, 1, 2, 3)
            3'b110 : op = a >> b[1:0];       //Shift Right logical (SRL)
            3'b111 : op = a < b ? 4'b1 : 4'b0;   //Set Less Than (SLT)
            default : op = 4'b0000;           //Default safety case
        endcase             
    end

endmodule

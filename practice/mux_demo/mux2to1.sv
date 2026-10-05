module mux2to1 (
    input logic d0, //Data input 0
    input logic d1, //Data input 1
    input logic sel, //select line (0 -> d0, 1 -> d1)
    output logic y  //output    
);
    
    //Continuous Assignment using Ternary operator
    assign y = sel ? d1 : d0;

endmodule
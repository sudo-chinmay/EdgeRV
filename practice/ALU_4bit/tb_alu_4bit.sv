`timescale 1ns/1ps      // 1ns - time unit (for delay) | 1ps - time precision (0.001ns)

module tb_alu_4bit;

    //Testbench signals
    logic [3:0] a;
    logic [3:0] b;
    logic [2:0] sel;
    logic [3:0] op;

    //Initiate ALU (DUT - Device Under Test)
    alu_4bit uut (
        .a(a),      // .port_name(wire_name) | port-ALU, ()-tb variable 
        .b(b),
        .sel(sel),
        .op(op)
    );

    initial begin       
    //initial block - procedural block that starts executing at time 0 of simulation | executes exactly once and runs sequentially from top  to bottom
        //Setup waveform dumping for Gtkwave
        $dumpfile("alu_4bit_sv.vcd");   //create structural Value Change Dump file
        $dumpvars(0, tb_alu_4bit);      //0-dump every signal inside tb_alu_4bit module and any sub module connected

        $display("-----Starting SystemVerilog 4-bit ALU testbench-----");

        //1. Test ADD (5+3=8)
        a = 4'd5;
        b = 4'd3;
        sel = 3'b000;
        #10;        //halts 10ns
        assert(op == 8) else $fatal("[ERROR]: Failed Addition operation!");
        $display("[PASS] Add: 5 + 3 = %0d", op);

        //2. Test SUB (11-5=6)
        a = 4'd11; b = 4'd5; sel = 3'b001; #10;
        assert(op == 6) else $fatal("[ERROR]: Failed Subtraction operation!");
        $display("[PASS] SUB: 11 - 5 = %0d", op);
        
        //3. Test AND (0xC & 0x9 = 0x8)
        a = 4'hC; b = 4'h9; sel = 3'b010; #10;
        assert(op == 4'h8) else $fatal("[ERROR]: Failed bitwise AND operation!");
        $display("[PASS] AND: 0x%h & 0x%h = 0x%h", a, b, op);
        
        //4. Test OR (0xA | 0xC=0xE)
        a = 4'b1010; b = 4'b1100; sel = 3'b011; #10;
        assert(op == 4'b1110) else $fatal("[ERROR]: Failed bitwise OR operation!");
        $display("[PASS] OR: 0x%h | 0x%h = 0x%h", a, b, op);
        
        //5. Test XOR (0xF^0x6=0x9)
        a = 4'hF; b = 4'h6; sel = 3'b100; #10;
        assert(op == 4'h9) else $fatal("[ERROR]: Failed bitwise XOR operation!");
        $display("[PASS] XOR: 0x%h ^ 0x%h = 0x%h", a, b, op);
        
        //6. Test SLL (0b1101 << 2 = 0b0100)
        a = 4'b1101; b = 4'd2; sel = 3'b101; #10;
        assert(op == 4'b0100) else $fatal("[ERROR]: Failed SLL:shift left logical operation!");
        $display("[PASS] SLL: 1101 << 2 = %0b", op);
        
        //7. Test SRL (0b1000 >> 3 = 0b0001)
        a = 4'b1000; b = 4'd3; sel = 3'b110; #10;
        assert(op == 4'b0001) else $fatal("[ERROR]: Failed SRL:shift right logic operation!");
        $display("[PASS] SRL: 1000 >> 1 = %0b", op);
        
        //8. Test SLT (5<7=>1)
        a = 4'd5; b = 4'd7; sel = 3'b111; #10;
        assert(op == 4'd1) else $fatal("[ERROR]: Failed SLT:set less than operation!");
        $display("[PASS] SLT: 5 < 7 => %0d (true)", op);

        //9. Test SLT (11<3=>1)
        a = 4'b1011; b = 4'b0011; sel = 3'b111; #10;
        assert(op == 4'b0000) else $fatal("[ERROR]: Failed SLT:set less than operation!");
        $display("[PASS] SLT: 11 < 3 => %0d (false)", op);

        $display("-----All SystemVerilog ALU Test Pass Successfully!!!-----");
        $finish;
    end

endmodule


`timescale 1ns/1ps

module tb_regfile;

    //Declaring tb signals (;)
    logic clk;             
    logic rst;            //Asynchronous reset
    logic we;             //Write enable
    logic[4:0]  waddr;    //Write address
    logic[31:0] wdata;    //Write data
    logic[4:0] raddr1;    //Read address 1
    logic[4:0] raddr2;    //Read address 2
    logic[31:0] rdata1;  //Read data 1
    logic[31:0] rdata2;   //Read data 2

    //Initiate unit under test
    regfile uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    always #5 clk = ~clk;

    initial begin
        //initialize the signals
        clk = 0;
        rst = 0;
        we = 0;
        waddr = 0;
        wdata = 0;
        raddr1 = 0;
        raddr2 = 0;

        //Setup simulation and vcd waveform tracing
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_regfile);

        $display("======Simulation of 32x32 Register file======");
        //Test 1: Check reset
        $display("---Test 1: Triggering Reset---");
        rst = 1;
        #10;    //wait for 1 clock cycle (5ns low + 5ns high)
        rst = 0;
        #5;
        //verify the registers are cleared to 0
        raddr1 = 5;
        raddr2 = 10;
        #1; //delay for combinational read paths to settle
        assert(rdata1 == 32'b0 && rdata2 == 32'b0) else $fatal("[FAIL]: Registers not cleared on reset");
        $display("[PASS]: Reset cleared register file successfully!");

        //Test 2: Write/Read 
        $display("---Test 2: Writing on register and reading that register---");
        @(posedge clk);
        we = 1;
        waddr = 5'd1;
        wdata = 32'h0AFC1230;

        @(posedge clk);
        we=0;
        raddr1 = 5'b00001;
        #1;

        assert (rdata1 == 32'h0AFC1230 ) 
        else $fatal("[FAIL]: Failed to write or read the data in register");
        $display("[PASS]: Successfully wrote and read x1: 0x%0h", rdata1);

        //Test 3: Write/Read 2 different registers 
        $display("---Test 3: Writing on register and reading using asynchronous different registers---");
        @(posedge clk);
        we = 1;
        waddr = 5'd3;
        wdata = 32'(8'b11111111);       //casting so the verilator adds padding

        @(posedge clk);
        we=0;
        raddr1 = 5'b00001;
        raddr2 = 5'b00011;
        #1;

        assert (rdata1 == 32'h0AFC1230 && rdata2 == 32'h000000FF) 
        else $fatal("[FAIL]: Failed to write or read the data in register");
        $display("[PASS]: Dual read ports verified -> rdata1: 0x%0h | rdata2: 0x%0h", rdata1, rdata2);

        //Test 4: Verify x0 is hardwired to 0
        $display("---Test 4: Verify x0 is hardwired to 0---");
        @(posedge clk);
        we = 1;
        waddr = 5'b0;
        wdata = 32'h568AEB0F;

        @(posedge clk);
        we = 0;
        raddr2 = 5'd0;
        #1;

        assert(rdata2 == 32'b0) else $fatal("[FAIL]: x0 is not hardwired to 0 / 0x was overwritten");
        $display("[PASS]: x0 is hardwired to 0!");

        //Test 5: Overwriting same registers
        $display("---Test 5: Overwriting same registers---");
        @(posedge clk);
        we = 1;
        waddr = 5'b00111;
        wdata = 32'h568AEB0F;

        @(posedge clk);
        waddr = 5'd7;
        wdata = 32'h000F0FFF;

        @(posedge clk);
        we = 0;
        raddr1 = 5'd7;
        #1;

        assert(rdata1 == 32'h000F0FFF) else $fatal("[FAIL]: Register is not Overwritten");
        $display("[PASS]: Previous data overwritten successfully!!");

        //Test 6: Check reset
        $display("---Test 6: Triggering Reset---");
        rst = 1;
        #10;    //wait for 1 clock cycle (5ns low + 5ns high)
        rst = 0;
        #5;
        //verify the registers are cleared to 0
        raddr1 = 7;
        raddr2 = 0;
        #1; //delay for combinational read paths to settle
        assert(rdata1 == 32'b0 && rdata2 == 32'b0) else $fatal("[FAIL]: Registers not cleared on reset");
        $display("[PASS]: Reset cleared register file successfully!");

        $display("=====Testbench Finished=====");
        $finish;

    end
endmodule


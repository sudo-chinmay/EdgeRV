#include <iostream>
#include <memory>
#include <cassert>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vregister_4bit.h"

uint64_t sim_time = 0;

void tick(Vregister_4bit* top, VerilatedVcdC* tfp) {          //Verilog Change Dump (vcd)  | Trace file pointer (tfp)
    top->clk = 0;
    top->eval();
    if (tfp) tfp->dump(sim_time++);

    top->clk = 1;
    top->eval();
    if (tfp) tfp->dump(sim_time++);
}

int main (int argc, char** argv) {

    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vregister_4bit>();

    Verilated::traceEverOn(true);
    auto tfp = std::make_unique<VerilatedVcdC>();
    top->trace(tfp.get(), 99);
    tfp->open("waveform.vcd");

    std::cout << "---Starting 4-Bit Register (Active-High) Testbench---\n";

    //Initial Default
    top->clk = 0;
    top->rst = 0; //Inactive
    top->en = 0;
    top->d_in = 0x0;

    //1. Test Active high Reset Initial state (rst=1)
    top->rst = 1;
    tick(top.get(), tfp.get());
    assert(top->q_out == 0x0 && "ERROR: Active-high Reset failed");      //assert-inbuilt c++ funtion checks condtion inside parenthesis, if "true" normally runs the code, if "false" stops the program and prints the error msg | non-empty text is treated as logic 1 Thus=> &&
    std::cout<<"[PASS] rst=1 -> q_out = "<< (int) top->q_out <<"\n";
    top->rst = 0; //Release reset

    //2. Test Hold State (en=0)
    top->d_in = 0xA;   //4'b1010
    top->en = 0;
    tick(top.get(), tfp.get());
    assert(top->q_out == 0x0 && "ERROR: q_out updated when en=0");
    std::cout<<"[PASS] rst=0 | d_in=0xA | en=0 -> q_out = "<<(int) top->q_out <<"\n";

    //3. Testing Latching data (en=1)
    top->en = 1;
    tick(top.get(), tfp.get());
    assert(top->q_out==0xA && "ERROR: Failed to Latch d_in while en=1");
    std::cout<<"[PASS] rst=0 | d_in=0xA | en=1 -> q_out = "<<(int) top->q_out <<"\n";

    //4. Test Holding State (en=0)
    top->en=0;
    top->d_in=0x5;
    tick(top.get(), tfp.get());
    assert(top->q_out == 0xA && "[ERROR]: Failed to hold previous state at en=0");
    std::cout<<"[PASS] rst=0 | d_in = 0x5 | en=0 -> q_out = "<<(int) top->q_out<<"\n";

    //5. Test Mid operation Reset (rst=1)
    top->rst=1;
    tick(top.get(), tfp.get());
    assert(top->q_out == 0x0 && "[ERROR]: Failed to clear stored at active high reset");
    std::cout<<"[PASS] rst=1 | d_in = 0x5 | en=0 -> q_out = "<<(int) top->q_out<<"\n";
    top->rst=0; //Release Reset

    //6. Test Latch 0x5 (4'b0101)
    top->en=1;
    tick(top.get(), tfp.get());
    assert(top->q_out == 0x5 && "[ERROR]: Failed to Latch or get previous input");
    std::cout<<"[PASS] rst=0 | d_in = 0x5 | en=1 -> q_out ="<<(int) top->q_out<<"\n";

    tfp->close();
    std::cout<<"--- All test passed succesfully!!! ---"<<std::endl;
    return 0;
}
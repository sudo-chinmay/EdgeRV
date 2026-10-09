#include <iostream>
#include <memory>
#include <cassert>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vcounter_4bitUp.h"

uint64_t sim_time = 0;

void tick(Vcounter_4bitUp* top, VerilatedVcdC* tfp) {
    top->clk = 0;
    top->eval();
    if (tfp) tfp->dump(sim_time++);

    top->clk = 1;
    top->eval();
    if (tfp) tfp->dump(sim_time++);
}

int main(int argc, char** argv) {
    
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vcounter_4bitUp>();

    Verilated::traceEverOn(true);
    auto tfp = std::make_unique<VerilatedVcdC>();
    top->trace(tfp.get(), 99);
    tfp->open("waveform.vcd");

    std::cout<<"--Starting 4bit up counter testbench--\n";

    //Intial default
    top->clk = 0;
    top->rst = 0;
    top->en = 0;
    
    //1. Reset check
    top->rst=1;
    tick(top.get(), tfp.get());
    assert(top->q == 0x0 && "[ERROR]: Failed to active-high reset");
    std::cout<<"[PASS] rst=1 | en=0 | q="<<(int) top->q <<"\n";

    //2. Enable disabled
    top->rst=0;     //release reset
    top->en=0;
    tick(top.get(), tfp.get());
    tick(top.get(), tfp.get());
    assert(top->q == 0x0 && "[ERROR]: Failed to active-high reset");
    std::cout<<"[PASS] rst=0 | en=0 | q="<<(int) top->q <<"\n";

    //3. Enable counting (en=1) - Run through 0->15
    top->en=1;
    std::cout<<"--Starting counter--\n";
    for(int i = 1; i<16; i++) {
        tick(top.get(), tfp.get());
        assert(top->q == i && "[ERROR]: Failed to count up");
        std::cout<<"Clock Tick = "<< i <<" -> Counter q = "<<(int) top->q<<"\n";
    }

    //4. Rollover 15->0
    tick(top.get(), tfp.get());
    assert(top->q == 0x0 && "[ERROR]: Failed to Wrap back to 0");
    std::cout<<"[PASS] rst=0 | en=1 | q="<<(int) top->q <<"  --> Wrap back to 0\n";

    //5. Reset in middle of counter
    tick(top.get(), tfp.get());
    tick(top.get(), tfp.get());
    tick(top.get(), tfp.get());
    tick(top.get(), tfp.get());
    top->rst=1;
    tick(top.get(), tfp.get());
    tick(top.get(), tfp.get());
    assert(top->q == 0x0 && "[ERROR]: Failed to Reset in middle of the counter");
    std::cout<<"[PASS] rst=1 | en=1 | q="<<(int) top->q <<"\n";

    tfp->close();
    std::cout<<"---Successfully 4-bit Up-counter! | Saved waveform.vcd file---\n";
    return 0;
}
#include <iostream>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vmux2to1.h" // Verilator auto-generated header

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    // 1. Instantiate the module under test
    auto top = std::make_unique<Vmux2to1>();

    // 2. Setup VCD waveform generation
    Verilated::traceEverOn(true);
    auto trace = std::make_unique<VerilatedVcdC>();
    top->trace(trace.get(), 99);
    trace->open("waveform.vcd");

    vluint64_t main_time = 0; // Timestamp counter

    // Helper lambda function to set inputs, evaluate logic, and trace waveforms
    auto step = [&](uint8_t sel, uint8_t d0, uint8_t d1) {
        top->sel = sel;
        top->d0  = d0;
        top->d1  = d1;

        top->eval();            // Compute new hardware state
        trace->dump(main_time); // Record state in waveform file

        std::cout << "Time=" << main_time 
                  << " | sel=" << (int)top->sel 
                  << " d0=" << (int)top->d0 
                  << " d1=" << (int)top->d1 
                  << " -> y=" << (int)top->y << std::endl;

        main_time += 10; // Advance simulation clock
    };

    std::cout << "--- Starting Simulation ---" << std::endl;

    // Test Case Group 1: sel = 0 (y must follow d0)
    step(0, 0, 1); // Expected y = 0
    step(0, 1, 0); // Expected y = 1

    // Test Case Group 2: sel = 1 (y must follow d1)
    step(1, 0, 0); // Expected y = 0
    step(1, 1, 1); // Expected y = 1
    step(1, 0, 1); // Expected y = 1

    trace->close();
    std::cout << "--- Simulation Completed ---" << std::endl;
    return 0;
}
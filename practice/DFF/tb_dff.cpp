#include <iostream>     //print text to terminal 
#include <memory>       //managing computer memory automatically (eg. Smart pointers - avoid memory leak or prg crash)
#include <verilated.h>  //provided by Verilator for H/w simulation logic inside cpp
#include <verilated_vcd_c.h>
#include "Vdff.h"       //Verilator auto generates this header from DFF.sv (converts your hardware design into a C++ class )
// <> - built-in libraries | "" - project files 


int main(int argc, char**argv) {        //counts text or flags in terminal argc-count, argv-holds text of arg
    //--Initialize verilator context and parameters
    Verilated::commandArgs(argc, argv);     //passes terminal arg to Verilator sim engine to config itself
    auto top = std::make_unique<Vdff>();    //auto-cpp figure-out what type of variable|top-represent H/w chip|Allocate mem, create new instance of DFF chip

    //--- Enable tracing in Verilator
    Verilated::traceEverOn(true);
    auto tfp = std::make_unique<VerilatedVcdC>();
    top->trace(tfp.get(), 99);
    tfp->open("waveform.vcd");
    
    //--Define Sim tracking var
    vluint64_t main_time = 0;       //(V)eri(L)og (U)nsigned (INT)eger(64-bit) | (+only)Counts sim time steps | sim clk step at 0  
    std::cout << "Starting DFF C++ Testbench Simulation..." << std::endl;

    //--Simulation Loop
    //Run for 20 time steps (10 full clk cycles)
    while (main_time<20) {

        //--- Generate Clk signals ---
        //Toggle clk every time step
        //Step 0 = Low, Step 1 = High, Step 2 = Low, Step 3 = High, ...
        top->clk = (main_time % 2 == 1);

        //--- Drive Control and Data Signals ---
        if (main_time < 4) {
            //Actively reset the FF for first_n 2 clk cycles
            top->rst_n = 0;
            top->d = 0;
        } else {
            //Release reset and feed data into input 'd'
            top->rst_n = 1;
            
            if (main_time == 6) {
                top->d = 1;
            } else if (main_time == 8) {
                top->d = 0;
            } else if (main_time > 10 && main_time < 13) {
                top->d = 1;
            } else if (main_time == 14) {
                top->d = 0;
            }
        }

        //--- Evaluate the model ---
        //This calculates what happens in H/w based on current i/ps
        top->eval();        //in-built function of Verilator (run verilog logic math and updates o/p seeing i/p)

        //--- Dump all current signal states into the VCD file at this specific time step ---
        tfp->dump(main_time);

        //--- Monitor and Print o/ps ---
        //Prints status
        std::cout << "[Time " << main_time << "]"
                    << "rst_n=" << (int)top->rst_n             //typecast : (int)
                    << " | Input d=" << (int)top->d        //Verilog : 1-bit stored  as char  
                    << " --> Output q=" << (int)top->q     //w/o typr casting --> weired symbol or blank
                    << std::endl;
        
        //Increment time step
        main_time++;
    } 

    tfp->close();

    std::cout << "Simulation Finished Successfully !!! Waveform in stored in waveform.vcd" << std::endl;
    return 0;
}

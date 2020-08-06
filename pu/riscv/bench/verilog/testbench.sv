////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              PU RISCV / OR1K / MSP430                                      //
//              Universal Verification Methodology                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2020-2021 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

//Include UVM files
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;

//Include common files
`include "processor_sequence.sv"
`include "processor_driver.sv"
`include "processor_monitor.sv"
`include "processor_scoreboard.sv"
`include "processor_subscriber.sv"
`include "processor_agent.sv"
`include "processor_env.sv"
`include "processor_test.sv"

module top;  
  bit clk;
  
  //clock generation
  always #5 clk = ~clk;
  
  initial begin
    clk = 0;
  end

  // Instantiate the interface
  processor_interface processor_if(clk);
  // Instantiate dut

  Main_Processor dut(
    .inst_in     (processor_if.inst_in),
    .clk         (processor_if.clk),
    .pc_out      (processor_if.pc),
    .inst_out_tb (processor_if.inst_out),
    .wD_rf       (processor_if.reg_data),
    .w_en        (processor_if.reg_en),
    .aD_rf       (processor_if.reg_add),
    .mem_data_tb (processor_if.mem_data),
    .mem_en_tb   (processor_if.mem_en),
    .mem_add_tb  (processor_if.mem_add) 
  );

  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual processor_interface)::set(null, "*", "processor_vif", processor_if);
    
    // Start the test
    run_test();
  end

  initial begin
    $vcdpluson();
  end
endmodule

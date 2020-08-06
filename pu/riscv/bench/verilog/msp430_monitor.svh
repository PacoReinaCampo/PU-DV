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

class processor_monitor extends uvm_monitor;
  // register the monitor in the UVM factory
  `uvm_component_utils(processor_monitor)
  int count;

  // Declare virtual interface
  virtual processor_interface processor_vif;

  // Analysis port to broadcast results to scoreboard 
  uvm_analysis_port #(processor_transaction) Mon2Sb_port; 

  // Analysis port to broadcast results to subscriber 
  uvm_analysis_port #(processor_transaction) aport;     
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual processor_interface)::get(this, "", "processor_vif", processor_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
    Mon2Sb_port = new("Mon2Sb",this);
    aport = new("aport",this);
  endfunction

  task run_phase(uvm_phase phase);
    processor_transaction pros_trans;
    pros_trans = new ("trans");
    count = 0;
    fork
      forever begin
        @(processor_vif.monitor_if_mp.monitor_cb.inst_out) begin
          if(count<17) begin
            count++;
          end
          else begin
            // Set transaction from interface data
            pros_trans.pc = processor_vif.monitor_if_mp.monitor_cb.pc;
            pros_trans.inst_out = processor_vif.monitor_if_mp.monitor_cb.inst_out;
            pros_trans.reg_data = processor_vif.monitor_if_mp.monitor_cb.reg_data;
            pros_trans.reg_en = processor_vif.monitor_if_mp.monitor_cb.reg_en;
            pros_trans.reg_add = processor_vif.monitor_if_mp.monitor_cb.reg_add;
            pros_trans.mem_data = processor_vif.monitor_if_mp.monitor_cb.mem_data;
            pros_trans.mem_en = processor_vif.monitor_if_mp.monitor_cb.mem_en;						
            pros_trans.mem_add = processor_vif.monitor_if_mp.monitor_cb.mem_add;			
            // Send transaction to Scoreboard
            Mon2Sb_port.write(pros_trans);
            // Send transaction to subscriber		
            aport.write(pros_trans);	   
            count = 0;             
          end
        end
      end
    join
  endtask : run_phase
endclass : processor_monitor

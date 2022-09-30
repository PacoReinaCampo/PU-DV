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

class riscv_monitor extends uvm_monitor;
  // register the monitor in the UVM factory
  `uvm_component_utils(riscv_monitor)

  int count;

  // Declare virtual interface
  virtual riscv_interface riscv_vif;

  // Analysis port to broadcast results to scoreboard 
  uvm_analysis_port #(riscv_transaction) monitor2scoreboard_port;

  // Analysis port to broadcast results to subscriber 
  uvm_analysis_port #(riscv_transaction) aport;
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual riscv_interface)::get(this, "", "riscv_vif", riscv_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end

    monitor2scoreboard_port = new("monitor2scoreboard",this);
    aport = new("aport",this);
  endfunction

  task run_phase(uvm_phase phase);
    riscv_transaction pu_transaction;
    pu_transaction = new ("transaction");
    count = 0;
    fork
      forever begin
        @(riscv_vif.monitor_if_mp.monitor_cb.ins_HRDATA) begin
          if(count<17) begin
            count++;
          end
          else begin
            pu_transaction.pma_cfg_i     = riscv_vif.monitor_if_mp.monitor_cb.pma_cfg;
            pu_transaction.pma_adr_i     = riscv_vif.monitor_if_mp.monitor_cb.pma_adr;

            // AHB3 instruction
            pu_transaction.ins_HSEL      = riscv_vif.monitor_if_mp.monitor_cb.ins_HSEL;
            pu_transaction.ins_HADDR     = riscv_vif.monitor_if_mp.monitor_cb.ins_HADDR;
            pu_transaction.ins_HWDATA    = riscv_vif.monitor_if_mp.monitor_cb.ins_HWDATA;
            pu_transaction.ins_HRDATA    = riscv_vif.monitor_if_mp.monitor_cb.ins_HRDATA;
            pu_transaction.ins_HWRITE    = riscv_vif.monitor_if_mp.monitor_cb.ins_HWRITE;
            pu_transaction.ins_HSIZE     = riscv_vif.monitor_if_mp.monitor_cb.ins_HSIZE;
            pu_transaction.ins_HBURST    = riscv_vif.monitor_if_mp.monitor_cb.ins_HBURST;
            pu_transaction.ins_HPROT     = riscv_vif.monitor_if_mp.monitor_cb.ins_HPROT;
            pu_transaction.ins_HTRANS    = riscv_vif.monitor_if_mp.monitor_cb.ins_HTRANS;
            pu_transaction.ins_HMASTLOCK = riscv_vif.monitor_if_mp.monitor_cb.ins_HMASTLOCK;
            pu_transaction.ins_HREADY    = riscv_vif.monitor_if_mp.monitor_cb.ins_HREADY;
            pu_transaction.ins_HRESP     = riscv_vif.monitor_if_mp.monitor_cb.ins_HRESP;

            // AHB3 data
            pu_transaction.dat_HSEL      = riscv_vif.monitor_if_mp.monitor_cb.dat_HSEL;
            pu_transaction.dat_HADDR     = riscv_vif.monitor_if_mp.monitor_cb.dat_HADDR;
            pu_transaction.dat_HWDATA    = riscv_vif.monitor_if_mp.monitor_cb.dat_HWDATA;
            pu_transaction.dat_HRDATA    = riscv_vif.monitor_if_mp.monitor_cb.dat_HRDATA;
            pu_transaction.dat_HWRITE    = riscv_vif.monitor_if_mp.monitor_cb.dat_HWRITE;
            pu_transaction.dat_HSIZE     = riscv_vif.monitor_if_mp.monitor_cb.dat_HSIZE;
            pu_transaction.dat_HBURST    = riscv_vif.monitor_if_mp.monitor_cb.dat_HBURST;
            pu_transaction.dat_HPROT     = riscv_vif.monitor_if_mp.monitor_cb.dat_HPROT;
            pu_transaction.dat_HTRANS    = riscv_vif.monitor_if_mp.monitor_cb.dat_HTRANS;
            pu_transaction.dat_HMASTLOCK = riscv_vif.monitor_if_mp.monitor_cb.dat_HMASTLOCK;
            pu_transaction.dat_HREADY    = riscv_vif.monitor_if_mp.monitor_cb.dat_HREADY;
            pu_transaction.dat_HRESP     = riscv_vif.monitor_if_mp.monitor_cb.dat_HRESP;

            // Interrupts
            pu_transaction.ext_nmi       = riscv_vif.monitor_if_mp.monitor_cb.ext_nmi;
            pu_transaction.ext_tint      = riscv_vif.monitor_if_mp.monitor_cb.ext_tint;
            pu_transaction.ext_sint      = riscv_vif.monitor_if_mp.monitor_cb.ext_sint;
            pu_transaction.ext_int       = riscv_vif.monitor_if_mp.monitor_cb.ext_int;

            // Debug Interface
            pu_transaction.dbg_stall     = riscv_vif.monitor_if_mp.monitor_cb.dbg_stall;
            pu_transaction.dbg_strb      = riscv_vif.monitor_if_mp.monitor_cb.dbg_strb;
            pu_transaction.dbg_we        = riscv_vif.monitor_if_mp.monitor_cb.dbg_we;
            pu_transaction.dbg_addr      = riscv_vif.monitor_if_mp.monitor_cb.dbg_addr;
            pu_transaction.dbg_dati      = riscv_vif.monitor_if_mp.monitor_cb.dbg_dati;
            pu_transaction.dbg_dato      = riscv_vif.monitor_if_mp.monitor_cb.dbg_dato;
            pu_transaction.dbg_ack       = riscv_vif.monitor_if_mp.monitor_cb.dbg_ack;
            pu_transaction.dbg_bp        = riscv_vif.monitor_if_mp.monitor_cb.dbg_bp;

            // Send transaction to Scoreboard
            monitor2scoreboard_port.write(pu_transaction);

            // Send transaction to subscriber
            aport.write(pu_transaction);
            count = 0;
          end
        end
      end
    join
  endtask : run_phase
endclass : riscv_monitor

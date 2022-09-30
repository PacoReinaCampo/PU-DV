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

class msp430_monitor extends uvm_monitor;
  // register the monitor in the UVM factory
  `uvm_component_utils(msp430_monitor)

  int count;

  // Declare virtual interface
  virtual msp430_interface msp430_vif;

  // Analysis port to broadcast results to scoreboard 
  uvm_analysis_port #(msp430_transaction) monitor2scoreboard_port;

  // Analysis port to broadcast results to subscriber 
  uvm_analysis_port #(msp430_transaction) aport;
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual msp430_interface)::get(this, "", "msp430_vif", msp430_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end

    monitor2scoreboard_port = new("monitor2scoreboard",this);
    aport = new("aport",this);
  endfunction

  task run_phase(uvm_phase phase);
    msp430_transaction pu_transaction;
    pu_transaction = new ("transaction");
    count = 0;
    fork
      forever begin
        @(msp430_vif.monitor_if_mp.monitor_cb.dmem_dout) begin
          if(count<17) begin
            count++;
          end
          else begin
            pu_transaction.irq_detect = msp430_vif.monitor_if_mp.monitor_cb.irq_detect;
            pu_transaction.nmi_detect = msp430_vif.monitor_if_mp.monitor_cb.nmi_detect;
 
            pu_transaction.i_state = msp430_vif.monitor_if_mp.monitor_cb.i_state;
            pu_transaction.e_state = msp430_vif.monitor_if_mp.monitor_cb.e_state;
            pu_transaction.decode  = msp430_vif.monitor_if_mp.monitor_cb.decode;
            pu_transaction.ir      = msp430_vif.monitor_if_mp.monitor_cb.ir;
            pu_transaction.irq_num = msp430_vif.monitor_if_mp.monitor_cb.irq_num;
            pu_transaction.pc      = msp430_vif.monitor_if_mp.monitor_cb.pc;
 
            pu_transaction.nodiv_smclk = msp430_vif.monitor_if_mp.monitor_cb.nodiv_smclk;
 
            pu_transaction.aclk            = msp430_vif.monitor_if_mp.monitor_cb.aclk;
            pu_transaction.aclk_en         = msp430_vif.monitor_if_mp.monitor_cb.aclk_en;
            pu_transaction.dbg_freeze      = msp430_vif.monitor_if_mp.monitor_cb.dbg_freeze;
            pu_transaction.dbg_i2c_sda_out = msp430_vif.monitor_if_mp.monitor_cb.dbg_i2c_sda_out;
            pu_transaction.dbg_uart_txd    = msp430_vif.monitor_if_mp.monitor_cb.dbg_uart_txd;
            pu_transaction.dco_enable      = msp430_vif.monitor_if_mp.monitor_cb.dco_enable;
            pu_transaction.dco_wkup        = msp430_vif.monitor_if_mp.monitor_cb.dco_wkup;
            pu_transaction.irq_acc         = msp430_vif.monitor_if_mp.monitor_cb.irq_acc;
            pu_transaction.lfxt_enable     = msp430_vif.monitor_if_mp.monitor_cb.lfxt_enable;
            pu_transaction.lfxt_wkup       = msp430_vif.monitor_if_mp.monitor_cb.lfxt_wkup;
            pu_transaction.mclk            = msp430_vif.monitor_if_mp.monitor_cb.mclk;
            pu_transaction.puc_rst         = msp430_vif.monitor_if_mp.monitor_cb.puc_rst;
            pu_transaction.smclk           = msp430_vif.monitor_if_mp.monitor_cb.smclk;
            pu_transaction.smclk_en        = msp430_vif.monitor_if_mp.monitor_cb.smclk_en;
 
            pu_transaction.cpu_en            = msp430_vif.monitor_if_mp.monitor_cb.cpu_en;
            pu_transaction.dbg_en            = msp430_vif.monitor_if_mp.monitor_cb.dbg_en;
            pu_transaction.dbg_i2c_addr      = msp430_vif.monitor_if_mp.monitor_cb.dbg_i2c_addr;
            pu_transaction.dbg_i2c_broadcast = msp430_vif.monitor_if_mp.monitor_cb.dbg_i2c_broadcast;
            pu_transaction.dbg_i2c_scl       = msp430_vif.monitor_if_mp.monitor_cb.dbg_i2c_scl;
            pu_transaction.dbg_i2c_sda_in    = msp430_vif.monitor_if_mp.monitor_cb.dbg_i2c_sda_in;
            pu_transaction.dbg_uart_rxd      = msp430_vif.monitor_if_mp.monitor_cb.dbg_uart_rxd;
            pu_transaction.dco_clk           = msp430_vif.monitor_if_mp.monitor_cb.dco_clk;
            pu_transaction.irq               = msp430_vif.monitor_if_mp.monitor_cb.irq;
            pu_transaction.lfxt_clk          = msp430_vif.monitor_if_mp.monitor_cb.lfxt_clk;
            pu_transaction.nmi               = msp430_vif.monitor_if_mp.monitor_cb.nmi;
            pu_transaction.reset_n           = msp430_vif.monitor_if_mp.monitor_cb.reset_n;
            pu_transaction.scan_enable       = msp430_vif.monitor_if_mp.monitor_cb.scan_enable;
            pu_transaction.scan_mode         = msp430_vif.monitor_if_mp.monitor_cb.scan_mode;
            pu_transaction.wkup              = msp430_vif.monitor_if_mp.monitor_cb.wkup;
 
            pu_transaction.pmem_addr = msp430_vif.monitor_if_mp.monitor_cb.pmem_addr;
            pu_transaction.pmem_cen  = msp430_vif.monitor_if_mp.monitor_cb.pmem_cen;
            pu_transaction.pmem_din  = msp430_vif.monitor_if_mp.monitor_cb.pmem_din;
            pu_transaction.pmem_wen  = msp430_vif.monitor_if_mp.monitor_cb.pmem_wen;
            pu_transaction.pmem_dout = msp430_vif.monitor_if_mp.monitor_cb.pmem_dout;
 
 
            pu_transaction.dmem_addr = msp430_vif.monitor_if_mp.monitor_cb.dmem_addr;
            pu_transaction.dmem_cen  = msp430_vif.monitor_if_mp.monitor_cb.dmem_cen;
            pu_transaction.dmem_din  = msp430_vif.monitor_if_mp.monitor_cb.dmem_din;
            pu_transaction.dmem_wen  = msp430_vif.monitor_if_mp.monitor_cb.dmem_wen;
            pu_transaction.dmem_dout = msp430_vif.monitor_if_mp.monitor_cb.dmem_dout;
 
            pu_transaction.per_addr = msp430_vif.monitor_if_mp.monitor_cb.per_addr;
            pu_transaction.per_din  = msp430_vif.monitor_if_mp.monitor_cb.per_din;
            pu_transaction.per_we   = msp430_vif.monitor_if_mp.monitor_cb.per_we;
            pu_transaction.per_en   = msp430_vif.monitor_if_mp.monitor_cb.per_en;
            pu_transaction.per_dout = msp430_vif.monitor_if_mp.monitor_cb.per_dout;
 
            pu_transaction.r0  = msp430_vif.monitor_if_mp.monitor_cb.r0;
            pu_transaction.r1  = msp430_vif.monitor_if_mp.monitor_cb.r1;
            pu_transaction.r2  = msp430_vif.monitor_if_mp.monitor_cb.r2;
            pu_transaction.r3  = msp430_vif.monitor_if_mp.monitor_cb.r3;
            pu_transaction.r4  = msp430_vif.monitor_if_mp.monitor_cb.r4;
            pu_transaction.r5  = msp430_vif.monitor_if_mp.monitor_cb.r5;
            pu_transaction.r6  = msp430_vif.monitor_if_mp.monitor_cb.r6;
            pu_transaction.r7  = msp430_vif.monitor_if_mp.monitor_cb.r7;
            pu_transaction.r8  = msp430_vif.monitor_if_mp.monitor_cb.r8;
            pu_transaction.r9  = msp430_vif.monitor_if_mp.monitor_cb.r9;
            pu_transaction.r10 = msp430_vif.monitor_if_mp.monitor_cb.r10;
            pu_transaction.r11 = msp430_vif.monitor_if_mp.monitor_cb.r11;
            pu_transaction.r12 = msp430_vif.monitor_if_mp.monitor_cb.r12;
            pu_transaction.r13 = msp430_vif.monitor_if_mp.monitor_cb.r13;
            pu_transaction.r14 = msp430_vif.monitor_if_mp.monitor_cb.r14;
            pu_transaction.r15 = msp430_vif.monitor_if_mp.monitor_cb.r15;

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
endclass : msp430_monitor

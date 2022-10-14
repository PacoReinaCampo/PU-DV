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

class or1k_monitor extends uvm_monitor;
  // register the monitor in the UVM factory
  `uvm_component_utils(or1k_monitor)

  int count;

  // Declare virtual interface
  virtual or1k_interface or1k_vif;

  // Analysis port to broadcast results to scoreboard 
  uvm_analysis_port #(or1k_transaction) monitor2scoreboard_port;

  // Analysis port to broadcast results to subscriber 
  uvm_analysis_port #(or1k_transaction) aport;
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual or1k_interface)::get(this, "", "or1k_vif", or1k_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end

    monitor2scoreboard_port = new("monitor2scoreboard",this);
    aport = new("aport",this);
  endfunction

  task run_phase(uvm_phase phase);
    or1k_transaction pu_transaction;
    pu_transaction = new ("transaction");
    count = 0;
    fork
      forever begin
        @(or1k_vif.monitor_if_mp.monitor_cb.inst_out) begin
          if(count<17) begin
            count++;
          end
          else begin
            // Wishbone Instruction
            pu_transaction.iwbm_adr_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_adr_o;
            pu_transaction.iwbm_stb_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_stb_o;
            pu_transaction.iwbm_cyc_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_cyc_o;
            pu_transaction.iwbm_sel_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_sel_o;
            pu_transaction.iwbm_we_o    = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_we_o;
            pu_transaction.iwbm_cti_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_cti_o;
            pu_transaction.iwbm_bte_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_bte_o;
            pu_transaction.iwbm_dat_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_dat_o;
            pu_transaction.iwbm_err_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_err_i;
            pu_transaction.iwbm_ack_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_ack_i;
            pu_transaction.iwbm_dat_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_dat_i;
            pu_transaction.iwbm_rty_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.iwbm_rty_i;

            // Wishbone Data
            pu_transaction.dwbm_adr_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_adr_o;
            pu_transaction.dwbm_stb_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_stb_o;
            pu_transaction.dwbm_cyc_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_cyc_o;
            pu_transaction.dwbm_sel_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_sel_o;
            pu_transaction.dwbm_we_o    = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_we_o;
            pu_transaction.dwbm_cti_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_cti_o;
            pu_transaction.dwbm_bte_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_bte_o;
            pu_transaction.dwbm_dat_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_dat_o;
            pu_transaction.dwbm_err_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_err_i;
            pu_transaction.dwbm_ack_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_ack_i;
            pu_transaction.dwbm_dat_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_dat_i;
            pu_transaction.dwbm_rty_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.dwbm_rty_i;

            pu_transaction.irq_i        = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.irq;

            // Debug interface
            pu_transaction.du_addr_i    = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_adr_i;
            pu_transaction.du_stb_i     = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_stb_i;
            pu_transaction.du_dat_i     = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_dat_i;
            pu_transaction.du_we_i      = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_we_i;
            pu_transaction.du_dat_o     = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_dat_o;
            pu_transaction.du_ack_o     = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_ack_o;

            // Stall control from debug interface
            pu_transaction.du_stall_i   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_stall_i;
            pu_transaction.du_stall_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.du_stall_o;

            pu_transaction.traceport_exec_valid_o    = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_valid_o;
            pu_transaction.traceport_exec_pc_o       = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_pc_o;
            pu_transaction.traceport_exec_jb_o       = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_jb_o;
            pu_transaction.traceport_exec_jal_o      = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_jal_o;
            pu_transaction.traceport_exec_jr_o       = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_jr_o;
            pu_transaction.traceport_exec_jbtarget_o = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_jbtarget_o;
            pu_transaction.traceport_exec_insn_o     = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_insn_o;
            pu_transaction.traceport_exec_wbdata_o   = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_wbdata_o;
            pu_transaction.traceport_exec_wbreg_o    = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_wbreg_o;
            pu_transaction.traceport_exec_wben_o     = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.traceport_exec_wben_o;

            // The multicore core identifier
            pu_transaction.multicore_coreid_i = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.multicore_coreid_i;

            // The number of cores
            pu_transaction.multicore_numcores_i = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.multicore_numcores_i;

            pu_transaction.snoop_adr_i = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.snoop_adr_i;
            pu_transaction.snoop_en_i  = or1k_vif.monitor_if_mp.monitor_cb.or1k_if.snoop_en_i;

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
endclass : or1k_monitor

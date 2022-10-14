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
`include "or1k_sequence.svh"
`include "or1k_driver.svh"
`include "or1k_monitor.svh"
`include "or1k_scoreboard.svh"
`include "or1k_subscriber.svh"
`include "or1k_agent.svh"
`include "or1k_env.svh"
`include "or1k_test.svh"

`include "or1k_defines.sv"

module test;

  parameter OPTION_OPERAND_WIDTH = 32;

  parameter OPTION_CPU0 = "CAPPUCCINO";

  parameter FEATURE_DATACACHE          = "NONE";
  parameter OPTION_DCACHE_BLOCK_WIDTH  = 5;
  parameter OPTION_DCACHE_SET_WIDTH    = 9;
  parameter OPTION_DCACHE_WAYS         = 2;
  parameter OPTION_DCACHE_LIMIT_WIDTH  = 32;
  parameter OPTION_DCACHE_SNOOP        = "NONE";
  parameter FEATURE_DMMU               = "NONE";
  parameter FEATURE_DMMU_HW_TLB_RELOAD = "NONE";
  parameter OPTION_DMMU_SET_WIDTH      = 6;
  parameter OPTION_DMMU_WAYS           = 1;
  parameter FEATURE_INSTRUCTIONCACHE   = "NONE";
  parameter OPTION_ICACHE_BLOCK_WIDTH  = 5;
  parameter OPTION_ICACHE_SET_WIDTH    = 9;
  parameter OPTION_ICACHE_WAYS         = 2;
  parameter OPTION_ICACHE_LIMIT_WIDTH  = 32;
  parameter FEATURE_IMMU               = "NONE";
  parameter FEATURE_IMMU_HW_TLB_RELOAD = "NONE";
  parameter OPTION_IMMU_SET_WIDTH      = 6;
  parameter OPTION_IMMU_WAYS           = 1;
  parameter FEATURE_TIMER              = "ENABLED";
  parameter FEATURE_DEBUGUNIT          = "NONE";
  parameter FEATURE_PERFCOUNTERS       = "NONE";
  parameter OPTION_PERFCOUNTERS_NUM    = 0;
  parameter FEATURE_MAC                = "NONE";

  parameter FEATURE_SYSCALL = "ENABLED";
  parameter FEATURE_TRAP    = "ENABLED";
  parameter FEATURE_RANGE   = "ENABLED";

  parameter FEATURE_PIC          = "ENABLED";
  parameter OPTION_PIC_TRIGGER   = "LEVEL";
  parameter OPTION_PIC_NMI_WIDTH = 0;

  parameter FEATURE_DSX        = "ENABLED";
  parameter FEATURE_OVERFLOW   = "ENABLED";
  parameter FEATURE_CARRY_FLAG = "ENABLED";

  parameter FEATURE_FASTCONTEXTS     = "NONE";
  parameter OPTION_RF_CLEAR_ON_INIT  = 0;
  parameter OPTION_RF_NUM_SHADOW_GPR = 0;
  parameter OPTION_RF_ADDR_WIDTH     = 5;
  parameter OPTION_RF_WORDS          = 32;

  parameter OPTION_RESET_PC = {{(OPTION_OPERAND_WIDTH-13){1'b0}}, `OR1K_RESET_VECTOR, 8'd0};

  parameter FEATURE_MULTIPLIER = "THREESTAGE";
  parameter FEATURE_DIVIDER    = "SERIAL";

  parameter FEATURE_ADDC   = "ENABLED";
  parameter FEATURE_SRA    = "ENABLED";
  parameter FEATURE_ROR    = "NONE";
  parameter FEATURE_EXT    = "NONE";
  parameter FEATURE_CMOV   = "ENABLED";
  parameter FEATURE_FFL1   = "ENABLED";
  parameter FEATURE_ATOMIC = "ENABLED";

  parameter FEATURE_CUST1 = "NONE";
  parameter FEATURE_CUST2 = "NONE";
  parameter FEATURE_CUST3 = "NONE";
  parameter FEATURE_CUST4 = "NONE";
  parameter FEATURE_CUST5 = "NONE";
  parameter FEATURE_CUST6 = "NONE";
  parameter FEATURE_CUST7 = "NONE";
  parameter FEATURE_CUST8 = "NONE";

  parameter FEATURE_FPU          = "NONE";
  parameter OPTION_FTOI_ROUNDING = "CPP";

  parameter OPTION_SHIFTER = "BARREL";

  parameter FEATURE_STORE_BUFFER            = "ENABLED";
  parameter OPTION_STORE_BUFFER_DEPTH_WIDTH = 8;

  parameter FEATURE_MULTICORE = "NONE";

  parameter FEATURE_TRACEPORT_EXEC   = "NONE";
  parameter FEATURE_BRANCH_PREDICTOR = "SIMPLE";

  parameter BUS_IF_TYPE = "WISHBONE32";

  parameter IBUS_WB_TYPE = "B3_READ_BURSTING";
  parameter DBUS_WB_TYPE = "CLASSIC";

  // Instantiate interface
  or1k_interface or1k_if();

  // Instantiate dut
  or1k_core #(
    .FEATURE_DEBUGUNIT         ("ENABLED"),
    .FEATURE_CMOV              ("ENABLED"),
    .FEATURE_INSTRUCTIONCACHE  ("ENABLED"),
    .OPTION_ICACHE_BLOCK_WIDTH (5),
    .OPTION_ICACHE_SET_WIDTH   (8),
    .OPTION_ICACHE_WAYS        (2),
    .OPTION_ICACHE_LIMIT_WIDTH (32),
    .FEATURE_IMMU              ("ENABLED"),
    .FEATURE_DATACACHE         ("ENABLED"),
    .OPTION_DCACHE_BLOCK_WIDTH (5),
    .OPTION_DCACHE_SET_WIDTH   (8),
    .OPTION_DCACHE_WAYS        (2),
    .OPTION_DCACHE_LIMIT_WIDTH (31),
    .FEATURE_DMMU              ("ENABLED"),
    .OPTION_RF_NUM_SHADOW_GPR  (1),
    .IBUS_WB_TYPE              ("B3_REGISTERED_FEEDBACK"),
    .DBUS_WB_TYPE              ("B3_REGISTERED_FEEDBACK"),
    .OPTION_CPU0               ("CAPPUCCINO"),
    .OPTION_RESET_PC           (32'h00000100)
  )
  dut (
    .clk          ( or1k_if.clk ),
    .rst          ( or1k_if.rst ),

    // Wishbone Instruction
    .iwbm_adr_o   ( or1k_if.iwbm_adr_o ),
    .iwbm_stb_o   ( or1k_if.iwbm_stb_o ),
    .iwbm_cyc_o   ( or1k_if.iwbm_cyc_o ),
    .iwbm_sel_o   ( or1k_if.iwbm_sel_o ),
    .iwbm_we_o    ( or1k_if.iwbm_we_o  ),
    .iwbm_cti_o   ( or1k_if.iwbm_cti_o ),
    .iwbm_bte_o   ( or1k_if.iwbm_bte_o ),
    .iwbm_dat_o   ( or1k_if.iwbm_dat_o ),
    .iwbm_err_i   ( or1k_if.iwbm_err_i ),
    .iwbm_ack_i   ( or1k_if.iwbm_ack_i ),
    .iwbm_dat_i   ( or1k_if.iwbm_dat_i ),
    .iwbm_rty_i   ( or1k_if.iwbm_rty_i ),

    // Wishbone Data
    .dwbm_adr_o   ( or1k_if.dwbm_adr_o ),
    .dwbm_stb_o   ( or1k_if.dwbm_stb_o ),
    .dwbm_cyc_o   ( or1k_if.dwbm_cyc_o ),
    .dwbm_sel_o   ( or1k_if.dwbm_sel_o ),
    .dwbm_we_o    ( or1k_if.dwbm_we_o  ),
    .dwbm_cti_o   ( or1k_if.dwbm_cti_o ),
    .dwbm_bte_o   ( or1k_if.dwbm_bte_o ),
    .dwbm_dat_o   ( or1k_if.dwbm_dat_o ),
    .dwbm_err_i   ( or1k_if.dwbm_err_i ),
    .dwbm_ack_i   ( or1k_if.dwbm_ack_i ),
    .dwbm_dat_i   ( or1k_if.dwbm_dat_i ),
    .dwbm_rty_i   ( or1k_if.dwbm_rty_i ),

    .irq_i        ( or1k_if.irq ),

    // Debug interface
    .du_addr_i    ( or1k_if.du_adr_i ),
    .du_stb_i     ( or1k_if.du_stb_i ),
    .du_dat_i     ( or1k_if.du_dat_i ),
    .du_we_i      ( or1k_if.du_we_i  ),
    .du_dat_o     ( or1k_if.du_dat_o ),
    .du_ack_o     ( or1k_if.du_ack_o ),

    // Stall control from debug interface
    .du_stall_i   ( or1k_if.du_stall_i ),
    .du_stall_o   ( or1k_if.du_stall_o ),

    .traceport_exec_valid_o    ( or1k_if.traceport_exec_valid_o    ),
    .traceport_exec_pc_o       ( or1k_if.traceport_exec_pc_o       ),
    .traceport_exec_jb_o       ( or1k_if.traceport_exec_jb_o       ),
    .traceport_exec_jal_o      ( or1k_if.traceport_exec_jal_o      ),
    .traceport_exec_jr_o       ( or1k_if.traceport_exec_jr_o       ),
    .traceport_exec_jbtarget_o ( or1k_if.traceport_exec_jbtarget_o ),
    .traceport_exec_insn_o     ( or1k_if.traceport_exec_insn_o     ),
    .traceport_exec_wbdata_o   ( or1k_if.traceport_exec_wbdata_o   ),
    .traceport_exec_wbreg_o    ( or1k_if.traceport_exec_wbreg_o    ),
    .traceport_exec_wben_o     ( or1k_if.traceport_exec_wben_o     ),

    // The multicore core identifier
    .multicore_coreid_i ( or1k_if.multicore_coreid_i ),

    // The number of cores
    .multicore_numcores_i ( or1k_if.multicore_numcores_i ),

    .snoop_adr_i ( or1k_if.snoop_adr_i ),
    .snoop_en_i  ( or1k_if.snoop_en_i  )
  );
  //Clock generation
  always #5 or1k_if.clk = ~or1k_if.clk;
  
  initial begin
    or1k_if.clk = 0;
  end

  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual or1k_interface)::set(null, "*", "or1k_vif", or1k_if);
    
    // Start the test
    run_test();
  end

  initial begin
    $vcdpluson();
  end
endmodule

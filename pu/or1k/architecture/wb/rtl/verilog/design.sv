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

`include "or1k_defines.sv"

interface or1k_interface #(
  parameter OPTION_OPERAND_WIDTH = 32,

  parameter OPTION_CPU0 = "CAPPUCCINO",

  parameter FEATURE_DATACACHE          = "NONE",
  parameter OPTION_DCACHE_BLOCK_WIDTH  = 5,
  parameter OPTION_DCACHE_SET_WIDTH    = 9,
  parameter OPTION_DCACHE_WAYS         = 2,
  parameter OPTION_DCACHE_LIMIT_WIDTH  = 32,
  parameter OPTION_DCACHE_SNOOP        = "NONE",
  parameter FEATURE_DMMU               = "NONE",
  parameter FEATURE_DMMU_HW_TLB_RELOAD = "NONE",
  parameter OPTION_DMMU_SET_WIDTH      = 6,
  parameter OPTION_DMMU_WAYS           = 1,
  parameter FEATURE_INSTRUCTIONCACHE   = "NONE",
  parameter OPTION_ICACHE_BLOCK_WIDTH  = 5,
  parameter OPTION_ICACHE_SET_WIDTH    = 9,
  parameter OPTION_ICACHE_WAYS         = 2,
  parameter OPTION_ICACHE_LIMIT_WIDTH  = 32,
  parameter FEATURE_IMMU               = "NONE",
  parameter FEATURE_IMMU_HW_TLB_RELOAD = "NONE",
  parameter OPTION_IMMU_SET_WIDTH      = 6,
  parameter OPTION_IMMU_WAYS           = 1,
  parameter FEATURE_TIMER              = "ENABLED",
  parameter FEATURE_DEBUGUNIT          = "NONE",
  parameter FEATURE_PERFCOUNTERS       = "NONE",
  parameter OPTION_PERFCOUNTERS_NUM    = 0,
  parameter FEATURE_MAC                = "NONE",

  parameter FEATURE_SYSCALL = "ENABLED",
  parameter FEATURE_TRAP    = "ENABLED",
  parameter FEATURE_RANGE   = "ENABLED",

  parameter FEATURE_PIC          = "ENABLED",
  parameter OPTION_PIC_TRIGGER   = "LEVEL",
  parameter OPTION_PIC_NMI_WIDTH = 0,

  parameter FEATURE_DSX        = "ENABLED",
  parameter FEATURE_OVERFLOW   = "ENABLED",
  parameter FEATURE_CARRY_FLAG = "ENABLED",

  parameter FEATURE_FASTCONTEXTS     = "NONE",
  parameter OPTION_RF_CLEAR_ON_INIT  = 0,
  parameter OPTION_RF_NUM_SHADOW_GPR = 0,
  parameter OPTION_RF_ADDR_WIDTH     = 5,
  parameter OPTION_RF_WORDS          = 32,

  parameter OPTION_RESET_PC = {{(OPTION_OPERAND_WIDTH-13){1'b0}}, `OR1K_RESET_VECTOR, 8'd0},

  parameter FEATURE_MULTIPLIER = "THREESTAGE",
  parameter FEATURE_DIVIDER    = "SERIAL",

  parameter FEATURE_ADDC   = "ENABLED",
  parameter FEATURE_SRA    = "ENABLED",
  parameter FEATURE_ROR    = "NONE",
  parameter FEATURE_EXT    = "NONE",
  parameter FEATURE_CMOV   = "ENABLED",
  parameter FEATURE_FFL1   = "ENABLED",
  parameter FEATURE_ATOMIC = "ENABLED",

  parameter FEATURE_CUST1 = "NONE",
  parameter FEATURE_CUST2 = "NONE",
  parameter FEATURE_CUST3 = "NONE",
  parameter FEATURE_CUST4 = "NONE",
  parameter FEATURE_CUST5 = "NONE",
  parameter FEATURE_CUST6 = "NONE",
  parameter FEATURE_CUST7 = "NONE",
  parameter FEATURE_CUST8 = "NONE",

  parameter FEATURE_FPU          = "NONE",
  parameter OPTION_FTOI_ROUNDING = "CPP",

  parameter OPTION_SHIFTER = "BARREL",

  parameter FEATURE_STORE_BUFFER            = "ENABLED",
  parameter OPTION_STORE_BUFFER_DEPTH_WIDTH = 8,

  parameter FEATURE_MULTICORE = "NONE",

  parameter FEATURE_TRACEPORT_EXEC   = "NONE",
  parameter FEATURE_BRANCH_PREDICTOR = "SIMPLE",

  parameter BUS_IF_TYPE = "WISHBONE32",

  parameter IBUS_WB_TYPE = "B3_READ_BURSTING",
  parameter DBUS_WB_TYPE = "CLASSIC"
)
  ();

  logic                            clk;
  logic                            rst;

  // Wishbone Instruction
  logic [                    31:0] iwbm_adr_o;
  logic                            iwbm_stb_o;
  logic                            iwbm_cyc_o;
  logic [                     3:0] iwbm_sel_o;
  logic                            iwbm_we_o;
  logic [                     2:0] iwbm_cti_o;
  logic [                     1:0] iwbm_bte_o;
  logic [                    31:0] iwbm_dat_o;
  logic                            iwbm_err_i;
  logic                            iwbm_ack_i;
  logic [                    31:0] iwbm_dat_i;
  logic                            iwbm_rty_i;

  // Wishbone Data
  logic [                    31:0] dwbm_adr_o;
  logic                            dwbm_stb_o;
  logic                            dwbm_cyc_o;
  logic [                     3:0] dwbm_sel_o;
  logic                            dwbm_we_o;
  logic [                     2:0] dwbm_cti_o;
  logic [                     1:0] dwbm_bte_o;
  logic [                    31:0] dwbm_dat_o;
  logic                            dwbm_err_i;
  logic                            dwbm_ack_i;
  logic [                    31:0] dwbm_dat_i;
  logic                            dwbm_rty_i;

  logic [                    31:0] irq_i;

  // Debug interface
  logic [                    15:0] du_addr_i;
  logic                            du_stb_i;
  logic [OPTION_OPERAND_WIDTH-1:0] du_dat_i;
  logic                            du_we_i;
  logic [OPTION_OPERAND_WIDTH-1:0] du_dat_o;
  logic                            du_ack_o;

  // Stall control from debug interface
  logic                            du_stall_i;
  logic                            du_stall_o;

  logic                            traceport_exec_valid_o;
  logic [                    31:0] traceport_exec_pc_o;
  logic                            traceport_exec_jb_o;
  logic                            traceport_exec_jal_o;
  logic                            traceport_exec_jr_o;
  logic [                    31:0] traceport_exec_jbtarget_o;
  logic [`OR1K_INSN_WIDTH    -1:0] traceport_exec_insn_o;
  logic [OPTION_OPERAND_WIDTH-1:0] traceport_exec_wbdata_o;
  logic [OPTION_RF_ADDR_WIDTH-1:0] traceport_exec_wbreg_o;
  logic                            traceport_exec_wben_o;

  // The multicore core identifier
  logic [OPTION_OPERAND_WIDTH-1:0] multicore_coreid_i;

  // The number of cores
  logic [OPTION_OPERAND_WIDTH-1:0] multicore_numcores_i;

  logic [                    31:0] snoop_adr_i;
  logic                            snoop_en_i;
  
  clocking driver_cb @(posedge clk);
    output clk;
    output rst;

    // Wishbone Instruction
    input  iwbm_adr_o;
    input  iwbm_stb_o;
    input  iwbm_cyc_o;
    input  iwbm_sel_o;
    input  iwbm_we_o;
    input  iwbm_cti_o;
    input  iwbm_bte_o;
    input  iwbm_dat_o;
    output iwbm_err_i;
    output iwbm_ack_i;
    output iwbm_dat_i;
    output iwbm_rty_i;

    // Wishbone Data
    input  dwbm_adr_o;
    input  dwbm_stb_o;
    input  dwbm_cyc_o;
    input  dwbm_sel_o;
    input  dwbm_we_o;
    input  dwbm_cti_o;
    input  dwbm_bte_o;
    input  dwbm_dat_o;
    output dwbm_err_i;
    output dwbm_ack_i;
    output dwbm_dat_i;
    output dwbm_rty_i;

    output irq_i;

    // Debug interface
    output du_addr_i;
    output du_stb_i;
    output du_dat_i;
    output du_we_i;
    input  du_dat_o;
    input  du_ack_o;

    // Stall control from debug interface
    output du_stall_i;
    input  du_stall_o;

    input  traceport_exec_valid_o;
    input  traceport_exec_pc_o;
    input  traceport_exec_jb_o;
    input  traceport_exec_jal_o;
    input  traceport_exec_jr_o;
    input  traceport_exec_jbtarget_o;
    input  traceport_exec_insn_o;
    input  traceport_exec_wbdata_o;
    input  traceport_exec_wbreg_o;
    input  traceport_exec_wben_o;

    // The multicore core identifier
    output multicore_coreid_i;

    // The number of cores
    output multicore_numcores_i;

    output snoop_adr_i;
    output snoop_en_i;
  endclocking : driver_cb

  clocking monitor_cb @(posedge clk);
    input  clk;
    input  rst;

    // Wishbone Instruction
    output iwbm_adr_o;
    output iwbm_stb_o;
    output iwbm_cyc_o;
    output iwbm_sel_o;
    output iwbm_we_o;
    output iwbm_cti_o;
    output iwbm_bte_o;
    output iwbm_dat_o;
    input  iwbm_err_i;
    input  iwbm_ack_i;
    input  iwbm_dat_i;
    input  iwbm_rty_i;

    // Wishbone Data
    output dwbm_adr_o;
    output dwbm_stb_o;
    output dwbm_cyc_o;
    output dwbm_sel_o;
    output dwbm_we_o;
    output dwbm_cti_o;
    output dwbm_bte_o;
    output dwbm_dat_o;
    input  dwbm_err_i;
    input  dwbm_ack_i;
    input  dwbm_dat_i;
    input  dwbm_rty_i;

    input  irq_i;

    // Debug interface
    input  du_addr_i;
    input  du_stb_i;
    input  du_dat_i;
    input  du_we_i;
    output du_dat_o;
    output du_ack_o;

    // Stall control from debug interface
    input  du_stall_i;
    output du_stall_o;

    output traceport_exec_valid_o;
    output traceport_exec_pc_o;
    output traceport_exec_jb_o;
    output traceport_exec_jal_o;
    output traceport_exec_jr_o;
    output traceport_exec_jbtarget_o;
    output traceport_exec_insn_o;
    output traceport_exec_wbdata_o;
    output traceport_exec_wbreg_o;
    output traceport_exec_wben_o;

    // The multicore core identifier
    input  multicore_coreid_i;

    // The number of cores
    input  multicore_numcores_i;

    input  snoop_adr_i;
    input  snoop_en_i;
  endclocking : monitor_cb

  modport driver_if_mp(clocking driver_cb);
  modport monitor_if_mp(clocking monitor_cb);
endinterface

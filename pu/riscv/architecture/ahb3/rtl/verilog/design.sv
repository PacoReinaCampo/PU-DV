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

interface riscv_interface #(
  parameter            XLEN                  = 64,
  parameter            PLEN                  = 64,
  parameter            ILEN                  = 64,
  parameter            EXCEPTION_SIZE        = 16,
  parameter [XLEN-1:0] PC_INIT               = 'h200,
  parameter            HAS_USER              = 1,
  parameter            HAS_SUPER             = 1,
  parameter            HAS_HYPER             = 1,
  parameter            HAS_BPU               = 1,
  parameter            HAS_FPU               = 1,
  parameter            HAS_MMU               = 1,
  parameter            HAS_RVA               = 1,
  parameter            HAS_RVM               = 1,
  parameter            HAS_RVC               = 1,
  parameter            IS_RV32E              = 1,

  parameter            MULT_LATENCY          = 1,

  parameter            BREAKPOINTS           = 8,

  parameter            PMA_CNT               = 4,
  parameter            PMP_CNT               = 16,

  parameter            BP_GLOBAL_BITS        = 2,
  parameter            BP_LOCAL_BITS         = 10,
  parameter            BP_LOCAL_BITS_LSB     = 2,
 
  parameter            ICACHE_SIZE           = 64,
  parameter            ICACHE_BLOCK_SIZE     = 64,
  parameter            ICACHE_WAYS           = 2,
  parameter            ICACHE_REPLACE_ALG    = 0,
  parameter            ITCM_SIZE             = 0,
 
  parameter            DCACHE_SIZE           = 64,
  parameter            DCACHE_BLOCK_SIZE     = 64,
  parameter            DCACHE_WAYS           = 2,
  parameter            DCACHE_REPLACE_ALG    = 0,
  parameter            DTCM_SIZE             = 0,
  parameter            WRITEBUFFER_SIZE      = 4,

  parameter            TECHNOLOGY            = "GENERIC",

  parameter [XLEN-1:0] MNMIVEC_DEFAULT       = PC_INIT - 'h004,
  parameter [XLEN-1:0] MTVEC_DEFAULT         = PC_INIT - 'h040,
  parameter [XLEN-1:0] HTVEC_DEFAULT         = PC_INIT - 'h080,
  parameter [XLEN-1:0] STVEC_DEFAULT         = PC_INIT - 'h0C0,
  parameter [XLEN-1:0] UTVEC_DEFAULT         = PC_INIT - 'h100,

  parameter            JEDEC_BANK            = 10,
  parameter            JEDEC_MANUFACTURER_ID = 'h6e,

  parameter            HARTID                = 0,

  parameter            PARCEL_SIZE           = 64
)
  ();

  logic                         clk;
  logic                         rst;

  logic [PMA_CNT-1:0][    13:0] pma_cfg_i;
  logic [PMA_CNT-1:0][XLEN-1:0] pma_adr_i;

  // AHB3 instruction
  logic                         ins_HSEL;
  logic              [PLEN-1:0] ins_HADDR;
  logic              [XLEN-1:0] ins_HWDATA;
  logic              [XLEN-1:0] ins_HRDATA;
  logic                         ins_HWRITE;
  logic              [     2:0] ins_HSIZE;
  logic              [     2:0] ins_HBURST;
  logic              [     3:0] ins_HPROT;
  logic              [     1:0] ins_HTRANS;
  logic                         ins_HMASTLOCK;
  logic                         ins_HREADY;
  logic                         ins_HRESP;

  // AHB3 data
  logic                         dat_HSEL;
  logic              [PLEN-1:0] dat_HADDR;
  logic              [XLEN-1:0] dat_HWDATA;
  logic              [XLEN-1:0] dat_HRDATA;
  logic                         dat_HWRITE;
  logic              [     2:0] dat_HSIZE;
  logic              [     2:0] dat_HBURST;
  logic              [     3:0] dat_HPROT;
  logic              [     1:0] dat_HTRANS;
  logic                         dat_HMASTLOCK;
  logic                         dat_HREADY;
  logic                         dat_HRESP;

  // Interrupts
  logic                         ext_nmi;
  logic                         ext_tint;
  logic                         ext_sint;
  logic              [     3:0] ext_int;

  // Debug Interface
  logic                         dbg_stall;
  logic                         dbg_strb;
  logic                         dbg_we;
  logic              [PLEN-1:0] dbg_addr;
  logic              [XLEN-1:0] dbg_dati;
  logic              [XLEN-1:0] dbg_dato;
  logic                         dbg_ack;
  logic                         dbg_bp;
  
  clocking driver_cb @(posedge clk);
    output clk;
    output rst;

    output pma_cfg_i;
    output pma_adr_i;

    // AHB3 instruction
    input  ins_HSEL;
    input  ins_HADDR;
    input  ins_HWDATA;
    output ins_HRDATA;
    input  ins_HWRITE;
    input  ins_HSIZE;
    input  ins_HBURST;
    input  ins_HPROT;
    input  ins_HTRANS;
    input  ins_HMASTLOCK;
    output ins_HREADY;
    output ins_HRESP;

    // AHB3 data
    input  dat_HSEL;
    input  dat_HADDR;
    input  dat_HWDATA;
    output dat_HRDATA;
    input  dat_HWRITE;
    input  dat_HSIZE;
    input  dat_HBURST;
    input  dat_HPROT;
    input  dat_HTRANS;
    input  dat_HMASTLOCK;
    output dat_HREADY;
    output dat_HRESP;

    // Interrupts
    output ext_nmi;
    output ext_tint;
    output ext_sint;
    output ext_int;

    // Debug Interface
    output dbg_stall;
    output dbg_strb;
    output dbg_we;
    output dbg_addr;
    output dbg_dati;
    input  dbg_dato;
    input  dbg_ack;
    input  dbg_bp;
  endclocking : driver_cb

  clocking monitor_cb @(posedge clk);
    input  clk;
    input  rst;

    input  pma_cfg_i;
    input  pma_adr_i;

    // AHB3 instruction
    output ins_HSEL;
    output ins_HADDR;
    output ins_HWDATA;
    input  ins_HRDATA;
    output ins_HWRITE;
    output ins_HSIZE;
    output ins_HBURST;
    output ins_HPROT;
    output ins_HTRANS;
    output ins_HMASTLOCK;
    input  ins_HREADY;
    input  ins_HRESP;

    // AHB3 data
    output dat_HSEL;
    output dat_HADDR;
    output dat_HWDATA;
    input  dat_HRDATA;
    output dat_HWRITE;
    output dat_HSIZE;
    output dat_HBURST;
    output dat_HPROT;
    output dat_HTRANS;
    output dat_HMASTLOCK;
    input  dat_HREADY;
    input  dat_HRESP;

    // Interrupts
    input  ext_nmi;
    input  ext_tint;
    input  ext_sint;
    input  ext_int;

    // Debug Interface
    input  dbg_stall;
    input  dbg_strb;
    input  dbg_we;
    input  dbg_addr;
    input  dbg_dati;
    output dbg_dato;
    output dbg_ack;
    output dbg_bp;
  endclocking : monitor_cb

  modport driver_if_mp(clocking driver_cb);
  modport monitor_if_mp(clocking monitor_cb);
endinterface

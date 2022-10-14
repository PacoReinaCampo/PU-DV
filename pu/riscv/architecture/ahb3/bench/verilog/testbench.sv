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
`include "riscv_sequence.svh"
`include "riscv_driver.svh"
`include "riscv_monitor.svh"
`include "riscv_scoreboard.svh"
`include "riscv_subscriber.svh"
`include "riscv_agent.svh"
`include "riscv_env.svh"
`include "riscv_test.svh"

`include "riscv_defines.sv"

module test;

  parameter            XLEN                  = 64;
  parameter            PLEN                  = 64;
  parameter            ILEN                  = 64;
  parameter            EXCEPTION_SIZE        = 16;
  parameter [XLEN-1:0] PC_INIT               = 'h200;
  parameter            HAS_USER              = 1;
  parameter            HAS_SUPER             = 1;
  parameter            HAS_HYPER             = 1;
  parameter            HAS_BPU               = 1;
  parameter            HAS_FPU               = 1;
  parameter            HAS_MMU               = 1;
  parameter            HAS_RVA               = 1;
  parameter            HAS_RVM               = 1;
  parameter            HAS_RVC               = 1;
  parameter            IS_RV32E              = 1;

  parameter            MULT_LATENCY          = 1;

  parameter            BREAKPOINTS           = 8;

  parameter            PMA_CNT               = 4;
  parameter            PMP_CNT               = 16;

  parameter            BP_GLOBAL_BITS        = 2;
  parameter            BP_LOCAL_BITS         = 10;
  parameter            BP_LOCAL_BITS_LSB     = 2;
 
  parameter            ICACHE_SIZE           = 64;
  parameter            ICACHE_BLOCK_SIZE     = 64;
  parameter            ICACHE_WAYS           = 2;
  parameter            ICACHE_REPLACE_ALG    = 0;
  parameter            ITCM_SIZE             = 0;
 
  parameter            DCACHE_SIZE           = 64;
  parameter            DCACHE_BLOCK_SIZE     = 64;
  parameter            DCACHE_WAYS           = 2;
  parameter            DCACHE_REPLACE_ALG    = 0;
  parameter            DTCM_SIZE             = 0;
  parameter            WRITEBUFFER_SIZE      = 4;

  parameter            TECHNOLOGY            = "GENERIC";

  parameter [XLEN-1:0] MNMIVEC_DEFAULT       = PC_INIT - 'h004;
  parameter [XLEN-1:0] MTVEC_DEFAULT         = PC_INIT - 'h040;
  parameter [XLEN-1:0] HTVEC_DEFAULT         = PC_INIT - 'h080;
  parameter [XLEN-1:0] STVEC_DEFAULT         = PC_INIT - 'h0C0;
  parameter [XLEN-1:0] UTVEC_DEFAULT         = PC_INIT - 'h100;

  parameter            JEDEC_BANK            = 10;
  parameter            JEDEC_MANUFACTURER_ID = 'h6e;

  parameter            HARTID                = 0;

  parameter            PARCEL_SIZE           = 64;

  // Instantiate interface
  riscv_interface riscv_if();

  // Instantiate dut
  riscv_pu_ahb3 #(
    .XLEN                  ( XLEN                  ),
    .PLEN                  ( PLEN                  ),
    .PC_INIT               ( PC_INIT               ),
    .HAS_USER              ( HAS_USER              ),
    .HAS_SUPER             ( HAS_SUPER             ),
    .HAS_HYPER             ( HAS_HYPER             ),
    .HAS_BPU               ( HAS_BPU               ),
    .HAS_FPU               ( HAS_FPU               ),
    .HAS_MMU               ( HAS_MMU               ),
    .HAS_RVM               ( HAS_RVM               ),
    .HAS_RVA               ( HAS_RVA               ),
    .HAS_RVC               ( HAS_RVC               ),
    .IS_RV32E              ( IS_RV32E              ),
 
    .MULT_LATENCY          ( MULT_LATENCY          ),
 
    .BREAKPOINTS           ( BREAKPOINTS           ),
 
    .PMA_CNT               ( PMA_CNT               ),
    .PMP_CNT               ( PMP_CNT               ),
 
    .BP_GLOBAL_BITS        ( BP_GLOBAL_BITS        ),
    .BP_LOCAL_BITS         ( BP_LOCAL_BITS         ),
    .BP_LOCAL_BITS_LSB     ( BP_LOCAL_BITS_LSB     ),
 
    .ICACHE_SIZE           ( ICACHE_SIZE           ),
    .ICACHE_BLOCK_SIZE     ( ICACHE_BLOCK_SIZE     ),
    .ICACHE_WAYS           ( ICACHE_WAYS           ),
    .ICACHE_REPLACE_ALG    ( ICACHE_REPLACE_ALG    ),
    .ITCM_SIZE             ( ITCM_SIZE             ),
 
    .DCACHE_SIZE           ( DCACHE_SIZE           ),
    .DCACHE_BLOCK_SIZE     ( DCACHE_BLOCK_SIZE     ),
    .DCACHE_WAYS           ( DCACHE_WAYS           ),
    .DCACHE_REPLACE_ALG    ( DCACHE_REPLACE_ALG    ),
    .DTCM_SIZE             ( DTCM_SIZE             ),
    .WRITEBUFFER_SIZE      ( WRITEBUFFER_SIZE      ),
 
    .TECHNOLOGY            ( TECHNOLOGY            ),
 
    .MNMIVEC_DEFAULT       ( MNMIVEC_DEFAULT       ),
    .MTVEC_DEFAULT         ( MTVEC_DEFAULT         ),
    .HTVEC_DEFAULT         ( HTVEC_DEFAULT         ),
    .STVEC_DEFAULT         ( STVEC_DEFAULT         ),
    .UTVEC_DEFAULT         ( UTVEC_DEFAULT         ),
 
    .JEDEC_BANK            ( JEDEC_BANK            ),
    .JEDEC_MANUFACTURER_ID ( JEDEC_MANUFACTURER_ID ),
 
    .HARTID                ( HARTID                ),
 
    .PARCEL_SIZE           ( PARCEL_SIZE           )
  )
  dut (
    .HCLK           ( riscv_if.clk           ),
    .HRESETn        ( riscv_if.rst           ),

    .pma_cfg_i      ( riscv_if.pma_cfg       ),
    .pma_adr_i      ( riscv_if.pma_adr       ),

    // AHB3 instruction
    .ins_HSEL       ( riscv_if.ins_HSEL      ),
    .ins_HADDR      ( riscv_if.ins_HADDR     ),
    .ins_HWDATA     ( riscv_if.ins_HWDATA    ),
    .ins_HRDATA     ( riscv_if.ins_HRDATA    ),
    .ins_HWRITE     ( riscv_if.ins_HWRITE    ),
    .ins_HSIZE      ( riscv_if.ins_HSIZE     ),
    .ins_HBURST     ( riscv_if.ins_HBURST    ),
    .ins_HPROT      ( riscv_if.ins_HPROT     ),
    .ins_HTRANS     ( riscv_if.ins_HTRANS    ),
    .ins_HMASTLOCK  ( riscv_if.ins_HMASTLOCK ),
    .ins_HREADY     ( riscv_if.ins_HREADY    ),
    .ins_HRESP      ( riscv_if.ins_HRESP     ),

    // AHB3 data
    .dat_HSEL       ( riscv_if.dat_HSEL      ),
    .dat_HADDR      ( riscv_if.dat_HADDR     ),
    .dat_HWDATA     ( riscv_if.dat_HWDATA    ),
    .dat_HRDATA     ( riscv_if.dat_HRDATA    ),
    .dat_HWRITE     ( riscv_if.dat_HWRITE    ),
    .dat_HSIZE      ( riscv_if.dat_HSIZE     ),
    .dat_HBURST     ( riscv_if.dat_HBURST    ),
    .dat_HPROT      ( riscv_if.dat_HPROT     ),
    .dat_HTRANS     ( riscv_if.dat_HTRANS    ),
    .dat_HMASTLOCK  ( riscv_if.dat_HMASTLOCK ),
    .dat_HREADY     ( riscv_if.dat_HREADY    ),
    .dat_HRESP      ( riscv_if.dat_HRESP     ),

    // Interrupts
    .ext_nmi        ( riscv_if.ext_nmi       ),
    .ext_tint       ( riscv_if.ext_tint      ),
    .ext_sint       ( riscv_if.ext_sint      ),
    .ext_int        ( riscv_if.ext_int       ),

    // Debug Interface
    .dbg_stall      ( riscv_if.dbg_stall     ),
    .dbg_strb       ( riscv_if.dbg_strb      ),
    .dbg_we         ( riscv_if.dbg_we        ),
    .dbg_addr       ( riscv_if.dbg_addr      ),
    .dbg_dati       ( riscv_if.dbg_dati      ),
    .dbg_dato       ( riscv_if.dbg_dato      ),
    .dbg_ack        ( riscv_if.dbg_ack       ),
    .dbg_bp         ( riscv_if.dbg_bp        )
  ); 

  // Clock generation
  always #5 riscv_if.clk = ~riscv_if.clk;
  
  initial begin
    riscv_if.clk = 0;
  end

  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual riscv_interface)::set(null, "*", "riscv_vif", riscv_if);
    
    // Start the test
    run_test();
  end

  initial begin
    $vcdpluson();
  end
endmodule

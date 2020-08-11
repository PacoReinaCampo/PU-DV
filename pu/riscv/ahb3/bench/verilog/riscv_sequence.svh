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

class riscv_transaction extends uvm_sequence_item;
  `uvm_object_utils(riscv_transaction)

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

  parameter            DU_ADDR_SIZE          = 12;
  parameter            MAX_BREAKPOINTS       = 8;

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

  rand bit [15:0] instrn;

  bit                         clk;
  bit                         rst;

  bit [PMA_CNT-1:0][    13:0] pma_cfg_i;
  bit [PMA_CNT-1:0][XLEN-1:0] pma_adr_i;

  // AHB3 instruction
  bit                         ins_HSEL;
  bit              [PLEN-1:0] ins_HADDR;
  bit              [XLEN-1:0] ins_HWDATA;
  bit              [XLEN-1:0] ins_HRDATA;
  bit                         ins_HWRITE;
  bit              [     2:0] ins_HSIZE;
  bit              [     2:0] ins_HBURST;
  bit              [     3:0] ins_HPROT;
  bit              [     1:0] ins_HTRANS;
  bit                         ins_HMASTLOCK;
  bit                         ins_HREADY;
  bit                         ins_HRESP;

  // AHB3 data
  bit                         dat_HSEL;
  bit              [PLEN-1:0] dat_HADDR;
  bit              [XLEN-1:0] dat_HWDATA;
  bit              [XLEN-1:0] dat_HRDATA;
  bit                         dat_HWRITE;
  bit              [     2:0] dat_HSIZE;
  bit              [     2:0] dat_HBURST;
  bit              [     3:0] dat_HPROT;
  bit              [     1:0] dat_HTRANS;
  bit                         dat_HMASTLOCK;
  bit                         dat_HREADY;
  bit                         dat_HRESP;

  // Interrupts
  bit                         ext_nmi;
  bit                         ext_tint;
  bit                         ext_sint;
  bit              [     3:0] ext_int;

  // Debug Interface
  bit                         dbg_stall;
  bit                         dbg_strb;
  bit                         dbg_we;
  bit              [PLEN-1:0] dbg_addr;
  bit              [XLEN-1:0] dbg_dati;
  bit              [XLEN-1:0] dbg_dato;
  bit                         dbg_ack;
  bit                         dbg_bp;

  constraint input_constraint {
    //Cosntraint to prevent EOF operation
    instrn inside {[16'h0000:16'hEFFF]};
  }

  function new (string name = "");
    super.new(name);
  endfunction
endclass: riscv_transaction

class inst_sequence extends uvm_sequence#(riscv_transaction);
  `uvm_object_utils(inst_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  bit [15:0] inst;

  //riscv_transaction req;
  task body;
    req = riscv_transaction::type_id::create("req");
    start_item(req);

    if (!req.randomize()) begin
      `uvm_error("Instruction Sequence", "Randomize failed.");
    end

    inst = req.instrn;

    finish_item(req);
  endtask: body
endclass: inst_sequence

class riscv_sequence extends uvm_sequence#(riscv_transaction);
  `uvm_object_utils(riscv_sequence)

  function new (string name = "");
    super.new(name);
  endfunction

  inst_sequence inst_seq;

  task body;
    //LOOP relative to use case (say 256)
    for(int i =0;i<10000;i++) begin
      inst_seq = inst_sequence::type_id::create("inst_seq");
      inst_seq.start(m_sequencer);
    end
  endtask: body
endclass: riscv_sequence

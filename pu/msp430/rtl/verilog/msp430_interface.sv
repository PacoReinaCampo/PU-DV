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

interface msp430_interface #(
  parameter DW = 16,

  parameter PMEM_MSB = 16,
  parameter DMEM_MSB = 16,

  parameter IRQ_NR = 64
)
  ();

  logic              dbg_clk;
  logic              dbg_rst;
  logic              irq_detect;
  logic              nmi_detect;

  logic [       2:0] i_state;
  logic [       3:0] e_state;
  logic              decode;
  logic [DW    -1:0] ir;
  logic [       5:0] irq_num;
  logic [DW    -1:0] pc;

  logic              nodiv_smclk;

  logic              aclk;              // ASIC ONLY: ACLK
  logic              aclk_en;           // FPGA ONLY: ACLK enable
  logic              dbg_freeze;        // Freeze peripherals
  logic              dbg_i2c_sda_out;   // Debug interface: I2C SDA OUT
  logic              dbg_uart_txd;      // Debug interface: UART TXD
  logic              dco_enable;        // ASIC ONLY: Fast oscillator enable
  logic              dco_wkup;          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
  logic [IRQ_NR-3:0] irq_acc;           // Interrupt request accepted (one-hot signal)
  logic              lfxt_enable;       // ASIC ONLY: Low frequency oscillator enable
  logic              lfxt_wkup;         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
  logic              mclk;              // Main system clock
  logic              puc_rst;           // Main system reset
  logic              smclk;             // ASIC ONLY: SMCLK
  logic              smclk_en;          // FPGA ONLY: SMCLK enable

  logic              cpu_en;            // Enable CPU code execution (asynchronous and non-glitchy)
  logic              dbg_en;            // Debug interface enable (asynchronous and non-glitchy)
  logic [       6:0] dbg_i2c_addr;      // Debug interface: I2C Address
  logic [       6:0] dbg_i2c_broadcast; // Debug interface: I2C Broadcast Address (for multicore systems)
  logic              dbg_i2c_scl;       // Debug interface: I2C SCL
  logic              dbg_i2c_sda_in;    // Debug interface: I2C SDA IN
  logic              dbg_uart_rxd;      // Debug interface: UART RXD (asynchronous)
  logic              dco_clk;           // Fast oscillator (fast clock)
  logic [IRQ_NR-3:0] irq;               // Maskable interrupts (14; 30 or 62)
  logic              lfxt_clk;          // Low frequency oscillator (typ 32kHz)
  logic              nmi;               // Non-maskable interrupt (asynchronous and non-glitchy)
  logic              reset_n;           // Reset Pin (active low; asynchronous and non-glitchy)
  logic              scan_enable;       // ASIC ONLY: Scan enable (active during scan shifting)
  logic              scan_mode;         // ASIC ONLY: Scan mode
  logic              wkup;              // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

  logic [PMEM_MSB:0] pmem_addr;         // Program Memory address
  logic              pmem_cen;          // Program Memory chip enable (low active)
  logic [DW    -1:0] pmem_din;          // Program Memory data input (optional)
  logic [       1:0] pmem_wen;          // Program Memory write enable (low active) (optional)
  logic [DW    -1:0] pmem_dout;         // Program Memory data output


  logic [DMEM_MSB:0] dmem_addr;         // Data Memory address
  logic              dmem_cen;          // Data Memory chip enable (low active)
  logic [DW    -1:0] dmem_din;          // Data Memory data input
  logic [       1:0] dmem_wen;          // Data Memory write enable (low active)
  logic [DW    -1:0] dmem_dout;         // Data Memory data output

  logic [      13:0] per_addr;          // Peripheral address
  logic [DW    -1:0] per_din;           // Peripheral data input
  logic [       1:0] per_we;            // Peripheral write enable (high active)
  logic              per_en;            // Peripheral enable (high active)
  logic [DW    -1:0] per_dout;          // Peripheral data output

  logic [DW    -1:0] r0;
  logic [DW    -1:0] r1;
  logic [DW    -1:0] r2;
  logic [DW    -1:0] r3;
  logic [DW    -1:0] r4;
  logic [DW    -1:0] r5;
  logic [DW    -1:0] r6;
  logic [DW    -1:0] r7;
  logic [DW    -1:0] r8;
  logic [DW    -1:0] r9;
  logic [DW    -1:0] r10;
  logic [DW    -1:0] r11;
  logic [DW    -1:0] r12;
  logic [DW    -1:0] r13;
  logic [DW    -1:0] r14;
  logic [DW    -1:0] r15;
  
  clocking master_cb @(posedge dbg_clk);
    output              dbg_clk;
    output              dbg_rst;
    output              irq_detect;
    output              nmi_detect;

    output [       2:0] i_state;
    output [       3:0] e_state;
    output              decode;
    output [DW    -1:0] ir;
    output [       5:0] irq_num;
    output [DW    -1:0] pc;

    output              nodiv_smclk;

    output              aclk;              // ASIC ONLY: ACLK
    output              aclk_en;           // FPGA ONLY: ACLK enable
    output              dbg_freeze;        // Freeze peripherals
    output              dbg_i2c_sda_out;   // Debug interface: I2C SDA OUT
    output              dbg_uart_txd;      // Debug interface: UART TXD
    output              dco_enable;        // ASIC ONLY: Fast oscillator enable
    output              dco_wkup;          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    output [IRQ_NR-3:0] irq_acc;           // Interrupt request accepted (one-hot signal)
    output              lfxt_enable;       // ASIC ONLY: Low frequency oscillator enable
    output              lfxt_wkup;         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    output              mclk;              // Main system clock
    output              puc_rst;           // Main system reset
    output              smclk;             // ASIC ONLY: SMCLK
    output              smclk_en;          // FPGA ONLY: SMCLK enable

    input               cpu_en;            // Enable CPU code execution (asynchronous and non-glitchy)
    input               dbg_en;            // Debug interface enable (asynchronous and non-glitchy)
    input  [       6:0] dbg_i2c_addr;      // Debug interface: I2C Address
    input  [       6:0] dbg_i2c_broadcast; // Debug interface: I2C Broadcast Address (for multicore systems)
    input               dbg_i2c_scl;       // Debug interface: I2C SCL
    input               dbg_i2c_sda_in;    // Debug interface: I2C SDA IN
    input               dbg_uart_rxd;      // Debug interface: UART RXD (asynchronous)
    input               dco_clk;           // Fast oscillator (fast clock)
    input  [IRQ_NR-3:0] irq;               // Maskable interrupts (14; 30 or 62)
    input               lfxt_clk;          // Low frequency oscillator (typ 32kHz)
    input               nmi;               // Non-maskable interrupt (asynchronous and non-glitchy)
    input               reset_n;           // Reset Pin (active low; asynchronous and non-glitchy)
    input               scan_enable;       // ASIC ONLY: Scan enable (active during scan shifting)
    input               scan_mode;         // ASIC ONLY: Scan mode
    input               wkup;              // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

    output [PMEM_MSB:0] pmem_addr;         // Program Memory address
    output              pmem_cen;          // Program Memory chip enable (low active)
    output [DW    -1:0] pmem_din;          // Program Memory data input (optional)
    output [       1:0] pmem_wen;          // Program Memory write enable (low active) (optional)
    input  [DW    -1:0] pmem_dout;         // Program Memory data output


    output [DMEM_MSB:0] dmem_addr;         // Data Memory address
    output              dmem_cen;          // Data Memory chip enable (low active)
    output [DW    -1:0] dmem_din;          // Data Memory data input
    output [       1:0] dmem_wen;          // Data Memory write enable (low active)
    input  [DW    -1:0] dmem_dout;         // Data Memory data output

    output [      13:0] per_addr;          // Peripheral address
    output [DW    -1:0] per_din;           // Peripheral data input
    output [       1:0] per_we;            // Peripheral write enable (high active)
    output              per_en;            // Peripheral enable (high active)
    input  [DW    -1:0] per_dout;          // Peripheral data output

    output [DW    -1:0] r0;
    output [DW    -1:0] r1;
    output [DW    -1:0] r2;
    output [DW    -1:0] r3;
    output [DW    -1:0] r4;
    output [DW    -1:0] r5;
    output [DW    -1:0] r6;
    output [DW    -1:0] r7;
    output [DW    -1:0] r8;
    output [DW    -1:0] r9;
    output [DW    -1:0] r10;
    output [DW    -1:0] r11;
    output [DW    -1:0] r12;
    output [DW    -1:0] r13;
    output [DW    -1:0] r14;
    output [DW    -1:0] r15;
  endclocking : master_cb

  clocking slave_cb @(posedge dbg_clk);
    input               dbg_clk;
    input               dbg_rst;
    input               irq_detect;
    input               nmi_detect;

    input  [       2:0] i_state;
    input  [       3:0] e_state;
    input               decode;
    input  [DW    -1:0] ir;
    input  [       5:0] irq_num;
    input  [DW    -1:0] pc;

    input               nodiv_smclk;

    input               aclk;              // ASIC ONLY: ACLK
    input               aclk_en;           // FPGA ONLY: ACLK enable
    input               dbg_freeze;        // Freeze peripherals
    input               dbg_i2c_sda_out;   // Debug interface: I2C SDA OUT
    input               dbg_uart_txd;      // Debug interface: UART TXD
    input               dco_enable;        // ASIC ONLY: Fast oscillator enable
    input               dco_wkup;          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    input  [IRQ_NR-3:0] irq_acc;           // Interrupt request accepted (one-hot signal)
    input               lfxt_enable;       // ASIC ONLY: Low frequency oscillator enable
    input               lfxt_wkup;         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    input               mclk;              // Main system clock
    input               puc_rst;           // Main system reset
    input               smclk;             // ASIC ONLY: SMCLK
    input               smclk_en;          // FPGA ONLY: SMCLK enable

    input               cpu_en;            // Enable CPU code execution (asynchronous and non-glitchy)
    output              dbg_en;            // Debug interface enable (asynchronous and non-glitchy)
    output [       6:0] dbg_i2c_addr;      // Debug interface: I2C Address
    output [       6:0] dbg_i2c_broadcast; // Debug interface: I2C Broadcast Address (for multicore systems)
    output              dbg_i2c_scl;       // Debug interface: I2C SCL
    output              dbg_i2c_sda_in;    // Debug interface: I2C SDA IN
    output              dbg_uart_rxd;      // Debug interface: UART RXD (asynchronous)
    output              dco_clk;           // Fast oscillator (fast clock)
    output [IRQ_NR-3:0] irq;               // Maskable interrupts (14; 30 or 62)
    output              lfxt_clk;          // Low frequency oscillator (typ 32kHz)
    output              nmi;               // Non-maskable interrupt (asynchronous and non-glitchy)
    output              reset_n;           // Reset Pin (active low; asynchronous and non-glitchy)
    output              scan_enable;       // ASIC ONLY: Scan enable (active during scan shifting)
    output              scan_mode;         // ASIC ONLY: Scan mode
    output              wkup;              // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

    input  [PMEM_MSB:0] pmem_addr;         // Program Memory address
    input               pmem_cen;          // Program Memory chip enable (low active)
    input  [DW    -1:0] pmem_din;          // Program Memory data output(optional)
    input  [       1:0] pmem_wen;          // Program Memory write enable (low active) (optional)
    output [DW    -1:0] pmem_dout;         // Program Memory data input 


    input  [DMEM_MSB:0] dmem_addr;         // Data Memory address
    input               dmem_cen;          // Data Memory chip enable (low active)
    input  [DW    -1:0] dmem_din;          // Data Memory data input
    input  [       1:0] dmem_wen;          // Data Memory write enable (low active)
    output [DW    -1:0] dmem_dout;         // Data Memory data input 

    input  [      13:0] per_addr;          // Peripheral address
    input  [DW    -1:0] per_din;           // Peripheral data input
    input  [       1:0] per_we;            // Peripheral write enable (high active)
    input               per_en;            // Peripheral enable (high active)
    output [DW    -1:0] per_dout;          // Peripheral data input 

    input  [DW    -1:0] r0;
    input  [DW    -1:0] r1;
    input  [DW    -1:0] r2;
    input  [DW    -1:0] r3;
    input  [DW    -1:0] r4;
    input  [DW    -1:0] r5;
    input  [DW    -1:0] r6;
    input  [DW    -1:0] r7;
    input  [DW    -1:0] r8;
    input  [DW    -1:0] r9;
    input  [DW    -1:0] r10;
    input  [DW    -1:0] r11;
    input  [DW    -1:0] r12;
    input  [DW    -1:0] r13;
    input  [DW    -1:0] r14;
    input  [DW    -1:0] r15;
  endclocking : slave_cb
  
  clocking monitor_cb @(posedge clk);
    input              dbg_clk;
    input              dbg_rst;
    input              irq_detect;
    input              nmi_detect;

    input [       2:0] i_state;
    input [       3:0] e_state;
    input              decode;
    input [DW    -1:0] ir;
    input [       5:0] irq_num;
    input [DW    -1:0] pc;

    input              nodiv_smclk;

    input              aclk;              // ASIC ONLY: ACLK
    input              aclk_en;           // FPGA ONLY: ACLK enable
    input              dbg_freeze;        // Freeze peripherals
    input              dbg_i2c_sda_out;   // Debug interface: I2C SDA OUT
    input              dbg_uart_txd;      // Debug interface: UART TXD
    input              dco_enable;        // ASIC ONLY: Fast oscillator enable
    input              dco_wkup;          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    input [IRQ_NR-3:0] irq_acc;           // Interrupt request accepted (one-hot signal)
    input              lfxt_enable;       // ASIC ONLY: Low frequency oscillator enable
    input              lfxt_wkup;         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    input              mclk;              // Main system clock
    input              puc_rst;           // Main system reset
    input              smclk;             // ASIC ONLY: SMCLK
    input              smclk_en;          // FPGA ONLY: SMCLK enable

    input              cpu_en;            // Enable CPU code execution (asynchronous and non-glitchy)
    input              dbg_en;            // Debug interface enable (asynchronous and non-glitchy)
    input [       6:0] dbg_i2c_addr;      // Debug interface: I2C Address
    input [       6:0] dbg_i2c_broadcast; // Debug interface: I2C Broadcast Address (for multicore systems)
    input              dbg_i2c_scl;       // Debug interface: I2C SCL
    input              dbg_i2c_sda_in;    // Debug interface: I2C SDA IN
    input              dbg_uart_rxd;      // Debug interface: UART RXD (asynchronous)
    input              dco_clk;           // Fast oscillator (fast clock)
    input [IRQ_NR-3:0] irq;               // Maskable interrupts (14; 30 or 62)
    input              lfxt_clk;          // Low frequency oscillator (typ 32kHz)
    input              nmi;               // Non-maskable interrupt (asynchronous and non-glitchy)
    input              reset_n;           // Reset Pin (active low; asynchronous and non-glitchy)
    input              scan_enable;       // ASIC ONLY: Scan enable (active during scan shifting)
    input              scan_mode;         // ASIC ONLY: Scan mode
    input              wkup;              // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

    input [PMEM_MSB:0] pmem_addr;         // Program Memory address
    input              pmem_cen;          // Program Memory chip enable (low active)
    input [DW    -1:0] pmem_din;          // Program Memory data input (optional)
    input [       1:0] pmem_wen;          // Program Memory write enable (low active) (optional)
    input [DW    -1:0] pmem_dout;         // Program Memory data output


    input [DMEM_MSB:0] dmem_addr;         // Data Memory address
    input              dmem_cen;          // Data Memory chip enable (low active)
    input [DW    -1:0] dmem_din;          // Data Memory data input
    input [       1:0] dmem_wen;          // Data Memory write enable (low active)
    input [DW    -1:0] dmem_dout;         // Data Memory data output

    input [      13:0] per_addr;          // Peripheral address
    input [DW    -1:0] per_din;           // Peripheral data input
    input [       1:0] per_we;            // Peripheral write enable (high active)
    input              per_en;            // Peripheral enable (high active)
    input [DW    -1:0] per_dout;          // Peripheral data output

    input [DW    -1:0] r0;
    input [DW    -1:0] r1;
    input [DW    -1:0] r2;
    input [DW    -1:0] r3;
    input [DW    -1:0] r4;
    input [DW    -1:0] r5;
    input [DW    -1:0] r6;
    input [DW    -1:0] r7;
    input [DW    -1:0] r8;
    input [DW    -1:0] r9;
    input [DW    -1:0] r10;
    input [DW    -1:0] r11;
    input [DW    -1:0] r12;
    input [DW    -1:0] r13;
    input [DW    -1:0] r14;
    input [DW    -1:0] r15;
  endclocking : monitor_cb

  modport master(clocking master_cb);
  modport slave(clocking slave_cb);
  modport passive(clocking monitor_cb);
endinterface

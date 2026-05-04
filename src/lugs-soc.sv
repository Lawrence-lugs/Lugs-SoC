// SPDX-License-Identifier: Apache-2.0
// Top-level of the SoC (internal core, equivalent to chip_core in the IHP template).
//
// For the initial padring test this module contains:
//   - ibex_core  — RISC-V CPU
//   - ibex_register_file_ff — flip-flop register file
//   - sram_1rw_32_1024_wrapper — hardened SRAM wrapper (1024×32, from sram/)
//
// All peripheral interfaces (UART, QSPI, JTAG, GPIO) are stubbed out and will
// be wired to real IP blocks in a later revision.

`default_nettype none

import ibex_pkg::*;

module lugs_soc (
    input  logic        clk,
    input  logic        rst_n,

    // UART
    output logic        uart_tx,
    input  logic        uart_rx,

    // QSPI (quad-SPI flash)
    output logic        qspi_sck,
    output logic        qspi_cs,
    input  logic [3:0]  qspi_io_in,
    output logic [3:0]  qspi_io_out,
    output logic [3:0]  qspi_io_oe,

    // JTAG debug
    input  logic        jtag_tck,
    input  logic        jtag_tms,
    input  logic        jtag_tdi,
    output logic        jtag_tdo,

    // General-purpose I/O
    input  logic [3:0]  gpio_in,
    output logic [3:0]  gpio_out,
    output logic [3:0]  gpio_oe
);

    // -----------------------------------------------------------------------
    // Ibex data-memory interface wires
    // -----------------------------------------------------------------------
    logic        data_req;
    logic        data_we;
    logic [3:0]  data_be;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic [31:0] data_rdata;
    logic        data_rvalid;

    // -----------------------------------------------------------------------
    // Ibex instruction-memory interface (always-grant, NOP stream)
    // The CPU will boot from address 0 and execute NOPs indefinitely until
    // firmware is added to a ROM / flash controller.
    // -----------------------------------------------------------------------
    logic instr_req;
    logic instr_rvalid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) instr_rvalid <= 1'b0;
        else        instr_rvalid <= instr_req;
    end

    // -----------------------------------------------------------------------
    // External register-file wires (ibex_core ↔ ibex_register_file_ff)
    // -----------------------------------------------------------------------
    logic        dummy_instr_id, dummy_instr_wb;
    logic [4:0]  rf_raddr_a, rf_raddr_b, rf_waddr_wb;
    logic        rf_we_wb;
    logic [31:0] rf_wdata_wb;
    logic [31:0] rf_rdata_a, rf_rdata_b;

    // -----------------------------------------------------------------------
    // Ibex core
    // -----------------------------------------------------------------------
    /* verilator lint_off PINCONNECTEMPTY */
    ibex_core #(
        .ICache           (1'b0),
        .BranchPredictor  (1'b0),
        .WritebackStage   (1'b0),
        .RV32M            (ibex_pkg::RV32MFast),
        .RV32B            (ibex_pkg::RV32BNone),
        .DummyInstructions(1'b0),
        .PMPEnable        (1'b0),
        .DbgTriggerEn     (1'b0)
    ) u_ibex (
        .clk_i                  (clk),
        .rst_ni                 (rst_n),
        .hart_id_i              (32'h0),
        .boot_addr_i            (32'h0),

        // Instruction memory — always-grant, feed NOPs (ADDI x0,x0,0)
        .instr_req_o            (instr_req),
        .instr_gnt_i            (instr_req),
        .instr_rvalid_i         (instr_rvalid),
        .instr_addr_o           (),
        .instr_rdata_i          (32'h0000_0013),
        .instr_err_i            (1'b0),

        // Data memory — connected to SRAM
        .data_req_o             (data_req),
        .data_gnt_i             (data_req),
        .data_rvalid_i          (data_rvalid),
        .data_we_o              (data_we),
        .data_be_o              (data_be),
        .data_addr_o            (data_addr),
        .data_wdata_o           (data_wdata),
        .data_rdata_i           (data_rdata),
        .data_err_i             (1'b0),

        // External register file
        .dummy_instr_id_o       (dummy_instr_id),
        .dummy_instr_wb_o       (dummy_instr_wb),
        .rf_raddr_a_o           (rf_raddr_a),
        .rf_raddr_b_o           (rf_raddr_b),
        .rf_waddr_wb_o          (rf_waddr_wb),
        .rf_we_wb_o             (rf_we_wb),
        .rf_wdata_wb_ecc_o      (rf_wdata_wb),
        .rf_rdata_a_ecc_i       (rf_rdata_a),
        .rf_rdata_b_ecc_i       (rf_rdata_b),

        // ICache RAMs — disabled (ICache=0); outputs open, inputs not driven
        // (Yosys ties unconnected inputs to 0; ic_rdata is irrelevant when ICache=0)
        .ic_tag_req_o           (),
        .ic_tag_write_o         (),
        .ic_tag_addr_o          (),
        .ic_tag_wdata_o         (),
        .ic_data_req_o          (),
        .ic_data_write_o        (),
        .ic_data_addr_o         (),
        .ic_data_wdata_o        (),
        .ic_scr_key_valid_i     (1'b0),
        .ic_scr_key_req_o       (),

        // Interrupts — all masked for stub
        .irq_software_i         (1'b0),
        .irq_timer_i            (1'b0),
        .irq_external_i         (1'b0),
        .irq_fast_i             (15'b0),
        .irq_nm_i               (1'b0),
        .irq_pending_o          (),

        // Debug — tied off (no debug module yet)
        .debug_req_i            (1'b0),
        .crash_dump_o           (),
        .double_fault_seen_o    (),

        // CPU control
        .fetch_enable_i         (ibex_pkg::IbexMuBiOn),
        .alert_minor_o          (),
        .alert_major_internal_o (),
        .alert_major_bus_o      (),
        .core_busy_o            ()
    );
    /* verilator lint_on PINCONNECTEMPTY */

    // -----------------------------------------------------------------------
    // Flip-flop register file
    // -----------------------------------------------------------------------
    ibex_register_file_ff u_regfile (
        .clk_i           (clk),
        .rst_ni          (rst_n),
        .test_en_i       (1'b0),
        .dummy_instr_id_i(dummy_instr_id),
        .dummy_instr_wb_i(dummy_instr_wb),
        .raddr_a_i       (rf_raddr_a),
        .rdata_a_o       (rf_rdata_a),
        .raddr_b_i       (rf_raddr_b),
        .rdata_b_o       (rf_rdata_b),
        .waddr_a_i       (rf_waddr_wb),
        .wdata_a_i       (rf_wdata_wb),
        .we_a_i          (rf_we_wb)
    );

    // -----------------------------------------------------------------------
    // Data read-valid: 1 cycle after a granted read
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) data_rvalid <= 1'b0;
        else        data_rvalid <= data_req & ~data_we;
    end

    // -----------------------------------------------------------------------
    // Hardened SRAM wrapper — 1024 × 32-bit, single-port.
    // (* keep *) / (* keep_hierarchy *) prevent Yosys from optimising the
    // macro away during constant propagation / dead-code elimination — the
    // same pattern used in the greyhound reference design.
    // -----------------------------------------------------------------------
    (* keep *) wire [31:0] sram_rdata;
    (* keep_hierarchy *)
    sram_1rw_32_1024_wrapper u_sram (
        .clk   (clk),
        .cs    (data_req),
        .we    (data_we),
        .addr  (data_addr[11:2]),
        .wdata (data_wdata),
        .wmask (data_be),
        .rdata (sram_rdata)
    );
    assign data_rdata = sram_rdata;

    // -----------------------------------------------------------------------
    // Peripheral stub tie-offs (filled in future revisions)
    // -----------------------------------------------------------------------
    assign uart_tx    = 1'b1;    // UART idle-high
    assign qspi_sck   = 1'b0;
    assign qspi_cs    = 1'b1;    // deasserted (active-low)
    assign qspi_io_out = 4'b0;
    assign qspi_io_oe  = 4'b0;   // all QSPI IOs as inputs
    assign jtag_tdo   = 1'b1;    // JTAG TDO idle-high
    assign gpio_out   = 4'b0;
    assign gpio_oe    = 4'b0;    // all GPIOs as inputs

    // Suppress unused-input warnings
    logic _unused;
    assign _unused = &{uart_rx, qspi_io_in, jtag_tck, jtag_tms, jtag_tdi, gpio_in};

endmodule

`default_nettype wire
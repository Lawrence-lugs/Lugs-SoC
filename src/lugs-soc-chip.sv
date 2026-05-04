// SPDX-License-Identifier: Apache-2.0
// Padring and SoC top-level instantiation — IHP SG13G2
//
// 24 pads (6 per side) arranged as follows:
//   SOUTH (6): clk_pad, nrst_pad, uart_rx_pad, uart_tx_pad, gpio0_pad, gpio1_pad
//   EAST  (6): qspi_sck_pad, qspi_cs_pad, qspi_io0_pad, qspi_io1_pad, qspi_io2_pad, qspi_io3_pad
//   NORTH (6): jtag_tck_pad, jtag_tms_pad, jtag_tdi_pad, jtag_tdo_pad, gpio2_pad, gpio3_pad
//   WEST  (6): vddio_pad (IOVDD), vddc_pad (VDD), vss0_pad .. vss3_pad (downbonded VSS)

`default_nettype none

module lugs_soc_chip (
`ifdef USE_POWER_PINS
    inout  wire IOVDD,
    inout  wire IOVSS,
    inout  wire VDD,
    inout  wire VSS,
`endif
    // Clock & reset
    inout  wire clk_PAD,
    inout  wire nrst_PAD,

    // UART
    inout  wire uart_tx_PAD,
    inout  wire uart_rx_PAD,

    // QSPI flash
    inout  wire qspi_sck_PAD,
    inout  wire qspi_cs_PAD,
    inout  wire qspi_io0_PAD,
    inout  wire qspi_io1_PAD,
    inout  wire qspi_io2_PAD,
    inout  wire qspi_io3_PAD,

    // JTAG
    inout  wire jtag_tck_PAD,
    inout  wire jtag_tms_PAD,
    inout  wire jtag_tdi_PAD,
    inout  wire jtag_tdo_PAD,

    // General-purpose I/O
    inout  wire gpio0_PAD,
    inout  wire gpio1_PAD,
    inout  wire gpio2_PAD,
    inout  wire gpio3_PAD
);

    // -----------------------------------------------------------------------
    // Internal pad-to-core / core-to-pad signals
    // -----------------------------------------------------------------------

    // Clock & reset
    wire clk_core;
    wire nrst_core;

    // UART
    wire uart_tx_core;
    wire uart_rx_core;

    // QSPI
    wire qspi_sck_core;
    wire qspi_cs_core;
    wire [3:0] qspi_io_in_core;
    wire [3:0] qspi_io_out_core;
    wire [3:0] qspi_io_oe_core;

    // JTAG
    wire jtag_tck_core;
    wire jtag_tms_core;
    wire jtag_tdi_core;
    wire jtag_tdo_core;

    // GPIO
    wire [3:0] gpio_in_core;
    wire [3:0] gpio_out_core;
    wire [3:0] gpio_oe_core;

    // -----------------------------------------------------------------------
    // SOUTH pad row
    //   clk_pad  nrst_pad  uart_rx_pad  uart_tx_pad  gpio0_pad  gpio1_pad
    // -----------------------------------------------------------------------

    (* keep *) sg13g2_IOPadIn clk_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .p2c    (clk_core),
        .pad    (clk_PAD)
    );

    (* keep *) sg13g2_IOPadIn nrst_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .p2c    (nrst_core),
        .pad    (nrst_PAD)
    );

    (* keep *) sg13g2_IOPadIn uart_rx_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .p2c    (uart_rx_core),
        .pad    (uart_rx_PAD)
    );

    (* keep *) sg13g2_IOPadOut30mA uart_tx_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (uart_tx_core),
        .pad    (uart_tx_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA gpio0_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (gpio_out_core[0]),
        .c2p_en (gpio_oe_core[0]),
        .p2c    (gpio_in_core[0]),
        .pad    (gpio0_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA gpio1_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (gpio_out_core[1]),
        .c2p_en (gpio_oe_core[1]),
        .p2c    (gpio_in_core[1]),
        .pad    (gpio1_PAD)
    );

    // -----------------------------------------------------------------------
    // EAST pad row
    //   qspi_sck_pad  qspi_cs_pad  qspi_io0..3_pad
    // -----------------------------------------------------------------------

    (* keep *) sg13g2_IOPadOut30mA qspi_sck_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (qspi_sck_core),
        .pad    (qspi_sck_PAD)
    );

    (* keep *) sg13g2_IOPadOut30mA qspi_cs_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (qspi_cs_core),
        .pad    (qspi_cs_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA qspi_io0_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (qspi_io_out_core[0]),
        .c2p_en (qspi_io_oe_core[0]),
        .p2c    (qspi_io_in_core[0]),
        .pad    (qspi_io0_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA qspi_io1_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (qspi_io_out_core[1]),
        .c2p_en (qspi_io_oe_core[1]),
        .p2c    (qspi_io_in_core[1]),
        .pad    (qspi_io1_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA qspi_io2_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (qspi_io_out_core[2]),
        .c2p_en (qspi_io_oe_core[2]),
        .p2c    (qspi_io_in_core[2]),
        .pad    (qspi_io2_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA qspi_io3_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (qspi_io_out_core[3]),
        .c2p_en (qspi_io_oe_core[3]),
        .p2c    (qspi_io_in_core[3]),
        .pad    (qspi_io3_PAD)
    );

    // -----------------------------------------------------------------------
    // NORTH pad row
    //   jtag_tck_pad  jtag_tms_pad  jtag_tdi_pad  jtag_tdo_pad  gpio2_pad  gpio3_pad
    // -----------------------------------------------------------------------

    (* keep *) sg13g2_IOPadIn jtag_tck_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .p2c    (jtag_tck_core),
        .pad    (jtag_tck_PAD)
    );

    (* keep *) sg13g2_IOPadIn jtag_tms_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .p2c    (jtag_tms_core),
        .pad    (jtag_tms_PAD)
    );

    (* keep *) sg13g2_IOPadIn jtag_tdi_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .p2c    (jtag_tdi_core),
        .pad    (jtag_tdi_PAD)
    );

    (* keep *) sg13g2_IOPadOut30mA jtag_tdo_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (jtag_tdo_core),
        .pad    (jtag_tdo_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA gpio2_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (gpio_out_core[2]),
        .c2p_en (gpio_oe_core[2]),
        .p2c    (gpio_in_core[2]),
        .pad    (gpio2_PAD)
    );

    (* keep *) sg13g2_IOPadInOut30mA gpio3_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS),
`endif
        .c2p    (gpio_out_core[3]),
        .c2p_en (gpio_oe_core[3]),
        .p2c    (gpio_in_core[3]),
        .pad    (gpio3_PAD)
    );

    // -----------------------------------------------------------------------
    // WEST pad row
    //   vddio_pad (IOVDD power)  vddc_pad (VDD core power)  vss0..3_pad (downbonded VSS)
    // -----------------------------------------------------------------------

    (* keep *) sg13g2_IOPadIOVdd vddio_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS)
`endif
    );

    (* keep *) sg13g2_IOPadVdd vddc_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS)
`endif
    );

    (* keep *) sg13g2_IOPadVss vss0_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS)
`endif
    );

    (* keep *) sg13g2_IOPadVss vss1_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS)
`endif
    );

    (* keep *) sg13g2_IOPadVss vss2_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS)
`endif
    );

    (* keep *) sg13g2_IOPadVss vss3_pad (
`ifdef USE_POWER_PINS
        .iovdd  (IOVDD), .iovss  (IOVSS), .vdd    (VDD), .vss    (VSS)
`endif
    );

    // -----------------------------------------------------------------------
    // Internal SoC core
    // -----------------------------------------------------------------------
    (* keep *) lugs_soc u_lugs_soc (
        .clk         (clk_core),
        .rst_n       (nrst_core),

        .uart_tx     (uart_tx_core),
        .uart_rx     (uart_rx_core),

        .qspi_sck    (qspi_sck_core),
        .qspi_cs     (qspi_cs_core),
        .qspi_io_in  (qspi_io_in_core),
        .qspi_io_out (qspi_io_out_core),
        .qspi_io_oe  (qspi_io_oe_core),

        .jtag_tck    (jtag_tck_core),
        .jtag_tms    (jtag_tms_core),
        .jtag_tdi    (jtag_tdi_core),
        .jtag_tdo    (jtag_tdo_core),

        .gpio_in     (gpio_in_core),
        .gpio_out    (gpio_out_core),
        .gpio_oe     (gpio_oe_core)
    );

endmodule

`default_nettype wire
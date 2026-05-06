###############################################################################
# Created by write_sdc
###############################################################################
current_design lugs_soc_chip
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk_PAD -period 20.0000 [get_pins {clk_pad/p2c}]
set_clock_transition 0.1500 [get_clocks {clk_PAD}]
set_clock_uncertainty 0.2500 clk_PAD
set_propagated_clock [get_clocks {clk_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {gpio0_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {gpio0_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {gpio1_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {gpio1_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {gpio2_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {gpio2_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {gpio3_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {gpio3_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {jtag_tck_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {jtag_tck_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {jtag_tdi_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {jtag_tdi_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {jtag_tms_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {jtag_tms_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {nrst_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {nrst_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {qspi_io0_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {qspi_io0_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {qspi_io1_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {qspi_io1_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {qspi_io2_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {qspi_io2_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {qspi_io3_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {qspi_io3_PAD}]
set_input_delay 0.0000 -clock [get_clocks {clk_PAD}] -min -add_delay [get_ports {uart_rx_PAD}]
set_input_delay 4.0000 -clock [get_clocks {clk_PAD}] -max -add_delay [get_ports {uart_rx_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {gpio0_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {gpio1_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {gpio2_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {gpio3_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {jtag_tdo_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {qspi_cs_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {qspi_io0_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {qspi_io1_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {qspi_io2_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {qspi_io3_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {qspi_sck_PAD}]
set_output_delay 4.0000 -clock [get_clocks {clk_PAD}] -add_delay [get_ports {uart_tx_PAD}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0060 [get_ports {clk_PAD}]
set_load -pin_load 0.0060 [get_ports {gpio0_PAD}]
set_load -pin_load 0.0060 [get_ports {gpio1_PAD}]
set_load -pin_load 0.0060 [get_ports {gpio2_PAD}]
set_load -pin_load 0.0060 [get_ports {gpio3_PAD}]
set_load -pin_load 0.0060 [get_ports {jtag_tck_PAD}]
set_load -pin_load 0.0060 [get_ports {jtag_tdi_PAD}]
set_load -pin_load 0.0060 [get_ports {jtag_tdo_PAD}]
set_load -pin_load 0.0060 [get_ports {jtag_tms_PAD}]
set_load -pin_load 0.0060 [get_ports {nrst_PAD}]
set_load -pin_load 0.0060 [get_ports {qspi_cs_PAD}]
set_load -pin_load 0.0060 [get_ports {qspi_io0_PAD}]
set_load -pin_load 0.0060 [get_ports {qspi_io1_PAD}]
set_load -pin_load 0.0060 [get_ports {qspi_io2_PAD}]
set_load -pin_load 0.0060 [get_ports {qspi_io3_PAD}]
set_load -pin_load 0.0060 [get_ports {qspi_sck_PAD}]
set_load -pin_load 0.0060 [get_ports {uart_rx_PAD}]
set_load -pin_load 0.0060 [get_ports {uart_tx_PAD}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 10.0000 [current_design]

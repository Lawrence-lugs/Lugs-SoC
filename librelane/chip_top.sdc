# SDC timing constraints for lugs_soc_chip (padring flow)
# Based on the IHP SG13G2 LibreLane template chip_top.sdc.

current_design $::env(DESIGN_NAME)
set_units -time ns

# ---------------------------------------------------------------------------
# Clock — defined at the pad input; travels through the IOPadIn cell (p2c)
# ---------------------------------------------------------------------------
set clock_port clk_PAD
if { [info exists ::env(CLOCK_PORT)] } {
    set clock_port [lindex $::env(CLOCK_PORT) 0]
}

if { $::env(CLOCK_PORT) eq $::env(CLOCK_NET) } {
    create_clock [get_ports $clock_port] \
        -name $clock_port \
        -period $::env(CLOCK_PERIOD)
} else {
    # CLOCK_NET points to the internal side of the pad cell (p2c pin)
    create_clock [get_pins [lindex $::env(CLOCK_NET) 0]] \
        -name $clock_port \
        -period $::env(CLOCK_PERIOD)
}

set clocks      [get_clocks $clock_port]
set period      $::env(CLOCK_PERIOD)
set io_delay    [expr { $period * $::env(IO_DELAY_CONSTRAINT) / 100.0 }]

# ---------------------------------------------------------------------------
# Input delays — all non-clock input pads
# ---------------------------------------------------------------------------
set input_pads [get_ports {
    nrst_PAD
    uart_rx_PAD
    qspi_io0_PAD qspi_io1_PAD qspi_io2_PAD qspi_io3_PAD
    jtag_tck_PAD jtag_tms_PAD jtag_tdi_PAD
    gpio0_PAD gpio1_PAD gpio2_PAD gpio3_PAD
}]

set_input_delay -min 0          -clock $clocks $input_pads
set_input_delay -max $io_delay  -clock $clocks $input_pads

# ---------------------------------------------------------------------------
# Output delays — all output / bidir pads driven by core
# ---------------------------------------------------------------------------
set output_pads [get_ports {
    uart_tx_PAD
    qspi_sck_PAD qspi_cs_PAD
    qspi_io0_PAD qspi_io1_PAD qspi_io2_PAD qspi_io3_PAD
    jtag_tdo_PAD
    gpio0_PAD gpio1_PAD gpio2_PAD gpio3_PAD
}]

set_output_delay $io_delay -clock $clocks $output_pads

# ---------------------------------------------------------------------------
# Load / fanout / transition constraints
# ---------------------------------------------------------------------------
set cap_load [expr { $::env(OUTPUT_CAP_LOAD) / 1000.0 }]
set_load $cap_load [all_outputs]

set_max_fanout $::env(MAX_FANOUT_CONSTRAINT) [current_design]

if { [info exists ::env(MAX_TRANSITION_CONSTRAINT)] } {
    set_max_transition $::env(MAX_TRANSITION_CONSTRAINT) [current_design]
}
if { [info exists ::env(MAX_CAPACITANCE_CONSTRAINT)] } {
    set_max_capacitance $::env(MAX_CAPACITANCE_CONSTRAINT) [current_design]
}

# ---------------------------------------------------------------------------
# Clock uncertainty and derating
# ---------------------------------------------------------------------------
set_clock_uncertainty $::env(CLOCK_UNCERTAINTY_CONSTRAINT) $clocks
set_clock_transition  $::env(CLOCK_TRANSITION_CONSTRAINT)  $clocks

set_timing_derate -early [expr { 1 - $::env(TIME_DERATING_CONSTRAINT) / 100.0 }]
set_timing_derate -late  [expr { 1 + $::env(TIME_DERATING_CONSTRAINT) / 100.0 }]

if { [info exists ::env(OPENLANE_SDC_IDEAL_CLOCKS)] &&
     $::env(OPENLANE_SDC_IDEAL_CLOCKS) } {
    unset_propagated_clock [all_clocks]
} else {
    set_propagated_clock [all_clocks]
}

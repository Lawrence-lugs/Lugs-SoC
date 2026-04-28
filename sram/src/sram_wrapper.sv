// SRAM wrapper for SoC integration – IHP SG13G2.
//
// Instantiates the IHP pre-compiled RM_IHPSG13_1P_1024x32_c2_bm_bist macro
// and exposes a simplified memory interface compatible with the Ibex bus.
//
// IHP SRAM port interface (active-LOW enables):
//   A_CLK      – rising-edge clock
//   A_MEN      – memory enable bar  (active-low chip-select)
//   A_WEN      – write enable bar   (active-low)
//   A_REN      – read enable bar    (active-low)
//   A_ADDR[9:0]– word address (1024 entries)
//   A_DIN[31:0]– write data
//   A_DLY      – extra pipeline delay; tie to 1'b1
//   A_DOUT[31:0]– read data (registered, valid one cycle after addr)
//   A_BM[31:0] – bit-level write mask (1 = write bit, 0 = hold)
//   A_BIST_*   – BIST interface; tie inactive
//
// This wrapper presents an active-high interface and converts the 4-bit byte
// write-mask to the 32-bit bit-mask the IHP macro expects.

`default_nettype none

module sram_1rw_32_1024_wrapper (
    input  wire        clk,

    // Active-high chip-select and write-enable.
    input  wire        cs,       // 1 = access enabled
    input  wire        we,       // 1 = write, 0 = read

    input  wire [ 9:0] addr,     // word address (1024 locations)
    input  wire [31:0] wdata,    // write data
    input  wire [ 3:0] wmask,    // byte write mask: bit N enables byte N

    output wire [31:0] rdata     // read data (valid one cycle after addr)
);

    // Expand 4-bit byte-enable to 32-bit bit-level mask required by A_BM.
    wire [31:0] bm = {{8{wmask[3]}}, {8{wmask[2]}}, {8{wmask[1]}}, {8{wmask[0]}}};

    RM_IHPSG13_1P_1024x32_c2_bm_bist u_sram (
        .A_CLK       (clk),
        .A_MEN       (~cs),           // active-low: deassert to enable
        .A_WEN       (~we),           // active-low: deassert to write
        .A_REN       (~(cs & ~we)),   // active-low: assert on cs=1, we=0
        .A_ADDR      (addr),
        .A_DIN       (wdata),
        .A_DLY       (1'b1),          // normal timing (no extra delay path)
        .A_DOUT      (rdata),
        .A_BM        (bm),
        // BIST ports inactive
        .A_BIST_CLK  (1'b0),
        .A_BIST_EN   (1'b0),
        .A_BIST_MEN  (1'b1),
        .A_BIST_WEN  (1'b1),
        .A_BIST_REN  (1'b1),
        .A_BIST_ADDR (10'b0),
        .A_BIST_DIN  (32'b0),
        .A_BIST_BM   (32'b0)
    );

endmodule

`default_nettype wire

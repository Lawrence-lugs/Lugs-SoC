// Blackbox stub for the IHP SG13G2 pre-compiled SRAM macro.
//
// Used only for synthesis (Yosys) so it can resolve the module interface
// of RM_IHPSG13_1P_1024x32_c2_bm_bist without parsing the full PDK Verilog,
// which contains specify/setuphold blocks that Yosys cannot parse.
//
// Physical files (GDS, LEF) and timing (Liberty) come from the installed PDK:
//   /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_sram/

(* blackbox *)
module RM_IHPSG13_1P_1024x32_c2_bm_bist (
    input         A_CLK,
    input         A_MEN,
    input         A_WEN,
    input         A_REN,
    input  [ 9:0] A_ADDR,
    input  [31:0] A_DIN,
    input         A_DLY,
    output [31:0] A_DOUT,
    input  [31:0] A_BM,
    input         A_BIST_CLK,
    input         A_BIST_EN,
    input         A_BIST_MEN,
    input         A_BIST_WEN,
    input         A_BIST_REN,
    input  [ 9:0] A_BIST_ADDR,
    input  [31:0] A_BIST_DIN,
    input  [31:0] A_BIST_BM
);
endmodule

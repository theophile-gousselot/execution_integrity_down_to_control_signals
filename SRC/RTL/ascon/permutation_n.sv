`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:    Defines for various type.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module permutation_n
    import ascon_pack::*;    
#(                                                                              
    parameter HW_PERMUTATION_N = 6,
    parameter CLK_FACTOR = 1


) (
	input  state_t    state_i,
    input logic [2:0] round_index_i,
    output state_t    state_o
);

/* verilator lint_off UNOPTFLAT */
    state_t state_s [HW_PERMUTATION_N:0];
/* verilator lint_on UNOPTFLAT */

    genvar i;
    generate
        for (i=0; i < HW_PERMUTATION_N; i++) begin : g_permutation
            permutation permutation_0
            (
                .state_i(state_s[i]),
                .round_i(4'(i+12-HW_PERMUTATION_N*(CLK_FACTOR-32'(round_index_i)))),
                .state_o(state_s[i+1])
            );
        end : g_permutation
    endgenerate

    assign state_s[0] = state_i;
    assign state_o = state_s[HW_PERMUTATION_N];
endmodule

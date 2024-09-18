`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:    Defines for various type.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module permutation
    import ascon_pack::*;    
(
	input  state_t state_i,
	input  [3:0]   round_i,
	output state_t state_o
);

state_t state_c2s_s;
state_t state_s2l_s;

addroundconstant addroundconstant_0
(
    .state_i(state_i),
	.round_i(round_i),
    .state_o(state_c2s_s)
);

sublayer sublayer_0
(
    .state_i(state_c2s_s),
    .state_o(state_s2l_s)
);

linlayer linlayer_0
(
    .state_i(state_s2l_s),
    .state_o(state_o)
);
endmodule


 

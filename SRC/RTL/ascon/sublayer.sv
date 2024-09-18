`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:   Substitution Layer                                          // 
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module sublayer
    import ascon_pack::*;
(
	input  state_t  state_i,
	output state_t  state_o
);

//assign state_o = state_i;

    state_t         state_s;
    state_t         op_s;


    assign state_s[0] = state_i[0] ^ state_i[4];
    assign state_s[1] = state_i[1];
    assign state_s[2] = state_i[2] ^ state_i[1];
    assign state_s[3] = state_i[3];
    assign state_s[4] = state_i[4] ^ state_i[3];

    assign op_s[0] = state_s[0] ^ ((~state_s[1]) & state_s[2]);
    assign op_s[1] = state_s[1] ^ ((~state_s[2]) & state_s[3]);
    assign op_s[2] = state_s[2] ^ ((~state_s[3]) & state_s[4]);
    assign op_s[3] = state_s[3] ^ ((~state_s[4]) & state_s[0]);
    assign op_s[4] = state_s[4] ^ ((~state_s[0]) & state_s[1]);


    assign state_o[0] = op_s[0] ^ op_s[4];
    assign state_o[1] = op_s[0] ^ op_s[1];
    assign state_o[2] = ~op_s[2];
    assign state_o[3] = op_s[2] ^ op_s[3];
    assign state_o[4] = op_s[4];


endmodule

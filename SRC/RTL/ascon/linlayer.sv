`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:    Linear Diffusion Layer                                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module linlayer
    import ascon_pack::*;
(
	input  state_t state_i,
	output state_t state_o
);

    assign state_o[0] = state_i[0] ^ {state_i[0][18:0], state_i[0][63:19]} ^ {state_i[0][27:0], state_i[0][63:28]};
    assign state_o[1] = state_i[1] ^ {state_i[1][60:0], state_i[1][63:61]} ^ {state_i[1][38:0], state_i[1][63:39]}; 
    assign state_o[2] = state_i[2] ^ {state_i[2][0], state_i[2][63:1]} ^ {state_i[2][5:0], state_i[2][63:6]}; 
    assign state_o[3] = state_i[3] ^ {state_i[3][9:0], state_i[3][63:10]} ^ {state_i[3][16:0], state_i[3][63:17]}; 
    assign state_o[4] = state_i[4] ^ {state_i[4][6:0], state_i[4][63:7]} ^ {state_i[4][40:0], state_i[4][63:41]}; 
endmodule

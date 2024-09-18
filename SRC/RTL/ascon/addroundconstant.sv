`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:    Addition of Constants                                      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

module addroundconstant
    import ascon_pack::*;
(
	input  state_t      state_i,
	input  [3:0]        round_i,
	output state_t      state_o
);
    localparam logic [11:0][7:0] CONSTANTS = {8'h4b, 8'h5a, 8'h69, 8'h78, 8'h87, 8'h96, 8'ha5, 8'hb4, 8'hc3, 8'hd2, 8'he1, 8'hf0};

    
    assign state_o[0] = state_i[0];
    assign state_o[1] = state_i[1];
    assign state_o[2] = {state_i[2][63:8], state_i[2][7:0] ^ CONSTANTS[round_i]};
    assign state_o[3] = state_i[3];
    assign state_o[4] = state_i[4];
endmodule

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:    Defines for various type.                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps



package ascon_pack;
    parameter PATCH_NULL = 2'b00;
    parameter PATCH_IF = 2'b01;
    parameter PATCH_ID = 2'b10;
    parameter PATCH_EX = 2'b11;

    // the 320-bit state S is split into five 64-bit registers words
    typedef logic [4:0][63:0] state_t;
endpackage

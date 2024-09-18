`timescale 1ns / 1ps

`include "macro_def.sv"

module ascon_decryption
    import cv32e40p_pkg::*;
    import ascon_pack::*;    
#(
    parameter FIFO_DEPTH = 2,
    parameter FIFO_ADDR_DEPTH = 1,
    parameter PATCH_WIDTH = 320,
    parameter PATCH_MEM_ADDR_WIDTH = 16,
    parameter PB_ROUNDS = 6,
    parameter HW_PERMUTATION_N = 6
) (
    input logic          clk_core_slow_i,
    input logic          clk_ascon_fast_i,
    input logic          rst_ni,

`ifdef CS
    input logic [`CS_WIDTH-1:0] cs_vector_i,
`endif
//`ifdef CS_EX
//    input logic          dec_alu_en_i,
//`endif


    input logic          fifo_push_i,
    input logic          fifo_pop_i,
    input logic [FIFO_ADDR_DEPTH-1:0] fifo_read_pointer_i,
	input logic [FIFO_ADDR_DEPTH-1:0] fifo_write_pointer_i,
    input logic          instr_valid_if_i,
    input logic          if_valid_i,
    input logic          id_valid_i,
    input logic          lsu_data_misaligned_i,
    input logic          mult_multicycle_i,
	input logic          aligner_update_state_i,

    input logic [1:0]    ctrl_transfer_insn_in_id_i,
    input logic          branch_in_ex_i,
    input logic          branch_decision_i,
    input logic          pc_set_i,

    input logic [PATCH_WIDTH + 2*`CS_WB_WIDTH + `CS_EX_WIDTH - 1:0]           patch_i,
    output logic [PATCH_MEM_ADDR_WIDTH-1:0] patch_addr_o,

    input  logic [PATCH_MEM_ADDR_WIDTH-1:0]  instr_addr_i,
    input  logic [31:0]  instr_rdata_cipher_i,
    output  logic [31:0] instr_rdata_plain_o
);


    logic        sel_state_init_s;
    logic  [1:0] sel_patch_s;
    logic        sel_addr_redirected_s;
    logic        sel_previous_instr_addr_en_s;
    logic        redirection_in_id_s;
    logic        clk_ascon_fast_cnt_init_s;
    logic        clk_ascon_fast_cnt_en_s;
    logic        apply_patch_s;
`ifdef CS_PATCH
    logic        apply_patch_cs_s;
    logic        en_apply_patch_cs_destplus8_s;
`endif

    ascon_fsm #(
    ) ascon_fsm_i (
        .clk_core_slow_i            (clk_core_slow_i),
        .rst_ni                     (rst_ni),
        .ctrl_transfer_insn_in_id_i (ctrl_transfer_insn_in_id_i),
        .branch_in_ex_i             (branch_in_ex_i),
        .branch_decision_i          (branch_decision_i),
        .pc_set_i                   (pc_set_i),
	    .redirection_in_id_i        (redirection_in_id_s),

        .sel_state_init_o           (sel_state_init_s),
        .sel_patch_o                (sel_patch_s),
        .sel_addr_redirected_o      (sel_addr_redirected_s),
        .sel_previous_instr_addr_en_o (sel_previous_instr_addr_en_s),
        .clk_ascon_fast_cnt_init_o  (clk_ascon_fast_cnt_init_s),
        .clk_ascon_fast_cnt_en_o    (clk_ascon_fast_cnt_en_s),
`ifdef CS_PATCH
        .apply_patch_cs_o           (apply_patch_cs_s),
        .en_apply_patch_cs_destplus8_o(en_apply_patch_cs_destplus8_s),
`endif
        .apply_patch_o              (apply_patch_s)
    );


    ascon_datapath #(
        .FIFO_DEPTH           (FIFO_DEPTH),
        .FIFO_ADDR_DEPTH      (FIFO_ADDR_DEPTH),
        .PATCH_MEM_ADDR_WIDTH (PATCH_MEM_ADDR_WIDTH),
        .PATCH_WIDTH          (PATCH_WIDTH),
        .PB_ROUNDS            (PB_ROUNDS),
        .HW_PERMUTATION_N     (HW_PERMUTATION_N)
    ) ascon_datapath_i (
        .clk_core_slow_i           (clk_core_slow_i),
        .clk_ascon_fast_i          (clk_ascon_fast_i),
        .rst_ni                    (rst_ni),

`ifdef CS
        .cs_vector_i                (cs_vector_i),
`endif
//`ifdef CS_EX
//        .dec_alu_en_i               (dec_alu_en_i),
//`endif


        .fifo_push_i               (fifo_push_i),
        .fifo_pop_i                (fifo_pop_i),
        .fifo_read_pointer_i       (fifo_read_pointer_i),
        .fifo_write_pointer_i      (fifo_write_pointer_i),
        .instr_valid_if_i          (instr_valid_if_i),
        .if_valid_i                (if_valid_i),
        .id_valid_i                (id_valid_i),
        .lsu_data_misaligned_i     (lsu_data_misaligned_i),
        .mult_multicycle_i         (mult_multicycle_i),
        .aligner_update_state_i    (aligner_update_state_i),

        .sel_state_init_i          (sel_state_init_s),
        .sel_patch_i               (sel_patch_s),
        .sel_addr_redirected_i     (sel_addr_redirected_s),
        .sel_previous_instr_addr_en_i (sel_previous_instr_addr_en_s),
        .clk_ascon_fast_cnt_init_i (clk_ascon_fast_cnt_init_s),
        .clk_ascon_fast_cnt_en_i   (clk_ascon_fast_cnt_en_s),
`ifdef CS_PATCH
        .apply_patch_cs_i          (apply_patch_cs_s),
        .en_apply_patch_cs_destplus8_i(en_apply_patch_cs_destplus8_s),
`endif
        .apply_patch_i             (apply_patch_s),

        .patch_i                   (patch_i),
        .patch_addr_o              (patch_addr_o),

	    .redirection_in_id_o       (redirection_in_id_s),

        .instr_addr_i              (instr_addr_i),
        .instr_rdata_cipher_i      (instr_rdata_cipher_i),
        .instr_rdata_plain_o       (instr_rdata_plain_o)
    );

endmodule

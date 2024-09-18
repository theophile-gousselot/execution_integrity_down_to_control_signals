`timescale 1ns / 1ps

`include "macro_def.sv"

module ascon_fsm
    import cv32e40p_pkg::*;
    import ascon_pack::*;      
(
    input logic         clk_core_slow_i,
    input logic         rst_ni,
        
    input logic [1:0]   ctrl_transfer_insn_in_id_i,
    input logic         branch_in_ex_i,
    input logic         branch_decision_i,
    input logic         pc_set_i,
    input logic         redirection_in_id_i,

    output logic        sel_state_init_o,
    output logic  [1:0] sel_patch_o,
    output logic        sel_addr_redirected_o,
    output logic        sel_previous_instr_addr_en_o,
    output logic        clk_ascon_fast_cnt_init_o,
    output logic        clk_ascon_fast_cnt_en_o,
`ifdef CS_PATCH
    output logic        apply_patch_cs_o,
    output logic        en_apply_patch_cs_destplus8_o,
`endif
    output logic        apply_patch_o
);

    typedef enum logic [2:0] {
        RESET,
        WAIT_DISC,
        JUMP_IN_ID_WAIT,
        JAL_TAKEN,
        JALR_TAKEN,
        REDIRECTION_TAKEN,
        BRANCH_IN_ID,
        BRANCH_TAKEN
    } ascon_fsm_states;


    ascon_fsm_states state_s, next_state_s;

`ifdef CS_PATCH
    logic apply_patch_cs_s;
    logic en_apply_patch_cs_destplus8_s;
`endif


    always_ff @(posedge clk_core_slow_i or negedge rst_ni) begin : state_s_update
        if (!rst_ni)
            state_s <= RESET;
        else 
            state_s <= next_state_s;
    end : state_s_update


    always_comb begin : next_stat_s_generation
        case (state_s)
            RESET: begin
                if (pc_set_i) begin
                    next_state_s = WAIT_DISC;
                end else begin
                    next_state_s = RESET;
                end
            end

            WAIT_DISC: begin
                case (ctrl_transfer_insn_in_id_i)
                    BRANCH_NONE: begin
                        next_state_s = WAIT_DISC;
                    end

                    BRANCH_COND: begin
                        next_state_s = BRANCH_IN_ID;
                    end

                    BRANCH_JAL: begin
                        if (pc_set_i) begin
                            next_state_s = JAL_TAKEN;
                        end else begin
                            next_state_s = JUMP_IN_ID_WAIT;
                        end
                    end

                    BRANCH_JALR: begin
                        if (pc_set_i) begin
                            if (redirection_in_id_i) begin
                                next_state_s = REDIRECTION_TAKEN;
                            end else begin
                                next_state_s = JALR_TAKEN;
                            end
                        end else begin
                            next_state_s = JUMP_IN_ID_WAIT;
                        end
                    end
                endcase
            end

            JUMP_IN_ID_WAIT: begin
                if (pc_set_i) begin
                    if (ctrl_transfer_insn_in_id_i == BRANCH_JAL) begin
                        next_state_s = JAL_TAKEN;
                    end else begin
                        if (ctrl_transfer_insn_in_id_i == BRANCH_JALR) begin
                            if (redirection_in_id_i) begin
                                next_state_s = REDIRECTION_TAKEN;
                            end else begin
                                next_state_s = JALR_TAKEN;
                            end
                        end else begin // As a jump was in decode, there is no other case than BRANCH_JAL and BRANCH_JALR in decode
                            next_state_s = JUMP_IN_ID_WAIT;
                        end
                    end
                end else begin
                    next_state_s = JUMP_IN_ID_WAIT;
                end
            end

            BRANCH_IN_ID: begin
                if (branch_in_ex_i) begin
                    if (branch_decision_i) begin
                        next_state_s = BRANCH_TAKEN;
                    end else begin
                        case (ctrl_transfer_insn_in_id_i)
                            BRANCH_NONE: begin
                                next_state_s = WAIT_DISC;
                            end

                            BRANCH_COND: begin
                                next_state_s = BRANCH_IN_ID;
                            end

                            BRANCH_JAL: begin
                                if (pc_set_i) begin
                                    next_state_s = JAL_TAKEN;
                                end else begin
                                    next_state_s = JUMP_IN_ID_WAIT;
                                end
                            end

                            BRANCH_JALR: begin
                                if (pc_set_i) begin
                                    if (redirection_in_id_i) begin
                                        next_state_s = REDIRECTION_TAKEN;
                                    end else begin
                                        next_state_s = JALR_TAKEN;
                                    end
                                end else begin
                                    next_state_s = JUMP_IN_ID_WAIT;
                                end
                            end
                        endcase
                    end
                end else begin
                    next_state_s = BRANCH_IN_ID;
                end
            end

            JAL_TAKEN, JALR_TAKEN, REDIRECTION_TAKEN, BRANCH_TAKEN: begin
                next_state_s = WAIT_DISC;
            end

            default: begin
                next_state_s = RESET;
            end
        endcase
    end : next_stat_s_generation


    always_comb begin : fsm_ouputs_generation
        sel_state_init_o          = 1'b0;
        sel_patch_o               = PATCH_NULL;
        sel_addr_redirected_o     = 1'b0;
        sel_previous_instr_addr_en_o = 1'b0;
        clk_ascon_fast_cnt_init_o = 1'b0;
        clk_ascon_fast_cnt_en_o   = 1'b1;
        apply_patch_o             = 1'b0;
`ifdef CS_PATCH
        apply_patch_cs_s          = 1'b0;
        en_apply_patch_cs_destplus8_s = 1'b0;
`endif

        case (state_s)
            RESET: begin
                sel_state_init_o          = 1'b1;
                clk_ascon_fast_cnt_init_o = 1'b1;
                clk_ascon_fast_cnt_en_o   = 1'b0;
            end

            JAL_TAKEN: begin
                sel_patch_o               = PATCH_ID;
                apply_patch_o             = 1'b1;
`ifdef CS_PATCH
                apply_patch_cs_s          = 1'b1;
`endif
            end

            JALR_TAKEN: begin
                sel_patch_o               = PATCH_IF;
                apply_patch_o             = 1'b1;
`ifdef CS_PATCH
                apply_patch_cs_s          = 1'b1;
`endif
            end

            REDIRECTION_TAKEN: begin
                sel_patch_o               = PATCH_IF;
                apply_patch_o             = 1'b1;
                sel_previous_instr_addr_en_o = 1'b1;
`ifdef CS_PATCH
                apply_patch_cs_s          = 1'b1;
`endif
            end

            BRANCH_TAKEN: begin
                sel_patch_o               = PATCH_EX;
                apply_patch_o             = 1'b1;
`ifdef CS_PATCH
                apply_patch_cs_s          = 1'b1;
                en_apply_patch_cs_destplus8_s = 1'b1;
`endif
            end

            default:;
        endcase
        if (next_state_s == REDIRECTION_TAKEN) begin
            sel_addr_redirected_o     = 1'b1;
        end
    end : fsm_ouputs_generation

`ifdef CS_PATCH
    always_ff @(posedge clk_core_slow_i or negedge rst_ni) begin : apply_cs_patch_delay_one_cycle
        if (!rst_ni) begin
            apply_patch_cs_o <= 1'b0;
            en_apply_patch_cs_destplus8_o <= 1'b0;
        end else begin
            apply_patch_cs_o <= apply_patch_cs_s;
            en_apply_patch_cs_destplus8_o <= en_apply_patch_cs_destplus8_s;
        end
    end : apply_cs_patch_delay_one_cycle

`endif
endmodule

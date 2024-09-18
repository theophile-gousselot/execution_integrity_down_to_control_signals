import os
import riscv_control_signals_combinational
from riscv_control_signals_combinational import instr2fct7_3_opcode

CS_VECTOR_ARCH_LIB = [{}]

TEST_CS_FROM_DECODER_ONLY = False

# SET OF CONFIGS TO TEST ALL SIGNALS FROM DECODER, FROM ALL OR SPECIFIC STAGES (ID/EX/WB)
if TEST_CS_FROM_DECODER_ONLY:
    CS_VECTOR_ARCH_LIB.append({'id': ['alu_operator', 'alu_en', 'imm_a_mux_sel', 'imm_b_mux_sel', 'alu_op_a_mux_sel', 'alu_op_b_mux_sel', 'alu_op_c_mux_sel'], 'ex': ['alu_operator', 'alu_en']})
    CS_VECTOR_ARCH_LIB.append({'id': ['mult_en', 'mult_operator', 'mult_signed_mode', 'ctrl_transfer_target_mux_sel', 'ctrl_transfer_insn_in_dec', 'ctrl_transfer_insn_in_id'], 'ex': ['mult_en', 'mult_operator', 'mult_signed_mode']})
    CS_VECTOR_ARCH_LIB.append({'id': ['rega_used_dec', 'regb_used_dec', 'regc_used_dec', 'regfile_alu_we_dec', 'regfile_alu_we', 'regfile_mem_we', 'csr_status', 'csr_access'], 'ex': ['regfile_mem_we', 'regfile_alu_we', 'csr_access'], 'wb': ['regfile_mem_we']})
    CS_VECTOR_ARCH_LIB.append({'id': ['data_type', 'data_sign_ext', 'data_we', 'data_req'], 'ex': ['data_type', 'data_sign_ext', 'data_we', 'data_req'], 'wb': ['data_type', 'data_sign_ext', 'data_we']})

    CS_VECTOR_ARCH_LIB.append({'ex': ['alu_en', 'alu_operator', 'csr_access', 'data_req', 'mult_en', 'mult_operator', 'mult_signed_mode', 'regfile_alu_we']})
    CS_VECTOR_ARCH_LIB.append({'ex': ['alu_en', 'alu_operator', 'csr_access', 'data_req', 'mult_en', 'mult_operator', 'mult_signed_mode', 'regfile_alu_we'], 'wb': ['regfile_mem_we', 'data_sign_ext', 'data_type', 'data_we']})
    CS_VECTOR_ARCH_LIB.append({'wb': ['regfile_mem_we', 'data_sign_ext', 'data_type', 'data_we']})
    CS_VECTOR_ARCH_LIB.append({'id': ['alu_op_a_mux_sel', 'alu_op_b_mux_sel', 'alu_op_c_mux_sel', 'csr_status', 'ctrl_transfer_insn_in_dec', 'ctrl_transfer_insn_in_id', 'ctrl_transfer_target_mux_sel', 'imm_a_mux_sel', 'imm_b_mux_sel', 'rega_used_dec', 'regb_used_dec', 'regc_mux', 'regc_used_dec', 'regfile_alu_we_dec']})
    CS_VECTOR_ARCH_LIB.append({'id': ['alu_op_a_mux_sel', 'alu_op_b_mux_sel', 'alu_op_c_mux_sel', 'csr_status', 'ctrl_transfer_insn_in_dec', 'ctrl_transfer_insn_in_id', 'ctrl_transfer_target_mux_sel', 'imm_a_mux_sel', 'imm_b_mux_sel', 'rega_used_dec', 'regb_used_dec', 'regc_mux', 'regc_used_dec', 'regfile_alu_we_dec'], 'wb': ['regfile_mem_we', 'data_sign_ext', 'data_type', 'data_we']})

else:
# SET OF CONFIGS TO TEST ALL SIGNALS, FROM ALL OR SPECIFIC STAGES (ID/EX/WB)
    CS_VECTOR_ARCH_LIB.append({'id': ['alu_operator', 'alu_en', 'imm_a_mux_sel', 'imm_b_mux_sel', 'alu_op_a_mux_sel', 'alu_op_b_mux_sel', 'alu_op_c_mux_sel'], 'ex': ['alu_operator', 'alu_en']})
    CS_VECTOR_ARCH_LIB.append({'id': ['mult_en', 'mult_operator', 'mult_signed_mode', 'ctrl_transfer_target_mux_sel', 'ctrl_transfer_insn_in_dec', 'ctrl_transfer_insn_in_id'], 'ex': ['mult_en', 'mult_operator', 'mult_signed_mode']})
    CS_VECTOR_ARCH_LIB.append({'id': ['rega_used_dec', 'regb_used_dec', 'regc_mux', 'regc_used_dec', 'regfile_alu_we_dec', 'regfile_alu_we', 'regfile_mem_we', 'csr_status', 'csr_access'], 'ex': ['regfile_mem_we', 'regfile_alu_we', 'csr_access'], 'wb': ['regfile_mem_we']})
    CS_VECTOR_ARCH_LIB.append({'id': ['data_type', 'data_sign_ext', 'data_we', 'data_req'], 'ex': ['data_type', 'data_sign_ext', 'data_we', 'data_req'], 'wb': ['data_type', 'data_sign_ext', 'data_we']})

    CS_VECTOR_ARCH_LIB.append({'id': ['imm_b']})
    CS_VECTOR_ARCH_LIB.append({'id': ['branch_in_ex'], 'ex': ['branch_in_ex']})
    CS_VECTOR_ARCH_LIB.append({'id': ['regfile_addr_ra', 'regfile_addr_rb', 'regfile_alu_waddr'], 'ex': ['regfile_alu_waddr']})
    CS_VECTOR_ARCH_LIB.append({'wb': ['regfile_mem_waddr']})
    CS_VECTOR_ARCH_LIB.append({'id': ['regfile_mem_waddr'], 'ex': ['regfile_mem_waddr'], 'wb': ['regfile_mem_waddr']})


GEN_INCLUDE_IN_CV32E40P_SV_FILES = ['id_from_decoder', 'id_from_id', 'ex', 'wb_from_ex', 'wb_from_lsu']
VALID_SRC = ['instr_in_decoder', 'instr_in_id', 'cs_in_id']


SIGNAL_DESCRIPTION = {}
SIGNAL_DESCRIPTION['alu_bmask_a_mux_sel']          = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 119, 'stages': ['id'], 'reset_val': 0b1} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['alu_bmask_b_mux_sel']          = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 118, 'stages': ['id'], 'reset_val': 0b1} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['alu_en']                       = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 117, 'stages': ['id', 'ex'], 'we_signals': True, 'reset_val': 0b0, 'id_invalid_ex_ready': 0b1, 'sv_names': {'id_from_decoder': 'alu_en_o', 'ex': 'alu_en_ex'}}
SIGNAL_DESCRIPTION['alu_op_a_mux_sel']             = {'used': True, 'src': 'instr_in_decoder', 'width': 3, 'position_dec_tab': 114, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'alu_op_a_mux_sel_o'}}
SIGNAL_DESCRIPTION['alu_op_b_mux_sel']             = {'used': True, 'src': 'instr_in_decoder', 'width': 3, 'position_dec_tab': 111, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'alu_op_b_mux_sel_o'}}
SIGNAL_DESCRIPTION['alu_op_c_mux_sel']             = {'used': True, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 109, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'alu_op_c_mux_sel_o'}}
SIGNAL_DESCRIPTION['alu_operator']                 = {'used': True, 'src': 'instr_in_decoder', 'width': 7, 'position_dec_tab': 102, 'stages': ['id', 'ex'], 'reset_val': 0b11, 'id_invalid_ex_ready': 0b11, 'depends': ['alu_en'], 'ex_en':'alu_en', 'sv_names': {'id_from_decoder': 'alu_operator_o', 'ex': 'alu_operator_ex'}}
SIGNAL_DESCRIPTION['alu_vec_mode']                 = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 100} # useful only if FPU
SIGNAL_DESCRIPTION['apu_en']                       = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 99, 'we_signals': True} # useful only if FPU
SIGNAL_DESCRIPTION['apu_lat']                      = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 97} # useful only if FPU
SIGNAL_DESCRIPTION['apu_op']                       = {'used': False, 'src': 'instr_in_decoder', 'width': 6, 'position_dec_tab': 91} # useful only if FPU
SIGNAL_DESCRIPTION['atop']                         = {'used': False, 'src': 'instr_in_decoder', 'width': 6, 'position_dec_tab': 85} # useful only if A (ATOMIC)
SIGNAL_DESCRIPTION['bmask_a_mux']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 84} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['bmask_b_mux']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 82} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['csr_access']                   = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 81, 'stages': ['id', 'ex'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'csr_access_o', 'ex': 'csr_access_ex'}}
SIGNAL_DESCRIPTION['csr_op']                       = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 79, 'stages': ['id', 'ex'], 'we_signals': True, 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0} #problem csr_status_i                                                                                                                                                                                                  = 1                      = > flush_ex = > halt_id = > id_valid = 0 = > id_invalid_ex_ready (but in soft modelization id_invalid do not depend on other thing that load_stall...)
SIGNAL_DESCRIPTION['csr_status']                   = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 78, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'csr_status_o'}}
SIGNAL_DESCRIPTION['ctrl_transfer_insn_in_dec']    = {'used': True, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 76, 'stages': ['id'], 'sv_names': {'id_from_decoder': 'ctrl_transfer_insn_in_dec_o'}}
SIGNAL_DESCRIPTION['ctrl_transfer_insn_in_id']     = {'used': True, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 74, 'stages': ['id'], 'we_signals': True, 'sv_names': {'id_from_decoder': 'ctrl_transfer_insn_in_id_o'}}
SIGNAL_DESCRIPTION['ctrl_transfer_target_mux_sel'] = {'used': True, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 72, 'stages': ['id'], 'reset_val': 0b01, 'sv_names': {'id_from_decoder': 'ctrl_transfer_target_mux_sel_o'}}
SIGNAL_DESCRIPTION['data_load_event']              = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 71} # useful only if PULP_CLUSTER
SIGNAL_DESCRIPTION['data_reg_offset']              = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 69} # cte to 0
SIGNAL_DESCRIPTION['data_req']                     = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 68, 'stages': ['id', 'ex'], 'we_signals': True, 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'sv_names': {'id_from_decoder': 'data_req_o', 'ex': 'data_req_ex'}}
SIGNAL_DESCRIPTION['data_sign_ext']                = {'used': True, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 66, 'stages': ['id', 'ex', 'wb'], 'reset_val': 0b0, 'depends': ['data_req'], 'ex_en': 'data_req', 'wb_en': 'data_req', 'id_invalid_ex_ready': 0b0, 'sv_names': {'id_from_decoder': 'data_sign_extension_o', 'ex': 'data_sign_ext_ex', 'wb_from_lsu': 'data_sign_ext_q'}}
SIGNAL_DESCRIPTION['data_type']                    = {'used': True, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 64, 'stages': ['id', 'ex', 'wb'], 'reset_val': 0b0, 'depends': ['data_req'], 'ex_en': 'data_req', 'wb_en': 'data_req', 'id_invalid_ex_ready': 0b0, 'sv_names': {'id_from_decoder': 'data_type_o', 'ex': 'data_type_ex', 'wb_from_lsu': 'data_type_q'}}
SIGNAL_DESCRIPTION['data_we']                      = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 63, 'stages': ['id', 'ex', 'wb'], 'reset_val': 0b0, 'depends': ['data_req'], 'ex_en': 'data_req', 'wb_en': 'data_req', 'id_invalid_ex_ready': 0b0, 'sv_names': {'id_from_decoder': 'data_we_o', 'ex': 'data_we_ex', 'wb_from_lsu': 'data_we_q'}}
SIGNAL_DESCRIPTION['dret_dec']                     = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 62, 'stages': ['id']} # useful only if debug mode
SIGNAL_DESCRIPTION['dret_insn_dec']                = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 61, 'stages': ['id']} # useful only if debug mode
SIGNAL_DESCRIPTION['ebrk_insn_dec']                = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 60, 'stages': ['id']} # useful only if debug mode
SIGNAL_DESCRIPTION['ecall_insn_dec']               = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 59, 'stages': ['id']} # useful only if debug mode
SIGNAL_DESCRIPTION['fencei_insn_dec']              = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 58, 'stages': ['id']} # useful only if debug mode
SIGNAL_DESCRIPTION['fp_rnd_mode']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 3, 'position_dec_tab': 55, 'stages': ['id']} # useful only if FPU
SIGNAL_DESCRIPTION['fpu_dst_fmt']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 3, 'position_dec_tab': 52, 'stages': ['id']} # useful only if FPU
SIGNAL_DESCRIPTION['fpu_int_fmt']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 50, 'stages': ['id']} # useful only if FPU
SIGNAL_DESCRIPTION['fpu_src_fmt']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 3, 'position_dec_tab': 47, 'stages': ['id']} # useful only if FPU
SIGNAL_DESCRIPTION['hwlp_cnt_mux_sel']             = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 46, 'stages': ['id']} # useful only if HWLP
SIGNAL_DESCRIPTION['hwlp_start_mux_sel']           = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 45, 'stages': ['id']} # useful only if HWLP
SIGNAL_DESCRIPTION['hwlp_target_mux_sel']          = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 44, 'stages': ['id']} # useful only if HWLP
SIGNAL_DESCRIPTION['hwlp_we_int']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 3, 'position_dec_tab': 41, 'stages': ['id']} # useful only if HWLP
SIGNAL_DESCRIPTION['illegal_insn_dec']             = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 40} # not useful to include illegal insn as it must be always bi high, except under attack
SIGNAL_DESCRIPTION['imm_a_mux_sel']                = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 39, 'stages': ['id'], 'reset_val': 0b1, 'sv_names': {'id_from_decoder': 'imm_a_mux_sel_o'}}
SIGNAL_DESCRIPTION['imm_b_mux_sel']                = {'used': True, 'src': 'instr_in_decoder', 'width': 4, 'position_dec_tab': 35, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'imm_b_mux_sel_o'}}
SIGNAL_DESCRIPTION['is_clpx']                      = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 34} # cte to 0
SIGNAL_DESCRIPTION['is_subrot']                    = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 33} # cte to 0
SIGNAL_DESCRIPTION['mret_dec']                     = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 32} # useful only if debug mode
SIGNAL_DESCRIPTION['mret_insn_dec']                = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 31} # useful only if debug mode
SIGNAL_DESCRIPTION['mult_dot_en']                  = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 30, 'we_signals': True} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['mult_dot_signed']              = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 28} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['mult_imm_mux']                 = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 27, 'stages': ['id'], 'reset_val': 0b0} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['mult_en']                      = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 26, 'stages': ['id', 'ex'], 'we_signals': True, 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'sv_names': {'id_from_decoder': 'mult_int_en_o', 'ex': 'mult_en_ex'}}
SIGNAL_DESCRIPTION['mult_operator']                = {'used': True, 'src': 'instr_in_decoder', 'width': 3, 'position_dec_tab': 23, 'stages': ['id', 'ex'], 'reset_val': 0b10, 'id_invalid_ex_ready': 0b10, 'depends': ['mult_en'], 'ex_en':'mult_en', 'sv_names': {'id_from_decoder': 'mult_operator_o', 'ex': 'mult_operator_ex'}}
SIGNAL_DESCRIPTION['mult_sel_subword']             = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 22} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['mult_signed_mode']             = {'used': True, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 20, 'stages': ['id', 'ex'], 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'depends': ['mult_en'], 'ex_en':'mult_en', 'sv_names': {'id_from_decoder': 'mult_signed_mode_o', 'ex': 'mult_signed_mode_ex'}}
SIGNAL_DESCRIPTION['prepost_useincr']              = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 19} # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['rega_used_dec']                = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 18, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'rega_used_o'}}
SIGNAL_DESCRIPTION['regb_used_dec']                = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 17, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'regb_used_o'}}
SIGNAL_DESCRIPTION['regc_mux']                     = {'used': False, 'src': 'instr_in_decoder', 'width': 2, 'position_dec_tab': 15, 'stages': ['id'], 'reset_val': 0b11, 'sv_names': {'id_from_decoder': 'regc_mux_o'}} # cte to 0b11 use if FPU
SIGNAL_DESCRIPTION['regc_used_dec']                = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 14, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'regc_used_o'}}
SIGNAL_DESCRIPTION['regfile_alu_waddr_mux_sel']    = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 13, 'stages': ['id'], 'reset_val': 0b1} # cte to 1 # useful only if PULP_XPULP
SIGNAL_DESCRIPTION['regfile_alu_we_dec']           = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 12, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_decoder': 'regfile_alu_we_dec_o'}} # (same as regfile_alu_we, but propagated only to controller) alu we to detect load_stall
SIGNAL_DESCRIPTION['regfile_alu_we']               = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 11, 'stages': ['id', 'ex'], 'we_signals': True, 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'sv_names': {'id_from_decoder': 'regfile_alu_we_o', 'ex': 'regfile_alu_we_ex'}}
SIGNAL_DESCRIPTION['regfile_fp_a']                 = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 10} # useful only if FPU
SIGNAL_DESCRIPTION['regfile_fp_b']                 = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 9} # useful only if FPU
SIGNAL_DESCRIPTION['regfile_fp_c']                 = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 8} # useful only if FPU
SIGNAL_DESCRIPTION['regfile_fp_d']                 = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 7} # useful only if FPU
SIGNAL_DESCRIPTION['regfile_mem_we']               = {'used': True, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 6, 'stages': ['id', 'ex', 'wb'], 'we_signals': True, 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'ex_invalid_wb_ready': 0b0, 'sv_names': {'id_from_decoder': 'regfile_mem_we_o', 'ex': 'regfile_we_ex', 'wb_from_ex': 'regfile_we_lsu'}} # regfile_mem_we -> we_a
SIGNAL_DESCRIPTION['scalar_replication']           = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 5} # useful only if FPU
SIGNAL_DESCRIPTION['scalar_replication_c']         = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 4} # useful only if FPU
SIGNAL_DESCRIPTION['uret_dec']                     = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 3} # useful only if uret
SIGNAL_DESCRIPTION['uret_insn_dec']                = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 2} # useful only if uret
SIGNAL_DESCRIPTION['wfi_insn_dec']                 = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 1} # wfi
SIGNAL_DESCRIPTION['null']                         = {'used': False, 'src': 'instr_in_decoder', 'width': 1, 'position_dec_tab': 0}
SIGNAL_DESCRIPTION['imm_a']                        = {'used': True, 'src': 'cs_in_id', 'width': 32, 'stages': ['id'], 'reset_val': 0b0, 'depends': ['imm_a_mux_sel'], 'sv_names': {'id_from_id': 'imm_a'}}
SIGNAL_DESCRIPTION['imm_b']                        = {'used': True, 'src': 'cs_in_id', 'width': 32, 'stages': ['id'], 'reset_val': 0b0, 'depends': ['imm_b_mux_sel'], 'sv_names': {'id_from_id': 'imm_b'}}
SIGNAL_DESCRIPTION['regfile_alu_waddr']            = {'used': True, 'src': 'instr_in_id', 'width': 6, 'stages': ['id', 'ex'], 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'depends': ['regfile_alu_we'], 'ex_en':'regfile_alu_we', 'sv_names': {'id_from_id': 'regfile_alu_waddr_id', 'ex': 'regfile_alu_waddr_ex'}} # Register Destination (for ALU port b) width                                                             = 6 for fp compatiblity?
SIGNAL_DESCRIPTION['regfile_mem_waddr']            = {'used': True, 'src': 'instr_in_id', 'width': 6, 'stages': ['id', 'ex', 'wb'], 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'depends': ['regfile_mem_we'], 'ex_en':'regfile_mem_we', 'wb_en': 'regfile_mem_we', 'sv_names': {'id_from_id': 'regfile_waddr_id', 'ex': 'regfile_waddr_ex', 'wb_from_ex': 'regfile_waddr_lsu'}} # Register Destination (for MEM port a) width = 6 for fp compatiblity?
SIGNAL_DESCRIPTION['regfile_addr_ra']              = {'used': True, 'src': 'instr_in_id', 'width': 6, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_id': 'regfile_addr_ra_id'}} # Register Source
SIGNAL_DESCRIPTION['regfile_addr_rb']              = {'used': True, 'src': 'instr_in_id', 'width': 6, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_id': 'regfile_addr_rb_id'}} # Register Source
SIGNAL_DESCRIPTION['regfile_addr_rc']              = {'used': False, 'src': 'instr_in_id', 'width': 6, 'stages': ['id'], 'reset_val': 0b0, 'sv_names': {'id_from_id': 'regfile_addr_rc_id'}} # useful only if FPU
SIGNAL_DESCRIPTION['branch_in_ex']                 = {'used': True, 'src': 'cs_in_id', 'width': 1, 'stages': ['id', 'ex'], 'we_signals': True, 'reset_val': 0b0, 'id_invalid_ex_ready': 0b0, 'depends': ['ctrl_transfer_insn_in_id'], 'sv_names': {'id_from_id': 'branch_in_ex_id', 'ex': 'branch_in_ex'}}



# todo said that 'regfile_alu_waddr' is 5 width then assign cs_vector_o = {regfile_alu_waddr[4:0]}


CS_PATH = f"SRC/PROGRAM_TOOLS/CONTROL_SIGNALS/control_signals.csv"



class Macro_sv:
    def __init__(self):
        self.gen_sv_control_signal_assign()


    def write_file_if_not_exist_or_diff(self, path, string):
        write_file = True
        if os.path.isfile(path):
            with open(path, "r") as file:
                file_content = file.read()
            if string == file_content:
                write_file = False

        if write_file:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w") as file:
                file.write(string)


    def gen_sv_control_signal_assign(self):
        # Build a dict(sv file concerns) of dict (cs_vector_arch_id) of list(control signal)
        cs_assign = {}
        cs_assign_width = {}
        for sv_file in GEN_INCLUDE_IN_CV32E40P_SV_FILES:
            cs_assign[sv_file] = {1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [], 8: [], 9: []}
            cs_assign_width[sv_file] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0}

            for cs_vector_arch_id in range(1, len(CS_VECTOR_ARCH_LIB)):
                if sv_file[:2] in CS_VECTOR_ARCH_LIB[cs_vector_arch_id]:

                    for cs in CS_VECTOR_ARCH_LIB[cs_vector_arch_id][sv_file[:2]]:
                        if sv_file in SIGNAL_DESCRIPTION[cs]['sv_names']:
                            cs_assign[sv_file][cs_vector_arch_id].append(SIGNAL_DESCRIPTION[cs]['sv_names'][sv_file])
                            cs_assign_width[sv_file][cs_vector_arch_id] += SIGNAL_DESCRIPTION[cs]['width']

        # Build string `ifdef... only when there are signals (see if 8 lines below)
        cs_assign_str = {}
        for sv_file in GEN_INCLUDE_IN_CV32E40P_SV_FILES:
            cs_assign_str[sv_file] = ''
            for cs_vector_arch_id in range(1, len(CS_VECTOR_ARCH_LIB)):
                if cs_assign[sv_file][cs_vector_arch_id] != []:
                    cs_assign_str[sv_file] += f"`ifdef CS{cs_vector_arch_id}\n" + f"assign cs_vector_{sv_file}_{'s' if sv_file in ['id_from_id', 'ex'] else 'o'} = " + "{" + ', '.join(cs_assign[sv_file][cs_vector_arch_id]) + "};\n`endif\n"

        # Build string to merge wb signal from cv32e40p_ex_stage.sv file and cv32e40p_load_store_unit.sv
        cs_assign_wb_merge_from_ex_and_lsu_str = ''
        for cs_vector_arch_id in range(1, len(CS_VECTOR_ARCH_LIB)):
            if cs_assign['wb_from_ex'][cs_vector_arch_id] != []:
                if cs_assign['wb_from_lsu'][cs_vector_arch_id] != []:
                    cs_assign_wb_merge_from_ex_and_lsu_str += f"`ifdef CS{cs_vector_arch_id}\n" + "assign cs_vector_wb_s = {cs_vector_wb_from_ex_s, cs_vector_wb_from_lsu_s};\n`endif\n"
                else:
                    cs_assign_wb_merge_from_ex_and_lsu_str += f"`ifdef CS{cs_vector_arch_id}\n" + "assign cs_vector_wb_s = {cs_vector_wb_from_ex_s};\n`endif\n"
            else:
                if cs_assign['wb_from_lsu'][cs_vector_arch_id] != []:
                    cs_assign_wb_merge_from_ex_and_lsu_str += f"`ifdef CS{cs_vector_arch_id}\n" + "assign cs_vector_wb_s = {cs_vector_wb_from_lsu_s};\n`endif\n"

        # Build string to merge id signal from cv32e40p_decoder.sv file and cv32e40p_id_stage.sv
        cs_assign_id_merge_from_decoder_and_id_str = ''
        for cs_vector_arch_id in range(1, len(CS_VECTOR_ARCH_LIB)):
            if cs_assign['id_from_decoder'][cs_vector_arch_id] != []:
                if cs_assign['id_from_id'][cs_vector_arch_id] != []:
                    cs_assign_id_merge_from_decoder_and_id_str += f"`ifdef CS{cs_vector_arch_id}\n" + "assign cs_vector_id_o = {cs_vector_id_from_decoder_s, cs_vector_id_from_id_s};\n`endif\n"
                else:
                    cs_assign_id_merge_from_decoder_and_id_str += f"`ifdef CS{cs_vector_arch_id}\n" + "assign cs_vector_id_o = {cs_vector_id_from_decoder_s};\n`endif\n"
            else:
                if cs_assign['id_from_id'][cs_vector_arch_id] != []:
                    cs_assign_id_merge_from_decoder_and_id_str += f"`ifdef CS{cs_vector_arch_id}\n" + "assign cs_vector_id_o = {cs_vector_id_from_id_s};\n`endif\n"


        # Build macro_def string
        macro_def_str = '`define STRINGIFY(x) `"x`"\n'
        for cs_vector_arch_id in range(1, len(CS_VECTOR_ARCH_LIB)):
            macro_def_str += f"\n`ifdef CS{cs_vector_arch_id}\n`define CS {cs_vector_arch_id}\n"
            if cs_assign_width['id_from_decoder'][cs_vector_arch_id] + cs_assign_width['id_from_id'][cs_vector_arch_id] != 0:
                macro_def_str += f"`define CS_ID\n`define CS_ID_WIDTH {cs_assign_width['id_from_decoder'][cs_vector_arch_id] + cs_assign_width['id_from_id'][cs_vector_arch_id]}\n"
            if cs_assign_width['id_from_decoder'][cs_vector_arch_id] != 0:
                macro_def_str += f"`define CS_ID_DECODER\n`define CS_ID_DECODER_WIDTH {cs_assign_width['id_from_decoder'][cs_vector_arch_id]}\n"
            if cs_assign_width['id_from_id'][cs_vector_arch_id] != 0:
                macro_def_str += f"`define CS_ID_ID\n`define CS_ID_ID_WIDTH {cs_assign_width['id_from_id'][cs_vector_arch_id]}\n"
            if cs_assign_width['ex'][cs_vector_arch_id] != 0:
                macro_def_str += f"`define CS_EX\n`define CS_EX_WIDTH {cs_assign_width['ex'][cs_vector_arch_id]}\n"
            if cs_assign_width['wb_from_ex'][cs_vector_arch_id] + cs_assign_width['wb_from_lsu'][cs_vector_arch_id] != 0:
                macro_def_str += f"`define CS_WB\n`define CS_WB_WIDTH {cs_assign_width['wb_from_ex'][cs_vector_arch_id] + cs_assign_width['wb_from_lsu'][cs_vector_arch_id]}\n"
            if cs_assign_width['wb_from_ex'][cs_vector_arch_id] != 0:
                macro_def_str += f"`define CS_WB_EX\n`define CS_WB_EX_WIDTH {cs_assign_width['wb_from_ex'][cs_vector_arch_id]}\n"
            if cs_assign_width['wb_from_lsu'][cs_vector_arch_id] != 0:
                macro_def_str += f"`define CS_WB_LSU\n`define CS_WB_LSU_WIDTH {cs_assign_width['wb_from_lsu'][cs_vector_arch_id]}\n"
            macro_def_str += "`endif\n"

        macro_def_str += "\n`ifdef CS_WB\n`define CS_PATCH\n`define CS_CYCPLUS1\n`define CS_CYCPLUS2\n`endif\n"
        macro_def_str += "\n`ifdef CS_EX\n`define CS_PATCH\n`define CS_CYCPLUS1\n`endif\n"
        macro_def_str += "\n`ifndef CS_ID_WIDTH\n`define CS_ID_WIDTH 0\n`endif\n"
        macro_def_str += "\n`ifndef CS_EX_WIDTH\n`define CS_EX_WIDTH 0\n`endif\n"
        macro_def_str += "\n`ifndef CS_WB_WIDTH\n`define CS_WB_WIDTH 0\n`endif\n"
        macro_def_str += "\n`define CS_WIDTH `CS_ID_WIDTH + `CS_EX_WIDTH + `CS_WB_WIDTH"


        for sv_file in cs_assign_str.keys():
            file_path = f"../../OBJ/RTL/{sv_file}_cs_assign.sv"
            self.write_file_if_not_exist_or_diff(file_path, cs_assign_str[sv_file])
        self.write_file_if_not_exist_or_diff(f"../../OBJ/RTL/wb_merge_cs_assign.sv", cs_assign_wb_merge_from_ex_and_lsu_str)
        self.write_file_if_not_exist_or_diff(f"../../OBJ/RTL/id_merge_cs_assign.sv", cs_assign_id_merge_from_decoder_and_id_str)
        self.write_file_if_not_exist_or_diff(f"../../OBJ/RTL/macro_def.sv", macro_def_str)






class Control_signals:
    def __init__(self, cs_vector_arch_id):
        self.cs_vector_arch_id = cs_vector_arch_id
        self.SIGNAL_DESCRIPTION = SIGNAL_DESCRIPTION
        self.CS_VECTOR_ARCH = CS_VECTOR_ARCH_LIB[cs_vector_arch_id]
        self.gen_signal_set()
        self.CS_VECTOR_DESCRIPTION = self.gen_cs_vector_description()
        self.DEASSERT_WE_MASK = self.gen_deassert_we_mask()
        self.CS_VECTOR_RESET = self.gen_cs_vector_reset()
        self.CS_VECTOR_WIDTH = self.count_cs_vector_width()
        self.CS_VECTOR_ALL_ONE = (1 << self.CS_VECTOR_WIDTH) - 1
        self.CS_VECTOR_ID_INVALID_EX_READY, self.MASK_CS_VECTOR_ID_INVALID_EX_READY = self.gen_mask_cs_vector_stage_invalid_next_stage_ready('id_invalid_ex_ready')
        self.CS_VECTOR_EX_INVALID_WB_READY, self.MASK_CS_VECTOR_EX_INVALID_WB_READY = self.gen_mask_cs_vector_stage_invalid_next_stage_ready('ex_invalid_wb_ready')
        self.CS_VECTOR_DESCRIPTION = self.gen_cs_vector_description() # todo remove doublon
        self.WIDTH = self.count_all_stage_width()

        self.PATCH_CS_HEX_WIDTH = self.count_patch_cs_hex_width()
        self.read_decoding_table(CS_PATH)

    def stats_on_cs(self):
        cs_used, cs_not_used = 0, 0
        cs_used_width, cs_not_used_width = 0, 0
        cs_used_id, cs_used_ex, cs_used_wb = 0, 0, 0
        cs_used_id_width, cs_used_ex_width, cs_used_wb_width = 0, 0, 0
        cs_used_id_names, cs_used_ex_names, cs_used_wb_names = [], [], []
        for cs in self.SIGNAL_DESCRIPTION.keys():
            if self.SIGNAL_DESCRIPTION[cs]['used']:
                cs_used += 1
                cs_used_width += self.SIGNAL_DESCRIPTION[cs]['width']
                if self.SIGNAL_DESCRIPTION[cs]['stages'] == ['id']:
                    cs_used_id += 1
                    cs_used_id_width += self.SIGNAL_DESCRIPTION[cs]['width']
                    cs_used_id_names.append(cs)
                elif self.SIGNAL_DESCRIPTION[cs]['stages'] == ['id', 'ex']:
                    cs_used_ex += 1
                    cs_used_ex_width += self.SIGNAL_DESCRIPTION[cs]['width']
                    cs_used_ex_names.append(cs)
                elif self.SIGNAL_DESCRIPTION[cs]['stages'] == ['id', 'ex', 'wb']:
                    cs_used_wb += 1
                    cs_used_wb_width += self.SIGNAL_DESCRIPTION[cs]['width']
                    cs_used_wb_names.append(cs)
                else:
                    raise ValueError(f'Invalid stages for {cs}.')

            else:
                cs_not_used += 1
                cs_not_used_width += self.SIGNAL_DESCRIPTION[cs]['width']
        print(f"Number of CS:          {cs_used + cs_not_used:>4}")
        print(f"Width of CS:           {cs_used_width + cs_not_used_width:>4} bits")
        print(f"Number of CS used:     {cs_used:>4}")
        print(f"Width of CS used:      {cs_used_width:>4} bits")
        print(f"Number of CS not used: {cs_not_used:>4}")
        print(f"Width of CS not used:  {cs_not_used_width:>4} bits")
        print(f"\n#### ABOUT USED SIGNALS ####")
        print(f"### CS in ID only:")
        print(f"Number:    { cs_used_id:>4}")
        print(f"Width:     { cs_used_id_width:>4} bits")
        print(f"({cs_used_id_names})")
        print(f"\n### CS in ID/EX only:")
        print(f"Number:    { cs_used_ex:>4}")
        print(f"Width:     { cs_used_ex_width:>4} bits")
        print(f"({cs_used_ex_names})")
        print(f"\n### CS in ID/EX/WB:")
        print(f"Number:    { cs_used_wb:>4}")
        print(f"Width:     { cs_used_wb_width:>4} bits")
        print(f"({cs_used_wb_names})")

    def count_patch_cs_hex_width(self):
        width = 0
        if 'wb' in self.CS_VECTOR_ARCH.keys():
            width += 2*self.WIDTH['wb'] 
        if 'ex' in self.CS_VECTOR_ARCH.keys():
            width += self.WIDTH['ex'] 
        width_hex = ((width - 1)//4) + 1
        return(width_hex)

    def count_all_stage_width(self):
        width_dict = {}
        for stage in ['id', 'ex', 'wb']:
            width_dict[stage] = self.count_stage_width(stage)
        return width_dict


    def extract_cs_from_decoder_lut(self, fct7_3_opcode, cs_name):
        return (self.cs_decoder[fct7_3_opcode]['cs_vector'] >> self.SIGNAL_DESCRIPTION[cs_name]['position_dec_tab']) & ((1 << self.SIGNAL_DESCRIPTION[cs_name]['width']) - 1)

    def extract(self, integer, position, width):
        return ((integer >> position) & ((1 << width) - 1))


    def rec_add_dependant_signals(self, cs):
        if cs not in self.SIGNAL_SET:
            self.SIGNAL_SET.append(cs) # signal set will be reverse, thus dependant signals will be before cs
            if 'depends' in self.SIGNAL_DESCRIPTION[cs].keys():
                for dependant_cs in self.SIGNAL_DESCRIPTION[cs]['depends']:
                    self.rec_add_dependant_signals(dependant_cs)

    def gen_signal_set(self):
        self.SIGNAL_SET = []
        for stage in self.CS_VECTOR_ARCH.keys():
            for cs in self.CS_VECTOR_ARCH[stage]:
                # check signal reach this stage in microarchitecture (e.g., alu_operator is usefull in execute
                # stage, thus it is accessible in decode and excute but not in write-back
                if stage not in self.SIGNAL_DESCRIPTION[cs]['stages']: 
                    raise ValueError(f'Invalid CS_VECTOR_ARCH, {cs} is not available in stage {stage}. Please edit CS_VECTOR_ARCH_LIB.')

                self.rec_add_dependant_signals(cs)

        self.SIGNAL_SET.reverse()


    def gen_cs_vector_description(self):
        cs_vector_description = {}
        position = 0
        for cs_name in self.SIGNAL_SET:
            cs_vector_description[cs_name]=self.SIGNAL_DESCRIPTION[cs_name]
            cs_vector_description[cs_name]['position']= position
            position += cs_vector_description[cs_name]['width']
        return cs_vector_description


    def gen_deassert_we_mask(self):
        mask = 0
        for cs in self.CS_VECTOR_DESCRIPTION:
            if 'we_signals' not in self.CS_VECTOR_DESCRIPTION[cs] or not self.CS_VECTOR_DESCRIPTION[cs]['we_signals']:
                mask |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
        return mask

    def gen_cs_vector_reset(self):
        cs_vector_reset = 0
        for cs in self.CS_VECTOR_DESCRIPTION:
            if 'reset_val' in self.CS_VECTOR_DESCRIPTION[cs].keys():
                reset_val = self.CS_VECTOR_DESCRIPTION[cs]['reset_val'] 
            else:
                reset_val = 0
            cs_vector_reset |= reset_val << (self.CS_VECTOR_DESCRIPTION[cs]['position'])
        return(cs_vector_reset)


    def count_cs_vector_width(self):
        cs_vector_width = 0
        for cs in self.CS_VECTOR_DESCRIPTION:
            cs_vector_width += self.CS_VECTOR_DESCRIPTION[cs]['width']
        return(cs_vector_width)


    def gen_mask_cs_vector_stage_invalid_next_stage_ready(self, stage_invalid_next_stage_ready):
        cs_vector_id_invalid_ex_ready = 0
        mask_cs_vector_id_invalid_ex_ready = 0
        for cs in self.CS_VECTOR_DESCRIPTION:
            if stage_invalid_next_stage_ready in self.CS_VECTOR_DESCRIPTION[cs].keys():
                cs_vector_id_invalid_ex_ready |= self.CS_VECTOR_DESCRIPTION[cs][stage_invalid_next_stage_ready] << self.CS_VECTOR_DESCRIPTION[cs]['position']
            else:
                mask_cs_vector_id_invalid_ex_ready |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
        return(cs_vector_id_invalid_ex_ready, mask_cs_vector_id_invalid_ex_ready)


    def count_stage_width(self, stage):
        width = 0
        if stage not in self.CS_VECTOR_ARCH.keys():
            width = 0
        else:
            for cs in self.CS_VECTOR_ARCH[stage]:
                width += self.SIGNAL_DESCRIPTION[cs]['width']
        return (width)


    def cs_vector_dict_to_xored_int(self, cs_vector_dict):
        cs_vector_reduced = 0
        for stage in ['wb','ex','id']:
            if stage in cs_vector_dict.keys() and stage in self.CS_VECTOR_ARCH:
                for cs in self.CS_VECTOR_ARCH[stage]:
                    cs_vector_reduced <<= self.CS_VECTOR_DESCRIPTION[cs]['width']
                    cs_vector_reduced |= (cs_vector_dict[stage] >> self.CS_VECTOR_DESCRIPTION[cs]['position']) & ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1)
        return(cs_vector_reduced)

    def cs_vector_xored_dict_to_xored_int(self, cs_vector_xored_dict):
        cs_vector_xored_int = 0
        for stage in ['wb', 'ex', 'id']:
            if stage in cs_vector_xored_dict.keys():
                width = 0
                for cs in self.CS_VECTOR_ARCH[stage]:
                    width += self.SIGNAL_DESCRIPTION[cs]['width']
                cs_vector_xored_int <<= width
                cs_vector_xored_int |= cs_vector_xored_dict[stage]
        return(cs_vector_xored_int)



    def cs_vector_xored_int_to_dict(self, cs_vector_xored_int):
        cs_vector_dict = {}
        for stage in ['id', 'ex', 'wb']:
            if stage in self.CS_VECTOR_ARCH.keys():
                cs_vector_dict[stage] = 0
                for cs in self.CS_VECTOR_ARCH[stage]:
                    cs_vector_dict[stage] <<= self.CS_VECTOR_DESCRIPTION[cs]['width']
                    cs_vector_dict[stage] |= cs_vector_xored_int & ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1)
                cs_vector_xored_int >>= width
        return (cs_vector_xored_dict)



    def make_mask_ex_en(self, cs_vector_id):
        mask = 0
        mask_for_id = 0
        mask_for_reset = 0
        for cs in self.CS_VECTOR_DESCRIPTION:
            if not 'ex_en' in self.CS_VECTOR_DESCRIPTION[cs]:
                mask |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
                mask_for_id |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
            else:
                en_ex = (cs_vector_id >> self.CS_VECTOR_DESCRIPTION[self.CS_VECTOR_DESCRIPTION[cs]['ex_en']]['position']) & 1
                if en_ex == 1:
                    mask |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
                    mask_for_id |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
                else:
                    mask_for_reset |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
        return (mask_for_id, mask_for_reset)
        #return mask


    def make_mask_wb_en(self, cs_vector_ex):
        mask = 0
        mask_for_ex = 0
        mask_for_reset = 0
        for cs in self.CS_VECTOR_DESCRIPTION:
            if not 'wb_en' in self.CS_VECTOR_DESCRIPTION[cs]:
                mask_for_ex |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
            else:
                en_wb = (cs_vector_ex >> self.CS_VECTOR_DESCRIPTION[self.CS_VECTOR_DESCRIPTION[cs]['wb_en']]['position']) & 1
                if en_wb == 1:
                    mask_for_ex |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
                else:
                    mask_for_reset |= ((1 << self.CS_VECTOR_DESCRIPTION[cs]['width']) - 1) << self.CS_VECTOR_DESCRIPTION[cs]['position']
        return (mask_for_ex, mask_for_reset)
        #return mask



    def instr_to_cs_vector(self, instr, cs_vector_dict):
        cs_vector = 0
        for cs_name in self.CS_VECTOR_DESCRIPTION.keys():
            if self.CS_VECTOR_DESCRIPTION[cs_name]['src'] not in VALID_SRC:
                raise ValueError(f"Error, 'src' field is wrong for {cs_name}.")

            # DECODER is modelizes as a LUT (input fct7fct3opcode, output 72 control signals)
            if self.CS_VECTOR_DESCRIPTION[cs_name]['src'] == 'instr_in_decoder':
                cs_vector |= self.extract_cs_from_decoder_lut(instr2fct7_3_opcode(instr), cs_name) << self.CS_VECTOR_DESCRIPTION[cs_name]['position']

            # SIGNALS (like register operand) only needs instr fields to be set
            elif self.CS_VECTOR_DESCRIPTION[cs_name]['src'] == 'instr_in_id':
                hard_fct = getattr(riscv_control_signals_combinational, cs_name) # call hard function from cs_name
                cs_vector |= hard_fct(instr) << self.CS_VECTOR_DESCRIPTION[cs_name]['position']


        # Generate Control signals which depends (combitional) on control signals
        for cs_name in self.CS_VECTOR_DESCRIPTION.keys():

            # CONTROL SIGNALS WHICH DEPENDS ON OTHER CONTROL SIGNALS
            if self.CS_VECTOR_DESCRIPTION[cs_name]['src'] == 'cs_in_id':
                hard_fct = getattr(riscv_control_signals_combinational, cs_name) # call hard function from cs_name
                cs_vector |= hard_fct(instr, cs_vector, cs_vector_dict, self.CS_VECTOR_DESCRIPTION) << self.CS_VECTOR_DESCRIPTION[cs_name]['position']

        return cs_vector


    def decode_tab_to_instr_metadata(self, instr):
        return self.cs_decoder[instr2fct7_3_opcode(instr)]


    def read_decoding_table(self, cs_path):
        '''
        Read the decoding table (.csv file) generated outside of this project.

        Parameters
        ----------

        Returns
        ----------
        cs_decoder : list of dict
            Index of list is the fct7_3_opcode (= concatenation of instr[31:25] | instr[14:12] | instr[6:2])
            Every dict has 3 fields: cs_vector on N bits, is_multicycle on 1 bit, ctrl_transfer on 2 bits.
                - control_transfer(BRANCH_NONE) = 2'b00
                - control_transfer(BRANCH_JAL) = 2'b01
                - control_transfer(BRANCH_JALR) = 2'b10
                - control_transfer(BRANCH_COND) = 2'b11
        '''
        with open(cs_path, "r") as file:
            cs_file = file.read()
        cs_file_list = list(filter(('').__ne__, list(cs_file.split('\n'))))

        self.cs_decoder = []
        for fct7_3_opcode in range(len(cs_file_list)):
            cs_file_line = list(cs_file_list[fct7_3_opcode].split(','))
            if int(cs_file_line[1], 16) != fct7_3_opcode:
                raise ValueError(f'Error, {cs_path} is bad-formated.')
            self.cs_decoder.append({'cs_vector': (int(cs_file_line[2], 16) << (56+8)) | ( int(cs_file_line[3], 16) << 8) | int(cs_file_line[4], 16),
                'is_multicycle': int(cs_file_line[5]), 'is_div': int(cs_file_line[6]), 'ctrl_transfer': int(cs_file_line[7])})



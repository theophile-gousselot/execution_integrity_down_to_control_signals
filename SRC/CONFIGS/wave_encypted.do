onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /core_v_verif_fpga_tb/clk_nexys_board_s
add wave -noupdate /core_v_verif_fpga_tb/rst_sw_s
add wave -noupdate /core_v_verif_fpga_tb/led_s
add wave -noupdate /core_v_verif_fpga_tb/maxcycles_int
add wave -noupdate /core_v_verif_fpga_tb/clk_nexys_board_cyc_cnt_int
add wave -noupdate /core_v_verif_fpga_tb/clk_core_slow_cyc_cnt_int
add wave -noupdate /core_v_verif_fpga_tb/stop_sim_cnt
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/clk_core_slow_i
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/clk_ascon_fast_i
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/rst_n
add wave -noupdate -divider #####
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/cv32e40p_core_i/instr_addr_o
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/cv32e40p_core_i/pc_if
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/cv32e40p_core_i/pc_id
add wave -noupdate -divider #####
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/cv32e40p_core_i/instr_rdata_i
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/cv32e40p_core_i/if_stage_i/instr_decompressed
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/cv32e40p_core_i/instr_rdata_id
add wave -noupdate -divider #####
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/ascon_decryption_i/instr_rdata_cipher_i
add wave -noupdate /core_v_verif_fpga_tb/core_v_verif_fpga_top_i/core_v_verif_fpga_i/ascon_decryption_i/instr_rdata_plain_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6837997 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {6427920 ps} {7030110 ps}

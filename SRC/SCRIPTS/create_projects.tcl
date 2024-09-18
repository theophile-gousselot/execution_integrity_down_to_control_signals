if { $argc != 1 } {
    puts "error: unrecognized or invalid arguments: usage: ./create_projects.tcl <project_name>"
    exit
} 

set PROJECT_NAME [lindex $argv 0]
set PROGRAM_NAME [regsub -all {core_v_verif_fpga_([^_]*).*}  ${PROJECT_NAME} {\1}]
if { ! [file isdirectory SRC/PROGRAMS/${PROGRAM_NAME}]} {
    puts "error: The program ${PROGRAM_NAME} is not in SRC/PROGRAM. Please verify program name."
    exit
}
set ENCRYPT [string match *_encrypted* ${PROJECT_NAME}]
if { $ENCRYPT } {
    if { [regexp {_cf[0-9]} ${PROJECT_NAME} ] } {
        set CF [regsub -all {.*_cf([0-9]).*} ${PROJECT_NAME} {\1}]
    } else {
        puts "error: The project_name ${PROJECT_NAME} contains _encrypted but not _cf\[0-9\]"
        exit
    }
} else {
	set CF 1
}
set PROJECT_PATH "OBJ/VIVADO_OBJ_DIR/${PROJECT_NAME}" 

puts "Create project: ${PROJECT_NAME}"
puts "ENCRYPTION: $ENCRYPT"
if { $ENCRYPT } {
    puts "CLK FACTOR: $CF"
}


###### CREATE PROJECT
create_project ${PROJECT_NAME} ${PROJECT_PATH} -part xc7a200tsbg484-1
set_property board_part digilentinc.com:nexys_video:part0:1.2 [current_project]

set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
set_property incremental_checkpoint {} [get_runs synth_1]
set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]
set_property incremental_checkpoint {} [get_runs impl_1]
set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs impl_1]
set_property strategy {Vivado Implementation Defaults} [get_runs impl_1]


##### IMPORT RTL/XDC/TB
if { $ENCRYPT } {
    set flist [open ./SRC/RTL/rtl_encrypted.flist r]
} else {
    set flist [open ./SRC/RTL/rtl.flist r]
}
set rtl_files [read $flist]
close $flist



if { $ENCRYPT } {
    file mkdir ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/new
    set macro_file [open ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/new/define_macro.vh w] 
    puts $macro_file "`define ENCRYPT"

	set HW_PERMUTATION_N [expr { 6 / ${CF}}]
    puts $macro_file "`define HW_PERMUTATION_N ${HW_PERMUTATION_N}"
    flush $macro_file
    close $macro_file
    add_files ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/new/define_macro.vh
    set_property is_global_include true [get_files  ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/new/define_macro.vh]
}

if { $ENCRYPT } {
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_encrypted_0.mem
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_encrypted_1.mem
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_encrypted_2.mem
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_encrypted_3.mem
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_encrypted_patches.mem
} else {
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_0.mem
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_1.mem
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_2.mem
    import_files -fileset sources_1 -norecurse ./OBJ/PROGRAMS/${PROGRAM_NAME}/PROGRAM_COMPILED/program_3.mem
}
foreach file_path $rtl_files {
    import_files -fileset sources_1 -norecurse ${file_path}
}


import_files -fileset sources_1 -norecurse ./SRC/RTL/core_v_verif_fpga_top.sv
import_files -fileset constrs_1 -norecurse ./SRC/XDC/constraints.xdc
import_files -fileset sim_1 -norecurse ./SRC/BENCH/core_v_verif_fpga_tb.sv
import_files -fileset sim_1 -norecurse ./SRC/CONFIGS/core_v_verif_fpga_tb_behav.wcfg
set_property xsim.view  ./SRC/CONFIGS/core_v_verif_fpga_tb_behav.wcfg [get_filesets sim_1]


##### CREATE CLOCK WIZARD
set freq_clk_core_slow 20
set freq_clk_ascon_fast [expr {${freq_clk_core_slow} * ${CF}}]

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list CONFIG.Component_Name {clk_wiz_0} CONFIG.USE_DYN_RECONFIG {false} CONFIG.PRIM_SOURCE {No_buffer} CONFIG.AXI_DRP {false} CONFIG.PHASE_DUTY_CONFIG {false}] [get_ips clk_wiz_0]
set_property -dict [list CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} CONFIG.PRIMARY_PORT {clk_nexys_board_i}] [get_ips clk_wiz_0]
set_property -dict [list CONFIG.USE_SAFE_CLOCK_STARTUP {true} CONFIG.LOCKED_PORT {mmcm_clks_locked_o}] [get_ips clk_wiz_0]
set_property -dict [list CONFIG.CLK_OUT1_PORT {clk_core_slow_o} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ ${freq_clk_core_slow} ] [get_ips clk_wiz_0]
set_property -dict [list CONFIG.CLKOUT2_USED {true} CONFIG.CLK_OUT2_PORT {clk_ascon_fast_o} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ ${freq_clk_ascon_fast} ] [get_ips clk_wiz_0]
set_property -dict [list CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT4_USED {true} CONFIG.CLKOUT5_USED {true} CONFIG.CLKOUT6_USED {true} CONFIG.CLKOUT7_USED {true} ] [get_ips clk_wiz_0]

generate_target {instantiation_template} [get_files ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
generate_target all [get_files  ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
catch { config_ip_cache -export [get_ips -all clk_wiz_0] }

export_ip_user_files -of_objects [get_files ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${PROJECT_PATH}/${PROJECT_NAME}.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
launch_runs clk_wiz_0_synth_1 -jobs 3











update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#launch_runs synth_1 -jobs 3
launch_runs impl_1 -to_step write_bitstream -jobs 3

wait_on_run impl_1

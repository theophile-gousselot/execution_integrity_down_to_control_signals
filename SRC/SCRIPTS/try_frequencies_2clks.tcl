proc TryFreq {fmin fmax step nb_hw_perm} {

	set PROJECT_NAME [get_property NAME [current_project]]
	set PROJECT_DIR [get_property DIRECTORY [current_project]]
	set TRY_FREQ_FOLDER_PATH "${PROJECT_DIR}/${PROJECT_NAME}.try_freq"

	file mkdir ${TRY_FREQ_FOLDER_PATH}
    set try_freq_path "${TRY_FREQ_FOLDER_PATH}/try_freq__[clock format [clock seconds] -format "%Y-%m-%d__%H-%M-%S"]"
    set log_file "${try_freq_path}/try_freq.log"


    file mkdir ${try_freq_path}
    set fdlog [open ${log_file} a]
    puts $fdlog "====================================================================="
    puts $fdlog "${try_freq_path}"
    puts $fdlog "Number of hardware permutations: ${nb_hw_perm}"
    puts $fdlog "Fmin: ${fmin} MHz     Fmax: ${fmax} MHz     Step: ${step} MHz"
    puts $fdlog "[clock format [clock seconds]]"
    puts $fdlog "Synthesis strategy:      [get_property strategy [get_runs synth_1]]"
    puts $fdlog "Implementation strategy: [get_property strategy [get_runs impl_1]]"
    puts $fdlog "Flatten hierarchy:       [get_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY [get_runs synth_1]]"
    puts $fdlog "Synthesis incremental?   [get_property incremental_checkpoint [get_runs synth_1]]"
    puts $fdlog "Synthesis incremental?   [get_property AUTO_INCREMENTAL_CHECKPOINT [get_runs synth_1]]"
    puts $fdlog "Synthesis incremental?   [get_property STEPS.SYNTH_DESIGN.ARGS.INCREMENTAL_MODE [get_runs synth_1]]"
    puts $fdlog "Implementation incremental?   [get_property incremental_checkpoint [get_runs impl_1]]"
    puts $fdlog "Implementation incremental?   [get_property AUTO_INCREMENTAL_CHECKPOINT [get_runs impl_1]]"
    puts $fdlog "Implementation incremental?   [get_property STEPS.SYNTH_DESIGN.ARGS.INCREMENTAL_MODE [get_runs impl_1]]"
    puts $fdlog "====================================================================="
    flush $fdlog

    set clk_factor [expr { 6 / ${nb_hw_perm}}]

    for {set freq $fmin} {$freq <= $fmax} {set freq [expr {$freq + $step}]} {
        
        # SET CLK CORE (SLOW) FREQUENCY
        set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ $freq] [get_ips clk_wiz_0]
        
        # SET CLK ASCON PERMUTATION (FAST) FREQUENCY
        set freq_clk_fast [expr {${freq} * ${clk_factor}}]
        set_property -dict [list CONFIG.CLKOUT2_REQUESTED_OUT_FREQ $freq_clk_fast] [get_ips clk_wiz_0]

        # SET EXTRA (AND UNUSED) CLK AS CLK CORE FREQUENCY (to avoid approximation of CLK CORE§CLK ASCON.
        set_property -dict [list CONFIG.CLKOUT3_REQUESTED_OUT_FREQ $freq] [get_ips clk_wiz_0]
        set_property -dict [list CONFIG.CLKOUT4_REQUESTED_OUT_FREQ $freq] [get_ips clk_wiz_0]
        set_property -dict [list CONFIG.CLKOUT5_REQUESTED_OUT_FREQ $freq] [get_ips clk_wiz_0]
        set_property -dict [list CONFIG.CLKOUT6_REQUESTED_OUT_FREQ $freq] [get_ips clk_wiz_0]
        set_property -dict [list CONFIG.CLKOUT7_REQUESTED_OUT_FREQ $freq] [get_ips clk_wiz_0]

        # LAUNCH SYNTHESIS OF CLOCK WIZARD (OUT-OF-CONTEXT MODULE)
        reset_runs clk_wiz_0_synth_1
        launch_runs -jobs 18 clk_wiz_0_synth_1

        # LAUNCH SYNTHESIS/IMPLEMENTATION OF TOP MODULE
        reset_run synth_1
        reset_run impl_1
        launch_runs impl_1 -to_step write_bitstream -jobs 18

        # GENERATE LOG
        wait_on_run impl_1
        open_run impl_1

        set wns [get_property SLACK [get_timing_paths]]

        # GET THE REAL PERIOD IMPLEMENTED
        set real_period_clk_slow [get_property PERIOD [get_clocks clk_core_slow_o_clk_wiz_0]]
        set real_freq_clk_slow [expr 1000/$real_period_clk_slow]
        if {$clk_factor == 1 } {
            set real_period_clk_fast $real_period_clk_slow
        } else {
            set real_period_clk_fast [get_property PERIOD [get_clocks clk_ascon_fast_o_clk_wiz_0]]
        }
        set real_freq_clk_fast [expr 1000/$real_period_clk_fast]

        puts -nonewline $fdlog "Fcore=[format "%.5f" ${real_freq_clk_slow}]MHz ([format "%.5f" ${real_period_clk_slow}]ns) |"
        puts -nonewline $fdlog " Fascon=[format "%.5f" ${real_freq_clk_fast}]MHz ([format "%.5f" ${real_period_clk_fast}]ns) |"
        puts $fdlog " WNS=[format "%.5f" ${wns}]ns | [clock format [clock seconds]]"
        flush $fdlog
        
        # GENERATE REPORTS/CHECKPOINTS
        set real_freq_clk_slow_str [string map {. -} [format "%.5f" ${real_freq_clk_slow}]]
        set real_freq_clk_fast_str [string map {. -} [format "%.5f" ${real_freq_clk_fast}]]

        set freq_dir "${try_freq_path}/freq_${real_freq_clk_slow_str}_${real_freq_clk_fast_str}"
        file delete -force "${freq_dir}"
        file mkdir "${freq_dir}"
        set prefix "${freq_dir}/${PROJECT_NAME}_freq_${real_freq_clk_slow_str}_${real_freq_clk_fast_str}"
        write_checkpoint -force "${prefix}_checkpoint.dcp"
        write_bitstream -force "${prefix}.bit"
        report_utilization -file "${prefix}_report_utilization.rpt"
        report_utilization -hierarchical -file "${prefix}_report_utilization_hierarchical.rpt"
        report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 5 -nworst 4 -input_pins -file "${prefix}_timing.rpt"
        report_design_analysis -timing -extend -congestion -complexity -file "${prefix}_design-analysis.rpt"

    }
}

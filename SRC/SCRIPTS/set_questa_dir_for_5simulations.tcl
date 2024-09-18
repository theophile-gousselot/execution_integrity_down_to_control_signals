set_property target_simulator Questa [current_project]
set_property compxlib.questa_compiled_library_dir /home/data/public/gousselot/questa-2021-3-compile-simlib [current_project]
set_property generate_scripts_only 1 [current_fileset -simset]
set_property -name {questa.simulate.runtime} -value {} -objects [get_filesets sim_1]


set PROJECT_NAME [get_property NAME [current_project]]
set PROJECT_DIR [get_property DIRECTORY [current_project]]

launch_simulation -mode behavioral
set QUESTA_BEHAV_DIR "${PROJECT_DIR}/${PROJECT_NAME}.sim/sim_1/behav/questa"
exec sh ./SRC/SCRIPTS/edit_questa_scripts.sh ${QUESTA_BEHAV_DIR}

launch_simulation -mode post-synthesis -type functional
set QUESTA_SYNTH_FUNC_DIR "${PROJECT_DIR}/${PROJECT_NAME}.sim/sim_1/synth/func/questa"
exec sh ./SRC/SCRIPTS/edit_questa_scripts.sh ${QUESTA_SYNTH_FUNC_DIR}

launch_simulation -mode post-implementation -type functional
set QUESTA_IMPL_FUNC_DIR "${PROJECT_DIR}/${PROJECT_NAME}.sim/sim_1/impl/func/questa"
exec sh ./SRC/SCRIPTS/edit_questa_scripts.sh ${QUESTA_IMPL_FUNC_DIR}

launch_simulation -mode post-synthesis -type timing
set QUESTA_SYNTH_TIMING_DIR "${PROJECT_DIR}/${PROJECT_NAME}.sim/sim_1/synth/timing/questa"
exec sh ./SRC/SCRIPTS/edit_questa_scripts.sh ${QUESTA_SYNTH_TIMING_DIR}

launch_simulation -mode post-implementation -type timing
set QUESTA_IMPL_TIMING_DIR "${PROJECT_DIR}/${PROJECT_NAME}.sim/sim_1/impl/timing/questa"
exec sh ./SRC/SCRIPTS/edit_questa_scripts.sh ${QUESTA_IMPL_TIMING_DIR}






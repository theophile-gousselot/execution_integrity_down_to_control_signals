##################################################
## __     __         _       _     _            ##
## \ \   / /_ _ _ __(_) __ _| |__ | | ___  ___  ##
##  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __| ##
##   \ V / (_| | |  | | (_| | |_) | |  __/\__ \ ##
##    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/ ##
##                                              ##
##################################################

#==== DEFAULT USER MACROS ===#
MAX_SIM_TIME		:= 30000000


#==== RISCV ====#
RISCV			:= /opt/corev
RISCV_PREFIX      	:= riscv32-corev-elf-
RISCV_EXE_PREFIX  	:= $(RISCV)/bin/$(RISCV_PREFIX)
RISCV_CC          	:= gcc
CFLAGS 				:= -Os -g -static -mabi=ilp32 -march=rv32im -Wall -pedantic



#==== ENCRYPTION ===#
PB_ROUNDS			:= 6
PB_ROUNDS_PY_FLAG	:= --pb_rounds=$(PB_ROUNDS)



#==== SOURCE PATHS ====#
SRC_DIR				:= ./SRC
SCRIPT_DIR	 		:= $(SRC_DIR)/SCRIPTS
SV_RTL_DIR	 		:= $(SRC_DIR)/RTL
SV_BENCH_DIR		:= $(SRC_DIR)/BENCH
SRC_BSP_DIR	 		:= $(SRC_DIR)/PROGRAM_TOOLS/BSP
BSP_RESULT_FILES	:= $(patsubst %,$(SRC_BSP_DIR)/%,crt0.o handlers.o syscalls.o vectors.o libcv-verif.a)

SRC_RTL				:= $(shell cat ./SRC/RTL/rtl.flist)
SRC_RTL_ENCRYPTED	:= $(shell cat ./SRC/RTL/rtl_encrypted.flist) 
SRC_TB_FILE			:= $(SV_BENCH_DIR)/core_v_verif_fpga_tb.cpp

TB_CPP_NAME			:= core_v_verif_fpga

SOFT_SCRIPTS		:= $(filter %.py,$(wildcard  SRC/SCRIPTS/*)) 

#==== CV32E40P ====#
CV_CORE_PKG 		:= $(SV_RTL_DIR)/iea_cv32e40p_fpga_dev
CV_CORE_BRANCH 		:= iea_cv32e40p_fpga_dev
CV_CORE_REPO   		:= https://anonymous.4open.science/r/cv32e40p_cfi



#==== OBJECT PATHS ====#
OBJ_DIR                 := ./OBJ
OBJ_VERI_DIR 			:= $(OBJ_DIR)/VERILATOR_OBJ_DIR
OBJ_TOOLS_DIR           := $(OBJ_DIR)/PROGRAM_TOOLS
OBJ_BSP_DIR             := $(OBJ_TOOLS_DIR)/BSP




###################################################
##  _____                 _   _                  ##
## |  ___|   _ _ __   ___| |_(_) ___  _ __  ___  ##
## | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __| ##
## |  _|| |_| | | | | (__| |_| | (_) | | | \__ \ ##
## |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/ ##
##                                               ##
###################################################

cf_val = $(shell echo "$(1)" | sed 's=^.*_cf\([0-9]\).*$$=\1=' || true)
cf = $(shell echo "$(1)" | sed -n 's=^.*_cf\([0-9]\).*$$=_cf\1=p' || true)


program = $(shell echo "$(1)" | sed -n 's=^.*OBJ/PROGRAMS/\([^/]*\)/.*$$=\1=p' || true)

keep_if_enc= $(shell echo "$(1)" | sed -E -n 's=^(.*_encrypted.*)$$=\1=p' || true)

cs_flags_sw = $(shell echo "$(1)" | sed -n 's!^.*_cs\([0-9]\).*$$!--cs_vector_arch_id=\1!p' || true)
cs_flags_hw = $(shell echo "$(1)" | sed -n 's!^.*_cs\([0-9]\).*$$!+define+CS\1 -CFLAGS  '\''-D CS=\1'\''!p' || true)
cs = $(shell echo "$(1)" | sed -n 's=^.*_cs\([0-9]\).*$$=_cs\1=p' || true)

#cs = $(shell echo "$(1)" | grep -q "_cs" && echo "_cs" || true)
#cs_val = $(shell echo "$(1)" | sed -E -n 's=^.*_cs(([a-z]|-)*).*$$=_cs\1=p' || true)
#cs = $(shell echo "$(1)" | grep -q "_cs" && echo "_cs" || true)
#cs_id_hw = $(shell echo "$(1)" | sed -E -n 's=^.*_cs.*-(id).*$$=+define+CS_\U\1 -CFLAGS  '\''-D CS_\U\1'\''=p')
#cs_ex_hw = $(shell echo "$(1)" | sed -E -n 's=^.*_cs.*-(ex).*$$=+define+CS_\U\1 -CFLAGS  '\''-D CS_\U\1'\''=p')
#cs_flags_hw = $(shell echo "$(1)" | grep -q "_cs" && echo "$(call cs_id_hw,$(1)) $(call cs_ex_hw,$(1))" || true)
#cs_sw = $(shell echo "$(1)" | sed -E -n 's=^.*_cs(-id|)(-ex|).*$$=cs\1\2=p')
#cs_flags_sw = $(shell echo "$(1)" | grep -q "_cs" && echo "--control_signals=$(call cs_sw,$(1))" || true)

if_cs = $(shell echo "$(1)" | grep -q "_cs" && echo "$(2)" || true)

vcd = $(shell echo "$(1)" | grep -q "_vcd\|\.vcd" && echo "_vcd" || true)
vcd_flags = $(shell echo "$(1)" | grep -q "_vcd" && echo "--trace --trace-depth 8 -CFLAGS '-D VCD'" || true)

encrypted = $(shell echo "$(1)" | grep -q "_encrypted" && echo "_encrypted" || true)
encrypted_flags = $(shell echo "$(1)" | grep -q "_encrypted" && echo "+define+ENCRYPT -CFLAGS '-D ENCRYPT' -GHW_PERMUTATION_N=$(shell expr 6 / $(call cf_val,$@) ) -CFLAGS '-D CLK_FACTOR=$(call cf_val,$@)'" || true)


rm_none= $(shell echo "$(1)" | sed 's=_none==g' || true)


########################################
##  _____                    _        ##
## |_   _|_ _ _ __ __ _  ___| |_ ___  ##
##   | |/ _` | '__/ _` |/ _ \ __/ __| ##
##   | | (_| | | | (_| |  __/ |_\__ \ ##
##   |_|\__,_|_|  \__, |\___|\__|___/ ##
##                |___/               ##
########################################


VCD= _none _vcd
CF= 1 2 3 6
CS= 1 2 3 4 5 6 7 8 9


_ENC_CF= $(addprefix _encrypted_cf, $(CF))    							# _encrypted_cf1 _encrypted_cf2 ...
_CS= _none $(addprefix _cs, $(CS)) 						# _cs_cf1 _cs_cf2 ...
_ENC_CF_CS= _none $(foreach cs,$(_CS), $(foreach enc_cf,$(_ENC_CF), $(enc_cf)$(cs)))    # _encrypted_cf1 _encrypted_cf1_cs-id ...
_ENC_CS= $(call rm_none, $(addprefix _encrypted, $(_CS)))
_none_ENC_CS= _none $(_ENC_CS)

VERI_SIMU_VERIF_TARGETS= \
$(call rm_none,\
$(foreach _enc_cf_cs,$(_ENC_CF_CS),\
OBJ/PROGRAMS/%/SIM/LOG/program$(_enc_cf_cs)_verif.log)) \
$(call rm_none,\
$(foreach _enc_cf_cs,$(_ENC_CF_CS),\
OBJ/PROGRAMS/%/SIM/VCD/program$(_enc_cf_cs).vcd))

VERILATOR_EXE_TARGETS= \
$(call rm_none,\
$(foreach vcd,$(VCD),\
$(foreach _enc_cf_cs,$(_ENC_CF_CS),\
OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga$(_enc_cf_cs)$(vcd)/Vcore_v_verif_fpga)))

COMP_BASE= $(foreach _enc_cs,$(_ENC_CS), $(_enc_cs))

MEM_PATCHES_TARGETS=$(foreach base,$(_ENC_CS), OBJ/PROGRAMS/%/PROGRAM_COMPILED/program$(base)_patches.mem)
MEM_TARGETS=$(call rm_none, $(foreach base,$(_none_ENC_CS), OBJ/PROGRAMS/%/PROGRAM_COMPILED/.mem$(base)_timestamp))
HEX_TARGETS=$(call rm_none, $(foreach base,$(_none_ENC_CS), OBJ/PROGRAMS/%/PROGRAM_COMPILED/program$(base).hex))
ELF_ENC_TARGETS=$(foreach base,$(_ENC_CS), OBJ/PROGRAMS/%/PROGRAM_COMPILED/program$(base).elf)


.PHONY: info
info :
	@echo $(MODE) $(VCD) $(CF) $(CS)
	@echo "==="
	@echo $(_ENC_CF) $(_CS) $(_ENC_CF_CS) $(_ENC_CS)
	@echo "==="
	@echo $(VERI_SIMU_VERIF_TARGETS)
	@echo "==="
	@echo $(VERILATOR_EXE_TARGETS)
	@echo "==="
	@echo $(MEM_TARGETS)
	@echo "==="
	@echo $(_ENC_CS)
	@echo "==="
	@echo $(COMP_BASE)
	@echo "==="
	@echo $(ELF_ENC_TARGETS)
	@echo "==="
	@echo $(HEX_TARGETS)



##                 _ _       _                                           _
## __   _____ _ __(_| | __ _| |_ ___  _ __ _     _____  _____  ___ _   _| |_ ___
## \ \ / / _ | '__| | |/ _` | __/ _ \| '__(_)   / _ \ \/ / _ \/ __| | | | __/ _ \
##  \ V |  __| |  | | | (_| | || (_) | |   _   |  __/>  |  __| (__| |_| | ||  __/
##   \_/ \___|_|  |_|_|\__,_|\__\___/|_|  (_)   \___/_/\_\___|\___|\__,_|\__\___|
##

# Secondary Expansion allow Automatic Variablesto be used in dependancies field
.SECONDEXPANSION:

#==== RUN SIMULATION ====#
#OBJ/PROGRAMS/%/SIM/LOG/program_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf1_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf2_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf3_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf6_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf1_cs1_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf1_cs2_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf2_cs1_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf3_cs1_verif.log \
#OBJ/PROGRAMS/%/SIM/LOG/program_encrypted_cf6_cs1_verif.log \
#OBJ/PROGRAMS/%/SIM/VCD/program.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf1.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf2.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf3.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf6.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf1_cs1.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf1_cs2.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf2_cs1.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf3_cs1.vcd \
#OBJ/PROGRAMS/%/SIM/VCD/program_encrypted_cf6_cs1.vcd : \


$(VERI_SIMU_VERIF_TARGETS) : \
		$$(call keep_if_enc, OBJ/PROGRAMS/$$(call program,$$@)/PROGRAM_COMPILED/program$$(call encrypted,$$@)$$(call cs,$$@)_patches.mem) \
		$(OBJ_VERI_DIR)/$(TB_CPP_NAME)$$(call encrypted,$$@)$$(call cf,$$@)$$(call cs,$$@)$$(call vcd,$$@)/V$$(TB_CPP_NAME) \
		OBJ/PROGRAMS/$$(call program,$$@)/SIM/REF/ref_decode_pc_instr_patch.csv \
		SRC/PROGRAM_TOOLS/CONTROL_SIGNALS/control_signals.csv
	make OBJ/PROGRAMS/$(call program,$@)/PROGRAM_COMPILED/.mem$(call encrypted,$@)$(call cs,$@)_timestamp
	@echo "\n===> $@"
	mkdir -p $(dir $@)
	$(OBJ_VERI_DIR)/$(TB_CPP_NAME)$(call encrypted,$@)$(call cf,$@)$(call cs,$@)$(call vcd,$@)/V$(TB_CPP_NAME) $(call program,$@) --verif


.PRECIOUS: OBJ/PROGRAMS/%/SIM/LOG/program_save_ref.log
OBJ/PROGRAMS/%/SIM/LOG/program_save_ref.log :
	make OBJ/PROGRAMS/$(call program,$@)/SIM/REF/ref_decode_pc_instr_patch.csv


#==== SAVE REF ====#
.PRECIOUS: OBJ/PROGRAMS/%/SIM/REF/ref_decode_pc_instr_patch.csv
OBJ/PROGRAMS/%/SIM/REF/ref_decode_pc_instr_patch.csv : \
		$(OBJ_VERI_DIR)/$(TB_CPP_NAME)/V$(TB_CPP_NAME) \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/.mem_timestamp
	@echo "\n===> $@"
	mkdir -p $(dir $@)
	$(OBJ_VERI_DIR)/$(TB_CPP_NAME)/V$(TB_CPP_NAME) $* --save_ref


#==== SAVE CONTROL SIGNAL AT EXECUTION TIME ====#
.PRECIOUS: OBJ/PROGRAMS/%/SIM/REF/ref_cs.csv
OBJ/PROGRAMS/%/SIM/REF/ref_cs.csv : \
		$(OBJ_VERI_DIR)/$(TB_CPP_NAME)/V$(TB_CPP_NAME) \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/.mem_timestamp
	@echo "\n===> $@"
	mkdir -p $(dir $@)
	$(OBJ_VERI_DIR)/$(TB_CPP_NAME)/V$(TB_CPP_NAME) $* --save_ref --cs_ref


#==== TRACE SIGNALS ====#
.PRECIOUS: OBJ/PROGRAMS/%/SIM/REF/program_trace_signals.csv
OBJ/PROGRAMS/%/SIM/REF/program_trace_signals.csv : \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/.mem_timestamp \
		$(OBJ_VERI_DIR)/$(TB_CPP_NAME)/V$(TB_CPP_NAME)
	@echo "\n===> $@"
	mkdir -p $(dir $@)
	$(OBJ_VERI_DIR)/$(TB_CPP_NAME)/V$(TB_CPP_NAME) $* --trace_signals --save_ref



##                  _ _       _                  _           _ _     _
##  __   _____ _ __(_| | __ _| |_ ___  _ __ _   | |__  _   _(_| | __| |
##  \ \ / / _ | '__| | |/ _` | __/ _ \| '__(_)  | '_ \| | | | | |/ _` |
##   \ V |  __| |  | | | (_| | || (_) | |   _   | |_) | |_| | | | (_| |
##    \_/ \___|_|  |_|_|\__,_|\__\___/|_|  (_)  |_.__/ \__,_|_|_|\__,_|
## 


#==== BUILD CPP MODEL with ENCRYPTED PROGRAM and WAVEFORM GENERATION ===#
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_vcd/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf2/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf3/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf6/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf1_cs1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf1_cs2/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf2_cs1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf3_cs1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_cf6_cs1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf2/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf3/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf6/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf1_cs1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf1_cs2/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf2_cs1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf3_cs1/Vcore_v_verif_fpga \
#OBJ/VERILATOR_OBJ_DIR/core_v_verif_fpga_encrypted_vcd_cf6_cs1/Vcore_v_verif_fpga : 
$(VERILATOR_EXE_TARGETS) : \
		$(CV_CORE_PKG) $(SRC_RTL_ENCRYPTED) $(SRC_TB_FILE) OBJ/RTL/.rtl_timestamp
	@echo "\n===> $@"
	mkdir -p $(dir $@)
	verilator \
		$(call vcd_flags,$@) \
		$(call encrypted_flags,$@) \
		$(call cs_flags_hw,$@) \
		-CFLAGS "-D MAX_SIM_TIME=$(MAX_SIM_TIME)" \
	   	--Mdir $(OBJ_VERI_DIR)/$(TB_CPP_NAME)$(call encrypted,$@)$(call cf,$@)$(call cs,$@)$(call vcd,$@) \
		-IOBJ/RTL/ \
	   	--cc -sv --exe \
	   	--top-module $(TB_CPP_NAME) ../../$(SRC_TB_FILE) \
	   	-f SRC/RTL/rtl_encrypted.flist
	./SRC/SCRIPTS/gen_all_headers.sh $@
	make \
		-C $(OBJ_VERI_DIR)/$(TB_CPP_NAME)$(call encrypted,$@)$(call cf,$@)$(call cs,$@)$(call vcd,$@) \
		-f V$(TB_CPP_NAME).mk \
		V$(TB_CPP_NAME)

OBJ/RTL/.rtl_timestamp : SRC/SCRIPTS/riscv_control_signals.py
	@echo "\n===> $@"
	(cd SRC/SCRIPTS && python3 -c "from riscv_control_signals import Macro_sv; Macro_sv()")
	touch $@


##        _                _
## __   _(_)_   ____ _  __| | ___
## \ \ / / \ \ / / _` |/ _` |/ _ \
##  \ V /| |\ V / (_| | (_| | (_) |
##   \_/ |_| \_/ \__,_|\__,_|\___/
##



OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%/.simulate_behav_log_timestamp : OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%
	@echo "\n===> $@"
	vivado -mode batch OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.xpr -source ./SRC/SCRIPTS/set_questa_dir_for_5simulations.tcl
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.sim/sim_1/behav/questa -c
	touch $@

OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%/.simulate_log_timestamp : OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%
	@echo "\n===> $@"
	vivado -mode batch OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.xpr -source ./SRC/SCRIPTS/set_questa_dir_for_5simulations.tcl
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.sim/sim_1/behav/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.sim/sim_1/synth/func/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.sim/sim_1/synth/timing/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.sim/sim_1/impl/func/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*/core_v_verif_fpga_$*.sim/sim_1/impl/timing/questa -c
	touch $@


OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf1/.simulate_behav_log_timestamp \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf2/.simulate_behav_log_timestamp \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf3/.simulate_behav_log_timestamp \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf6/.simulate_behav_log_timestamp :
		OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted$$(call cf,$$@)
	@echo "\n===> $@"
	vivado -mode batch OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).xpr -source ./SRC/SCRIPTS/set_questa_dir_for_5simulations.tcl
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).sim/sim_1/behav/questa -c
	touch $@


OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf1/.simulate_log_timestamp \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf2/.simulate_log_timestamp \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf3/.simulate_log_timestamp \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf6/.simulate_log_timestamp :
	make OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)
	@echo "\n===> $@"
	vivado -mode batch OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).xpr -source ./SRC/SCRIPTS/set_questa_dir_for_5simulations.tcl
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).sim/sim_1/behav/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).sim/sim_1/synth/func/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).sim/sim_1/synth/timing/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).sim/sim_1/impl/func/questa -c
	SRC/SCRIPTS/launch_questa_simulation.sh OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_$*_encrypted$(call cf,$@)/core_v_verif_fpga_$*_encrypted$(call cf,$@).sim/sim_1/impl/timing/questa -c
	touch $@

OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_% : $(CV_CORE_PKG) $(SRC_RTL) $(SRC_TB_FILE) \
		SRC/SCRIPTS/create_projects.tcl \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/.mem_timestamp
	@echo "\n===> $@"
	vivado -mode batch -source SRC/SCRIPTS/create_projects.tcl -tclargs core_v_verif_fpga_$*

OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf1 \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf2 \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf3 \
OBJ/VIVADO_OBJ_DIR/core_v_verif_fpga_%_encrypted_cf6 :  $(CV_CORE_PKG) $(SRC_RTL_ENCRYPTED) $(SRC_TB_FILE) \
		SRC/SCRIPTS/create_projects.tcl \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/.mem_encrypted_timestamp \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program_encrypted_patches.mem
	@echo "\n===> $@"
	vivado -mode batch -source SRC/SCRIPTS/create_projects.tcl -tclargs core_v_verif_fpga_$*_encrypted$(call cf,$@)

##  _                   _                        
## | |__   __ _ _ __ __| |_      ____ _ _ __ ___ 
## | '_ \ / _` | '__/ _` \ \ /\ / / _` | '__/ _ \
## | | | | (_| | | | (_| |\ V  V / (_| | | |  __/
## |_| |_|\__,_|_|  \__,_| \_/\_/ \__,_|_|  \___|
##                                               

#==== GIT CLONE CV32E40P ====#
SRC/RTL/iea_cv32e40p_fpga_dev :
	@echo "\n===> $@"
	git clone -b $(CV_CORE_BRANCH) $(CV_CORE_REPO) $(CV_CORE_PKG); \
	cd $(CV_CORE_PKG); git checkout $(CV_CORE_BRANCH)



##                            _ _       _   _                    __ _               
##   ___ ___  _ __ ___  _ __ (_) | __ _| |_(_) ___  _ __        / _| | _____      __
##  / __/ _ \| '_ ` _ \| '_ \| | |/ _` | __| |/ _ \| '_ \ _____| |_| |/ _ \ \ /\ / /
## | (_| (_) | | | | | | |_) | | | (_| | |_| | (_) | | | |_____|  _| | (_) \ V  V / 
##  \___\___/|_| |_| |_| .__/|_|_|\__,_|\__|_|\___/|_| |_|     |_| |_|\___/ \_/\_/  
##                     |_|                                                          


#==== CONVERT HEX ENCRYPTED ====#
.PRECIOUS : $(MEM_TARGETS)
$(MEM_TARGETS) : \
		$(SCRIPT_DIR)/hex2mem.py \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.itb \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.readelf \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.objdump \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program$$(call encrypted,$$@)$$(call cs,$$@).hex 
	@echo "\n===> $@"
	python3 $< OBJ/PROGRAMS/$*/PROGRAM_COMPILED/program$(call encrypted,$@)$(call cs,$@).hex 
	touch $@

#==== GENERATE PATCH MEM FILE ====#
.PRECIOUS: $(MEM_PATCHES_TARGETS)
$(MEM_PATCHES_TARGETS) : \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.itb \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program_jalr_successors.csv \
		$(SOFT_SCRIPTS) \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program$$(call encrypted,$$@)$$(call cs,$$@).elf
	@echo "\n===> $@"
	python3 $(SCRIPT_DIR)/riscv-elf-generate-patches.py OBJ/PROGRAMS/$*/SIM/REF OBJ/PROGRAMS/$*/PROGRAM_COMPILED $(call cs_flags_sw,$@)



#==== GENERATE ENCRYPTED HEX FILE ====#
.PRECIOUS: $(HEX_TARGETS)
$(HEX_TARGETS) : \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program$$(call encrypted,$$@)$$(call cs,$$@).elf \
		SRC/PROGRAM_TOOLS/CONTROL_SIGNALS/control_signals.csv
	@echo "\n===> $@"
	$(RISCV_EXE_PREFIX)objcopy -O verilog OBJ/PROGRAMS/$*/PROGRAM_COMPILED/program$(call encrypted,$@)$(call cs,$@).elf $@
	


#==== ENCRYPT MEMORY ====#
.PRECIOUS: $(ELF_ENC_TARGETS)
$(ELF_ENC_TARGETS) : \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.elf \
		OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.itb \
		$(SCRIPT_DIR)/riscv-elf-encryption.py  \
		$(SOFT_SCRIPTS)
	@echo "\n===> $@"
	cp $< $@
	python3 $(SCRIPT_DIR)/riscv-elf-encryption.py $@ $(PB_ROUNDS_PY_FLAG) $(call cs_flags_sw,$@)



#==== EXTRACT JALR SUCCESSORS ====#
# backup for distribution (to increase speed get-jalr not executed in dev step)
#.PRECIOUS: OBJ/PROGRAMS/%/PROGRAM_COMPILED/program_jalr_successors.csv
#OBJ/PROGRAMS/%/PROGRAM_COMPILED/program_jalr_successors.csv : \
#		OBJ/PROGRAMS/%/SIM/REF/program_trace_signals.csv \
#		SRC/SCRIPTS/riscv-get-jalr-successors-from-extracted-signals.py
#	@echo "\n===> $@"
#	$(SCRIPT_DIR)/riscv-get-jalr-successors-from-extracted-signals.py $< $@
.PRECIOUS: OBJ/PROGRAMS/%/PROGRAM_COMPILED/program_jalr_successors.csv
OBJ/PROGRAMS/%/PROGRAM_COMPILED/program_jalr_successors.csv :
	make OBJ/PROGRAMS/$*/SIM/REF/program_trace_signals.csv 
	make SRC/SCRIPTS/riscv-get-jalr-successors-from-extracted-signals.py
	@echo "\n===> $@"
	python3 $(SCRIPT_DIR)/riscv-get-jalr-successors-from-extracted-signals.py  OBJ/PROGRAMS/$*/SIM/REF/program_trace_signals.csv $@
	

#==== GENERATE READELF FILE ====#
.PRECIOUS: OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.readelf
OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.readelf: OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.elf
	@echo "\n===> $@"
	$(RISCV_EXE_PREFIX)readelf -a $< > $@


#==== GENERATE OBJDUMP FILE ====#
.PRECIOUS: OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.objdump
OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.objdump: OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.elf
	@echo "\n===> $@"
	$(RISCV_EXE_PREFIX)objdump \
		-d \
		-M no-aliases \
		-M numeric \
		-S \
		$< > $@



#==== GENERATE ITB FILE FROM OBJDUMP FILE ====#
.PRECIOUS : OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.itb
OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.itb: OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.objdump
	@echo "\n===> $@"
	$(SCRIPT_DIR)/objdump2itb $< > $@


#==== COMPILE PROGRAM ====#
.PRECIOUS : OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.elf
OBJ/PROGRAMS/%/PROGRAM_COMPILED/program.elf: $(OBJ_BSP_DIR)/.bsp_timestamp
	@echo "\n===> $@"
	mkdir -p $(dir $@)
	$(RISCV_EXE_PREFIX)$(RISCV_CC) \
		$(CFLAGS) \
		-I $(OBJ_BSP_DIR) \
		-o $@ \
		-nostartfiles \
		$(filter %.c %.S,$(wildcard  SRC/PROGRAMS/$*/*)) \
		-T $(SRC_BSP_DIR)/link.ld \
		-L $(OBJ_BSP_DIR) \
		-lcv-verif


#==== COMPILE BSP ====#
OBJ/PROGRAM_TOOLS/BSP/.bsp_timestamp :
	@echo "\n===> $@"
	make -C $(SRC_BSP_DIR) \
		VPATH=$(SRC_BSP_DIR) \
		RISCV=$(RISCV) \
		RISCV_PREFIX=$(RISCV_PREFIX) \
		RISCV_EXE_PREFIX=$(RISCV_EXE_PREFIX) \
		RISCV_CC=$(RISCV_CC) \
		all
	mkdir -p $(dir $@)
	mv $(BSP_RESULT_FILES) $(OBJ_BSP_DIR)
	touch $@

                              


##       _                  
##   ___| | ___  __ _ _ __  
##  / __| |/ _ \/ _` | '_ \ 
## | (__| |  __/ (_| | | | |
##  \___|_|\___|\__,_|_| |_|
##                         

#==== CLEAN ===#
.PHONY : clean_vcd
clean_vcd :
	find . -name "*.vcd" -exec rm {} \;

.PHONY : clean_large_vcd
clean_large_vcd :
	find . -size +200M -name "*.vcd" -exec rm {} \;

.PHONY : clean
clean :
	rm -f explicit_target_names.mk
	rm -rf $(OBJ_DIR)

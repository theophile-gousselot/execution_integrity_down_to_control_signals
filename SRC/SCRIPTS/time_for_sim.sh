#!/bin/bash

questa_folders=$(find $1 -iname "*questa" | grep "\.sim" | sort) 


for folder in ${questa_folders}
do
	if test -f "${folder}/simulate.log"; then
		if test -f "${folder}/compile.log"; then
			if cat ${folder}/simulate.log | grep -q "EXIT VALID EXECUTION"; then
				REASON_END="VALID"
			elif cat ${folder}/simulate.log | grep -q "MAXIMUM CYCLE LIMIT"; then
				REASON_END="MAXIMUM CYCLE LIMIT"
			elif cat ${folder}/simulate.log | grep -q "EXIT ILLEGAL INSN DECODE"; then
				REASON_END="ILLEGAL INSN"
			else
				REASON_END="ERROR NOT KNOW/IN PROGRESS"
			fi
			simulate_end=$(stat -c '%Y' ${folder}/simulate.log)
			compile_end=$(stat -c '%Y' ${folder}/compile.log)
			simulation_delay=$((${simulate_end}-${compile_end}))
			echo "$(date -ud "@${simulation_delay}" +"$(( ${simulation_delay}/3600/24 ))j %H:%M:%S") --- ${folder} ===>  ${REASON_END}"
		fi
	fi
done

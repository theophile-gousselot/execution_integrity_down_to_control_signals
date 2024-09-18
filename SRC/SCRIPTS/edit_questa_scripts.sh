#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Error: missing path to questa folder"
	exit
fi


# Allow to open vsim in GUI mode if '-c' is given in argument
sed -i 's/$bin_path\/vsim -64 -c -do \(.*\)/if [ "$#" -ne 1 ] ; then\n\t$bin_path\/vsim -64 -do \1\nelse\n\t$bin_path\/vsim -64 $1 -do \1\nfi/' $1/simulate.sh


# Remove +transport_int_delays option
sed -i 's/vsim +transport_int_delays /vsim /' $1/*_simulate.do
sed -i '/quit -force/d' $1/*_simulate.do

# Add run -all at the end of <tb>_wave.do and ensure that there is no other
sed -i '/run -all/d' $1/*_wave.do
wave_do_file=`ls $1|grep wave.do`
cat ./SRC/CONFIGS/wave.do >> "$1/$wave_do_file"
sed -i '$arun -all' $1/*_wave.do

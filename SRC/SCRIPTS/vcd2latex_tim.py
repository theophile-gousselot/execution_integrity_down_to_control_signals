#!/bin/python3

import json
import sys
from pyDigitalWaveTools.vcd.parser import VcdParser

with open("program_fi_addr164-blt-transform-into-bge__PLAIN_FI-instr__AUTHENTICATION_SUCCESS_NOT_DETECTED-no-cm.vcd") as vcd_file:
    vcd = VcdParser()
    vcd.parse(vcd_file)
    data = vcd.scope.toJson()


def find_signal(signal_name, d, base_index, base_name):
    #print(base_index, d['name'], d['type']['name'])
    if d['type']['name'] == 'wire' and signal_name == d['name']:
        return(base_index, base_name + [d['name']])
    elif d['type']['name'] == 'struct':
        for i in range(len(d['children'])):
            if d['type']['name'] == 'struct':
                ret = find_signal(signal_name, d['children'][i], base_index + [i], base_name + [d['name']])
                if ret != None:
                    return(ret)

SIGNALS = ['pc_if', 'instr_decompressed', 'alu_operator', 'branch_taken_ex']

DATA={}
for signal_name in SIGNALS:
    base_index, _ = find_signal(signal_name, data, [], [])
    data_tmp = data
    for index in base_index:
        data_tmp = data_tmp['children'][index]
    DATA[signal_name] = data_tmp


signal_val = {}
signal_index = {}
signal_line_str = {'cyc': []}

for signal_name in SIGNALS:
    signal_index[signal_name] = 0
    signal_line_str[signal_name] = []

CYC_START = 556
CYC_STOP= 568
for cyc in range(0, CYC_STOP, 2):
    for signal_name in SIGNALS:
        if signal_index[signal_name] < len(DATA[signal_name]['data']) and cyc == DATA[signal_name]['data'][signal_index[signal_name]][0]:
            signal_val[signal_name] = DATA[signal_name]['data'][signal_index[signal_name]][1]
            #if DATA[signal_name]['type']['width'] > 1:
            #    print(DATA[signal_name]['name'])
            #    signal_val[signal_name] = signal_val[signal_name][1:] # remove 'b' before val
            signal_index[signal_name] += 1
    if cyc > CYC_START:
        signal_line_str['cyc'].append(str(cyc))
        for signal_name in SIGNALS:
            signal_line_str[signal_name].append(hex(int(signal_val[signal_name].replace('b',''), 2))[2:].zfill(int(DATA[signal_name]['type']['width'])//4))

print('\\begin{wave}{' + str(len(SIGNALS) + 1) + '}{' + str((CYC_STOP-CYC_START-3)//2) + '}')
for signal_name in SIGNALS:
    val = '\\known{' + '}{1} \\known{'.join(signal_line_str[signal_name]) + '}{1}'
    print("\\nextwave{" + signal_name.replace('_','\\_') + "} " + val)
print('\\end{wave}')


#
#DISPLAY_CYCLES = False
#
#with open("tb_tmp.vcd") as vcd_file:
#    vcd = VcdParser()
#    vcd.parse(vcd_file)
#    data = vcd.scope.toJson()
#
#instr_vivado = data['children'][0]['children'][8]['children'][28]['children'][13]['data']
#
#
#
#string = ""
#for instr in instr_vivado:
#    time = str(instr[0])[:-3]
#    if not 'x' in instr[1]:
#        value = hex(int(instr[1][1:],2))[2:].zfill(8)
#    else:
#        value = instr[1][1:]
#    if DISPLAY_CYCLES:
#        string += f"{time:>10},{value:>8}\n"
#    else:
#        string += f"{value:>8}\n"
#
#with open("instr_vivado.csv", "w") as f:
#    f.write(string)
#
#
#
#
#
#
#instr_vivado = data['children'][0]['children'][8]['children'][21]['children'][38]['children'][139]['data']
#
#
#string = ""
#for instr in instr_vivado:
#    time = instr[0]
#    if not 'x' in instr[1]:
#        value = hex(int(instr[1][1:],2))[2:].zfill(8)
#    else:
#        value = instr[1][1:]
#    if DISPLAY_CYCLES:
#        string += f"{time:>10},{value:>8}\n"
#    else:
#        string += f"{value:>8}\n"
#
#with open("instr_verilator.csv", "w") as f:
#    f.write(string)

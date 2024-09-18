#!/bin/python3
"""
riscv-get-jalr-successors-from-extracted-signals.py

This script generates a <program>_jalr_successors.csv which contains destination of jalr from a
nominal execution.
"""

import argparse
import subprocess
import os

###### Arguments ######
parser = argparse.ArgumentParser(description="Get the jalr (not ret) successors.")
parser.add_argument("trace_signals_path", help="specify the trace_signal_path file",
                    type=str, nargs='?', const="", default="")
parser.add_argument("jalr_successors_path", help="specify the jalr_successors_path file",
                    type=str, nargs='?', const="", default="")

args = parser.parse_args()

TRACE_SIGNALS_PATH = args.trace_signals_path
JALR_SUCCESSORS_PATH = args.jalr_successors_path


DEBUG = False

class SignalMonitored:
    """
    A class to decode extracted signal line.

    ...

    Attributes
    ----------
    pc_mem : int
        Addr of the PC in memory
    pc_if : int
        Addr of the PC in fetch stage
    pc_id : int
        Addr of the PC in decode stage
    instr_if_dec : int
        Instruction in the fetch stage
    instr_id_dec : int
        Instruction in the fetch stage
    mhpmevent_jump : int
        Flag raised if a jump is taken
    instr_id_bin :  str
        Binary of instruction in the decode stage.

    Methods
    -------
    """

    def __init__(self, line_of_signal_monitored):
        """
        Constructs all the necessary attributes.
        """
        self.pc_mem, self.pc_if, self.pc_id, self.instr_if_dec, self.instr_id_dec, self.mhpmevent_jump = list(
            map(lambda x: int(x, 16), list(filter(('').__ne__, line_of_signal_monitored.split(",", 5)))))
        self.instr_id_bin = bin(self.instr_id_dec)[2:].zfill(32)


def exe_cmd(cmd):
    """ Execute or print a bash command. """
    if DEBUG:
        print(cmd)
    else:
        subprocess.call(cmd, shell=True)



def get_real_jalr_successors():
    '''
    From signals extracted (by using VFLAG="+extract_signals" in make), destinations of
    each jump register (not ret) are computed.
    Signals (instr_addr_o, pc_if_o, pc_id_o, instr_rdata_i, instr_rdata_id_o, mhpmevent_jump)
    are extracted.

    Parameters
    ---------

    Variables
    ---------
    jalr_dict : dict of dict
        Keys are addresses of jalr (not ret). Values are dict with two keys 'asm', and 'successors'.

    Returns
    ----------
    successors : string
        Each line contains the address of a jalr, its delay of execution (in cycles), its successors.
    '''
    with open(TRACE_SIGNALS_PATH, "r", encoding="utf-8") as f:
        signals = list(f.read().split("\n"))

    # break while conditions
    s_max = len(signals)
    s = 0

    jalr_dict = {}

    while s < s_max:
        if signals[s] == '':
            break

        # Decode the extracted signal line
        sm = SignalMonitored(signals[s])

        # Build every jalr (not ret) and check if the decoded instruction is
        # not one of them and there is a jump.
        for rd in range(0, 2):
            for rs1 in range(0, 32):
                jalr_model = f"000000000000{bin(rs1)[2:].zfill(5)}000{bin(rd)[2:].zfill(5)}1100111"

                if jalr_model == sm.instr_id_bin and sm.mhpmevent_jump == 1:
                    # Add the jalr (not ret) if not already met
                    if sm.pc_id not in jalr_dict:
                        jalr_dict[sm.pc_id] = {}
                        jalr_dict[sm.pc_id]["asm"] = "ret" if (
                            rd == 0 and rs1 == 1) else f"jalr x{rd},0(x{rs1})"
                        jalr_dict[sm.pc_id]["successors"] = {}

                    # Add the jalr (not ret) successor if not already met
                    if sm.pc_if not in jalr_dict[sm.pc_id]["successors"]:
                        i = 1
                        delay = 0

                        # Compute delay of jalr (not ret) execution in cycles
                        while True:
                            if SignalMonitored(signals[s - i]).instr_if_dec == sm.instr_id_dec and SignalMonitored(
                                    signals[s - i - 1]).pc_mem == sm.pc_id:
                                jalr_dict[sm.pc_id]["successors"][sm.pc_if] = delay - 1
                                break
                            if i > 50:
                                raise ValueError(
                                    'Destination found but not the jalr instr')
                            if SignalMonitored(
                                    signals[s - i]).instr_if_dec != 0:
                                delay += 1
                            i += 1
        s += 1

    # Format the jalr (not ret) addresses, delays and successors  to be write
    # in a file
    successors = ""
    for j in jalr_dict:
        successors += f"{j},{','.join(map(str,jalr_dict[j]['successors'].keys()))}\n"
#        delay = set(jalr_dict[j]['successors'].values())
#        if len(delay) != 1:
#            raise ValueError(
#                f"The jalr ({j}) do not need the same number of cycles to be executed, depending of the successor targeted ({jalr_dict[j]['successors']}).")
#        successors += f"{j},{list(delay)[0]},{','.join(map(str,jalr_dict[j]['successors'].keys()))}\n"
    return successors


def simulate():
    '''
    For each program, a simulation of nominal execution is performed.
    Signals (instr_addr_o, pc_if_o, pc_id_o, instr_rdata_i, instr_rdata_id_o, mhpmevent_jump)
    are extracted.
    Destinations of JALR are deduced by get_real_jalr_successors().

    Parameters
    ----------

    Returns
    ----------
    '''
    successors = get_real_jalr_successors()
    with open(JALR_SUCCESSORS_PATH, "w", encoding="utf-8") as f:
        f.write(successors)

if __name__ == "__main__":
    simulate()


# class Jalr:
#    def __init__(self, addr, asm):
#        self.asm = asm
#        self.successor = {}
#
# class JalrList:
#    """
#    A class to list every jalr (not ret) and for each of them its successors.
#
#    ...
#
#    Attributes
#    ----------
#    jalr : dict
#        Addr of the PC in memory
#
#    Methods
#    -------
#    add_jalr:
#        Add a jalr if it not already exist.
#
#    add_new_successor:
#        Add a successor to a jalr (not ret) if the successor was not already added.
#    """
#    def __init__(self):
#        self.jalr = {}
#
#    def add_jalr(addr, asm):
#        if addr not in self.jalr:
#            self.jalr[addr] = Jalr(asm)
#
#    def add_new_successor(self, addr_jalr, addr_successor, delay):
#        if addr_successor not in self.successors:
#            self.successors[addr_successor] = delay
#


def count_number_of_jalr():
    '''
    Count each type of jalr from extracted signals.a NOT USED ANYMORE

    Parameters
    ----------

    Returns
    ----------
    successors : string
        Each line contains the address of a jalr, its delay of execution (in cycles), its successors.
    '''
    with open("../../sim/core/signal_extracted.csv", "r", encoding="utf-8") as f:
        signals = list(set(list(f.read().split("\n"))))

    nb_jalr = {}
    nb_jalr["signal_extracted"] = [[0] * 32, [0] * 32]

    for signal in signals[:-1]:
        for rd in range(0, 2):
            for rs1 in range(0, 32):
                if f"000000000000{bin(rs1)[2:].zfill(5)}000{bin(rd)[2:].zfill(5)}1100111" in signal:
                    nb_jalr["signal_extracted"][rd][rs1] += 1

    with open("../../tests/programs/custom/dhrystone/dhrystone_pc_instr.csv", "r", encoding="utf-8") as f:
        signals = list(f.read().split("\n"))

    nb_jalr["objdump"] = [[0] * 32, [0] * 32]

    for signal in signals[:-1]:
        instr = bin(int(list(signal.split(','))[1], 16))[2:].zfill(32)
        for rd in range(0, 2):
            for rs1 in range(0, 32):
                # if f"000000000000{bin(rd)[2:].zfill(5)}000000001100111" in
                # signal:
                if f"000000000000{bin(rs1)[2:].zfill(5)}000{bin(rd)[2:].zfill(5)}1100111" == instr:
                    nb_jalr["objdump"][rd][rs1] += 1

    print(f"         Extracted     Objdump")
    print(f"---------------------------------")
    print(f"   Rd |   0     1  |    0    1  |")
    print(f"---------------------------------")
    print(f"  Rs1 |            |            |")

    for rs1 in range(0, 32):
        print(
            f"{rs1:>4}  |  {nb_jalr['signal_extracted'][0][rs1]:>3}  {nb_jalr['signal_extracted'][1][rs1]:>3}  |  {nb_jalr['objdump'][0][rs1]:>3}  {nb_jalr['objdump'][1][rs1]:>3}  |")

    print(f"---------------------------------")
    print(f"Total |  {sum(nb_jalr['signal_extracted'][0]):>3}  {sum(nb_jalr['signal_extracted'][1]):>3}  |  {sum(nb_jalr['objdump'][0]):>3}  {sum(nb_jalr['objdump'][1]):>3}  |")
    print(f"---------------------------------")
    print(f"TOTAL |  {sum(nb_jalr['signal_extracted'][0]) + sum(nb_jalr['signal_extracted'][1]):>6}    |  {sum(nb_jalr['objdump'][0]) + sum(nb_jalr['objdump'][1]):>6}    |")
    print(f"---------------------------------")

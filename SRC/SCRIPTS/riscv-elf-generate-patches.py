#!/usr/bin/python3
"""
riscv-elf-generate_patches.py

This script generates patches from a <program>.itb and <program>_c_states_dec.csv files.
Patches are wroten in <program>_encrypted_patches.mem file.
"""

import os
import sys
import argparse
import matplotlib.pyplot as plt
from riscv_code import Code

# In some programs the get_ret_successors_rec function is call more than
# 1000 times recursively
sys.setrecursionlimit(10000)

###### Arguments ######
parser = argparse.ArgumentParser(description="generate patch from itb file")
parser.add_argument("src_path", help="specify the source path",
                    type=str, nargs='?', const="", default="")
parser.add_argument("obj_path", help="specify the object path",
                    type=str, nargs='?', const="", default="")
parser.add_argument("-i", "--cs_vector_arch_id", help="use control signal in encryption",
                    type=int, default=0)
parser.add_argument("-v", "--verbose",
                    help="increase output verbosity", action="store_true")
args = parser.parse_args()



def save_several_subgraph(code):
    order_min = -2
    order_max = 1
    save = True
#    code.plot_subgraph(1428, -4, 0, False)
    code.plot_subgraph(1560, order_min, order_max, save)
    code.plot_subgraph(1428, order_min, order_max, save)
    code.plot_subgraph(2496, order_min, order_max, save)
    code.plot_subgraph(5668, order_min, order_max, save)
    code.plot_subgraph(5552, order_min, order_max, save)
    code.plot_subgraph(200, order_min, order_max, save)
    code.plot_subgraph(5592, order_min, order_max, save)
    code.plot_subgraph(9620, order_min, order_max, save)
    code.plot_subgraph(8712, order_min, order_max, save)
    code.plot_subgraph(10648, order_min, order_max, save)
    code.plot_subgraph(12724, order_min, order_max, save)
    code.plot_subgraph(8544, order_min, order_max, save)
    code.plot_subgraph(8800, order_min, order_max, save)
    code.plot_subgraph(12252, order_min, order_max, save)


###### Main ######
if __name__ == "__main__":
    code = Code(args.src_path, args.obj_path, args.cs_vector_arch_id)
    code.read_itb()
    code.get_predecessors()
    code.get_ret_successors()
    code.get_predecessors()
    code.write_successors()
    code.read_states()
    code.get_patches('NL')
    # code.plot_subgraph(NODE0, DISTANCE_MAX)
    # save_several_subgraph(code)

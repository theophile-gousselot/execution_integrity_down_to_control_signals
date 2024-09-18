#!/bin/python3

import argparse


###### Arguments ######
parser = argparse.ArgumentParser(description="")
parser.add_argument(
    "hex_file",
    help="name of programs",
    type=str, nargs='?', const="", default=""
)

args = parser.parse_args()

HEX_FILE = args.hex_file
HEX_FILE_CONVERTED = [f"{HEX_FILE[:-4]}_{j}.mem" for j in range(4)]

def split_hex_4mem():
    with open(HEX_FILE, "r", encoding="utf-8") as f:
        hex_file = list(f.read().split('\n'))

    hex_file_onecolumn = [""] * 4
    for line in hex_file:
        if len(line) == 0:
            #print(f"ERROR: {line}")
            None
        elif line[0] != "@":
            line = line.replace(" ", "")
            for i in range(0, len(line), 8):
                for j in range(4):
                    hex_file_onecolumn[j] += f"{line[i + 2*j : i + 2*j+2]}\n"

    for j in range (4):
        with open(HEX_FILE_CONVERTED[j], "w", encoding="utf-8") as f:
            f.write(hex_file_onecolumn[j])


if __name__ == "__main__":
    split_hex_4mem()


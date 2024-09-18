#!/bin/python3
"""
A python script to replace '%' in Makefile by names of define list of programs.
"""


PROGRAMS=["crc32", "cubic", "dhrystone", "edn", "fibonacci", "huffbench", "matmult-int", "md5sum", "minver", "mont64", "nbody", "nettle-aes", "nettle-sha256", "nsichneu", "picojpeg", "primecount", "qrduino", "sglib-combined", "slre", "st", "statemate", "tarfind", "ud", "verifypin-0", "wikisort"]


def write_explicit_target_names():
    with open("Makefile", "r") as makefile_f:
        makefile_str = makefile_f.read()
    makefile_l = list(makefile_str.split('\n'))

    targets = [] # list of all targets in makefile

    # parse Makefile and build targets list
    i = 0
    while i < len(makefile_l):
        l = makefile_l[i]
        if ":" in l and ":=" not in l and not ".PRECIOUS" in l and not ".PHONY" in l:
            targets.append(l[0:l.index(":")].replace(' ',''))

            # in case there is several targets for same commands
            j = -1
            while "\\" in  makefile_l[i+j]:
                targets.append(makefile_l[i+j][0:makefile_l[i+j].index("\\")].replace(' ',''))
                j = j - 1

        i += 1

    # Build string for explicit_target_names.mk
    # If there is % it will be successively replaced by program name
    # If not, the target is just copy
    string = ""
    for t in targets:
        if "%" in t:
            for p in PROGRAMS:
                target_renamed = t.replace("%", p)
                string += f"{target_renamed} :\n"
                string += f"	make {target_renamed}\n\n"
        else:
            string += f"{t} :\n"
            string += f"	make {t}\n\n"

    #Write explicit_target_names.mk
    with open("explicit_target_names.mk", "w") as f:
        f.write(string)

write_explicit_target_names()

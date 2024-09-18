import os

folder_path = 'OBJ/PROGRAMS'

def intersection(lst1, lst2):
    lst3 = [value for value in lst1 if value in lst2]
    return lst3


def cnt_to_format(cnt):
    line = []
    for key in cnt.keys():
            if key != 'line':
                    line.append(cnt[key])
                    line.append(cnt[key]/cnt['line']*PER_CENT)
    return line

PER_CENT=100

def programs_analysis():
    file_dict = dict(zip(sorted(os.listdir(folder_path)), [os.path.join(folder_path, f) + "/PROGRAM_COMPILED/program.itb" for f in sorted(os.listdir(folder_path))]))
    nb_programs = len(file_dict)
    print("# PROGRAM ANALYSIS")
    print("{:>15}: {:>5} | {:>5} | {:>5} | {:>5}".format("Program", "lines", "br", "jal", "jalr"))
    cnt_tot = {}
    cnt_tot['line'] = 0
    cnt_tot['jal'] = 0
    cnt_tot['jalr'] = 0
    cnt_tot['br'] = 0
    cnt = {}

    for program in file_dict.keys():
        file = file_dict[program]

        with open(file, "r") as f:
            patch_mem=f.read()

        for key in cnt_tot.keys():
            cnt[key] = 0

        patch_mem_l = list(filter(('').__ne__, list(patch_mem.split('\n'))))
        for line in patch_mem_l:
            if line[0] != '#':
                cnt['line'] += 1
                if 'jalr' in line:
                    cnt['jalr'] +=1
                elif 'jal' in line:
                    cnt['jal'] +=1
                elif intersection([' beq ' , ' bne ' , ' blt ' , ' bge ' , ' bltu ' , ' bgeu '], line) != []:
                    cnt['br'] +=1

        print("{:>15}: {:>5.0f}".format(program, cnt['line']) + " | {:>5.0f} (+{:2.1f}) | {:>5.0f} (+{:2.1f}) | {:>5.0f} (+{:2.1f})".format(*cnt_to_format(cnt)))
 
        for key in cnt_tot.keys():
            cnt_tot[key] += cnt[key]

    for key in cnt_tot.keys():
        cnt_tot[key] /= nb_programs
    print("{:>15}: {:>5.0f}".format("AVERAGE", cnt_tot['line']) + " | {:>5.0f} (+{:2.1f}) | {:>5.0f} (+{:2.1f}) | {:>5.0f} (+{:2.1f})".format(*cnt_to_format(cnt_tot)))



def patch_analysis():
    file_dict = dict(zip(sorted(os.listdir(folder_path)), [os.path.join(folder_path, f) + "/PROGRAM_COMPILED/program_encrypted_cs1_patches.mem" for f in sorted(os.listdir(folder_path))]))
    nb_programs = len(file_dict)
    print("# PATCH / REDIRECTION ANALYSIS")
    print("{:>15}: {:>5} | {:>5}({:<3}) | {:>5}({:<3})".format("Program", "lines", "nb patch", "patch/line", "nb redir", "redir/lines"))
    cnt_tot = {}
    cnt_tot['patch'] = 0
    cnt_tot['line'] = 0
    cnt_tot['redir'] = 0
    cnt = {}

    for program in file_dict.keys():
        file = file_dict[program]

        with open(file, "r") as f:
            patch_mem=f.read()

        for key in cnt_tot.keys():
            cnt[key] = 0

        patch_mem_l = list(filter(('').__ne__, list(patch_mem.split('\n'))))
        for line in patch_mem_l:
            cnt['line'] += 1
            if line != "0000000000000000000000000000000000000000000000000000000000000000000000000000000000":
                cnt['patch'] +=1
            if line[2:5] == "fff":
                cnt['redir']+=1

        print("{:>15}: {:>5.0f} | {:>5.0f} (+{:2.1f}) | {:>5.0f} (+{:2.1f})".format(program, cnt['line'], cnt['patch'], cnt['patch']/cnt['line']*PER_CENT,cnt['redir'],cnt['redir']/cnt['line']*PER_CENT))

        for key in cnt_tot.keys():
            cnt_tot[key] += cnt[key]

    for key in cnt_tot.keys():
        cnt_tot[key] /= nb_programs
    print("{:>15}: {:>5.0f} | {:>5.0f} (+{:2.1f}) | {:>5.0f} (+{:2.1f})\n".format("AVERAGE", cnt_tot['line'], cnt_tot['patch'], cnt_tot['patch']/cnt_tot['line']*PER_CENT,cnt_tot['redir'],cnt_tot['redir']/cnt_tot['line']*PER_CENT))


programs_analysis()
patch_analysis()

INSTR_FIELDS = {}
INSTR_FIELDS["R"] = ['rd', 'rs1', 'rs2']
INSTR_FIELDS["I_arith"] = ['rd', 'rs1', 'imm']
INSTR_FIELDS["I_load_jalr"] = ['rd', 'imm', 'rs1']
INSTR_FIELDS["I_env"] = []
INSTR_FIELDS["S"] = ['rs2', 'imm', 'rs1']
INSTR_FIELDS["B"] = ['rs1', 'rs2', 'imm']
INSTR_FIELDS["U"] = ['rd', 'imm']
INSTR_FIELDS["J"] = ['rd', 'imm']
INSTR_FIELDS["SYSTEM"] = []


INSTR_TYPE = {}
INSTR_TYPE['I_arith'] = ['addi', 'xori', 'ori', 'andi', 'slli', 'srli', 'srai', 'slti', 'sltiu']
INSTR_TYPE['I_load_jalr'] = ['lb', 'lh', 'lw', 'lbu', 'lhu', 'jalr']
INSTR_TYPE['I_env'] = ['ecall', 'ebreak']
INSTR_TYPE['S'] = ['sb', 'sh', 'sw']
INSTR_TYPE['B'] = ['beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']
INSTR_TYPE['J'] = ['jal']
INSTR_TYPE['U'] = ['lui', 'auipc']
INSTR_TYPE['SYSTEM'] = ['csrrw', 'csrrs', 'csrrc', 'csrrwi', 'csrrsi', 'csrrci', 'mret', 'wfi']
INSTR_TYPE['R'] = [
    'add',
    'sub',
    'xor',
    'or',
    'and',
    'sll',
    'srl',
    'sra',
    'slt',
    'sltu',
    'mul',
    'mulh',
    'mulhsu',
    'mulhu',
    'div',
    'divu',
    'rem',
    'remu']

INSTR_MULT_EN = ['mul', 'mulh', 'mulhsu', 'mulhu']
DISC_INSTR = ['jalr', 'jal', 'beq', 'bne', 'blt', 'bge', 'bltu', 'bgeu']
LOAD_INSTR = ['lb', 'lh', 'lw', 'lbu', 'lhu']
#LOAD_INSTR = ['lb', 'lh', 'lw', 'lbu', 'lhu', 'jalr']


class Instruction:
    """
    A class to decode the instructions.

    ...

    Attributes
    ----------
    addr : int
        Addr of the PC in memory
    fname : str
       fname
    current_src_file : str
        current source file
    current_src_line : int
        current source line
    mcode : str
         instruction (hex)
    asm_len : str
        number of words in self.asm
    asm : str
         assembler mnemonics
    asm_list : list of str
         list of self.asm words
    inst : str
         inst of the instruction

    (provided by get_type method)
    disc : bool
         true if it is an discontinuity instruction
    type : str
         type of the instruction (R, I_arith, I_load_jalr, I_env, S, B, J, U, SYSTEM)
         as described in the Volume 1, Unprivileged Specification version 20191213
         Chapter 24 "RV32/64G Instruction Set Listings":
         https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf
    rd : int
        Destination register
    rs1 : int
        Source 1 register
    rs2 : int
        Source 2 register
    imm : int
        Immediate

    (provided by get_successors method)
    successors : list of int
        list of addresses which are available destinations
    successors_n : int
        number of successors
    predecessors : list of int
        list of addresses which are available previous instructions
    predecessors_n : int
        number of predecessors

    (provided by get_states method)
    state : list of int (len = 5)
        list of internal state for every instruction when encrypted

    Methods
    -------
    get_type
    get_successors
    """

    def __init__(self, addr, fname, current_src_file, current_src_line, mcode, asm_len, asm):
        self.addr = int(addr)
        self.fname = fname
        self.current_src_file = current_src_file
        self.current_src_line = int(current_src_line)
        self.mcode = mcode
        self.asm_len = int(asm_len)
        self.asm = asm

        # Build a list of instr, fields and comments
        self.asm_list = list(self.asm.split(' '))
        self.inst = self.asm_list[0]
        self.get_type()
        self.get_fields()
        self.get_successors()

    def get_type(self):
        """
        Get the type (R, I_arith, I_load_jalr, I_env, S, B, J, U, SYSTEM) of the instruction,
        and if it is a dicontinuity instruction.
        """
        self.disc = (self.inst in DISC_INSTR)

        self.type = None
        for instr_type in INSTR_TYPE:
            if self.inst in INSTR_TYPE[instr_type]:
                self.type = instr_type
                break
        if self.type is None:
            raise print(
                f"Error, {self.inst} is not referenced, please insert it in INSTR_TYPE dict")

    def get_fields(self):
        """
        Get the fields (rs1, rs2, rd, imm) of the instruction.
        """
        self.fields = [] if self.asm_len == 1 else list(filter(('').__ne__, list(
            self.asm_list[1].replace('(', ',').replace(')', ',').split(','))))

        self.rd, self.rs1, self.rs2, self.imm = None, None, None, None
        for i, field in enumerate(INSTR_FIELDS[self.type]):
            if field == 'imm':
                self.imm = int(self.fields[i], 16)
            elif field == 'rs1':
                self.rs1 = int(self.fields[i].replace('x', ''))
            elif field == 'rs2':
                self.rs2 = int(self.fields[i].replace('x', ''))
            elif field == 'rd':
                self.rd = int(self.fields[i].replace('x', ''))

        if self.inst == 'jalr' and self.rd != 0 and self.imm != 0 and self.rs1 != 1:
            print(
                f"The instruction '{self.addr}: {self.asm}' is an unsupported indirect jump.")

    def get_successors(self):
        """
        Get the successors of the instruction.
        """
        self.successors = []
        self.successors_n = 0
        if self.disc:
            if self.type == 'B':
                self.successors = [self.addr + 4, self.imm]
                self.successors_n = 2
            elif self.inst == 'jal':
                self.successors = [self.imm]
                self.successors_n = 1
            else:
                self.successors = []
                self.successors_n = 0

        else:
            self.successors = [self.addr + 4]
            self.successors_n = 1

        self.predecessors = []
        self.predecessors_n = 0

import os

debug = False
debug_medium = False
debug_one_line = True
debugpermutation = False

#DEBUG_CS = True
#DEBUG_LOG = "debug.log"

DESCRIPTION_LENGTH = 26


# === Ascon AEAD building blocks ===

def ascon_initialize(S, k, rate, a, b, key, nonce):
    """
    Ascon initialization phase - internal helper function.
    S: Ascon state, a list of 5 64-bit integers
    k: key size in bits
    rate: block size in bytes (8 for Ascon-128, Ascon-80pq; 16 for Ascon-128a)
    a: number of initialization/finalization rounds for permutation
    b: number of intermediate rounds for permutation
    key: a bytes object of size 16 (for Ascon-128, Ascon-128a; 128-bit security) or 20 (for Ascon-80pq; 128-bit security)
    nonce: a bytes object of size 16
    returns nothing, updates S
    """
    iv_zero_key_nonce = to_bytes([k, rate * 8, a, b] + (20 - len(key)) * [0]) + key + nonce
    S[0], S[1], S[2], S[3], S[4] = bytes_to_state(iv_zero_key_nonce)
    if debug:
        printstate(S, "initial value:")

    ascon_permutation(S, a)
    if debug_medium:
        printwords(S, f"PERMUTATION ({a})")

    zero_key = bytes_to_state(zero_bytes(40 - len(key)) + key)
    S[0] ^= zero_key[0]
    S[1] ^= zero_key[1]
    S[2] ^= zero_key[2]
    S[3] ^= zero_key[3]
    S[4] ^= zero_key[4]
    if debug_medium:
        printwords(S, f"XOR 0*|K")
    if debug:
        printstate(S, "end of initialization:")


def ascon_process_one_encryption(S, b, rate, instr_plain):
    """
    Ascon plaintext processing phase (during encryption) - internal helper function.
    S: Ascon state, a list of 5 64-bit integers
    b: number of intermediate rounds for permutation
    rate: block size in bytes (8 for Ascon-128, Ascon-80pq; 16 for Ascon-128a)
    plaintext: a bytes object of arbitrary length
    returns the ciphertext (without tag), updates S
    """

    # rate = 4
    S[0] ^= bytes_to_int(instr_plain) << 32
    instr_cipher = int_to_bytes(S[0] >> 32, 4)

    ascon_permutation(S, b)
    if debug_medium:
        printwords(S, f"P({b}) {bytes_to_hex(instr_plain, 8)} => \
{bytes_to_hex(instr_cipher,8)}")

    return instr_cipher

# === Ascon permutation ===

def ascon_permutation(S, rounds=1, debugperm=False):
    """
    Ascon core permutation for the sponge construction - internal helper function.
    S: Ascon state, a list of 5 64-bit integers
    rounds: number of rounds to perform
    returns nothing, updates S
    """
    assert(rounds <= 12)
    debugpermutation=debugperm
    if debugpermutation:
        printwords(S, "permutation input:")
    for r in range(12 - rounds, 12):
        # --- add round constants ---
        S[2] ^= (0xf0 - r * 0x10 + r * 0x1)
        if debugpermutation:
            printwords(S, "round constant addition:")
        # --- substitution layer ---
        S[0] ^= S[4]
        S[4] ^= S[3]
        S[2] ^= S[1]
        T = [(S[i] ^ 0xFFFFFFFFFFFFFFFF) & S[(i + 1) % 5] for i in range(5)]
        for i in range(5):
            S[i] ^= T[(i + 1) % 5]
        S[1] ^= S[0]
        S[0] ^= S[4]
        S[3] ^= S[2]
        S[2] ^= 0XFFFFFFFFFFFFFFFF
        if debugpermutation:
            printwords(S, "substitution layer:")
        # --- linear diffusion layer ---
        S[0] ^= rotr(S[0], 19) ^ rotr(S[0], 28)
        S[1] ^= rotr(S[1], 61) ^ rotr(S[1], 39)
        S[2] ^= rotr(S[2], 1) ^ rotr(S[2], 6)
        S[3] ^= rotr(S[3], 10) ^ rotr(S[3], 17)
        S[4] ^= rotr(S[4], 7) ^ rotr(S[4], 41)
        if debugpermutation:
            printwords(S, "linear diffusion layer:")


# === Ascon permutation inv ===

def ascon_permutation_inv(S, rounds=1, debugperm=False):
    """
    Ascon core permutation for the sponge construction - internal helper function.
    S: Ascon state, a list of 5 64-bit integers
    rounds: number of rounds to perform
    returns nothing, updates S
    """
    assert(rounds <= 12)
    debugpermutation=debugperm
    if debugpermutation:
        printwords(S, "permutation input:")
    for r in range(12 - rounds, 12):

        # --- linear diffusion layer ---
        S[0] ^= rotl(S[0], 19) ^ rotl(S[0], 28)
        S[1] ^= rotl(S[1], 61) ^ rotl(S[1], 39)
        S[2] ^= rotl(S[2], 1) ^ rotl(S[2], 6)
        S[3] ^= rotl(S[3], 10) ^ rotl(S[3], 17)
        S[4] ^= rotl(S[4], 7) ^ rotl(S[4], 41)
        if debugpermutation:
            printwords(S, "linear diffusion layer:")

        # --- add round constants ---
        S[2] ^= (0xf0 - r * 0x10 + r * 0x1)
        if debugpermutation:
            printwords(S, "round constant addition:")
        # --- substitution layer ---
        S[0] ^= S[4]
        S[4] ^= S[3]
        S[2] ^= S[1]
        T = [(S[i] ^ 0xFFFFFFFFFFFFFFFF) & S[(i + 1) % 5] for i in range(5)]
        for i in range(5):
            S[i] ^= T[(i + 1) % 5]
        S[1] ^= S[0]
        S[0] ^= S[4]
        S[3] ^= S[2]
        S[2] ^= 0XFFFFFFFFFFFFFFFF
        if debugpermutation:
            printwords(S, "substitution layer:")



# === Generate number
def get_random_bytes(num):
    return to_bytes(os.urandom(num))


def zero_bytes(n):
    return n * b"\x00"


# === Convert
def state2str(S):
    return(''.join([hex(S[j])[2:].zfill(16) for j in range(4, -1, -1)]))

def to_bytes(l):  # where l is a list or bytearray or bytes
    return bytes(bytearray(l))


def bytes_to_int(bytes):
    return sum([bi << ((len(bytes) - 1 - i) * 8)
               for i, bi in enumerate(to_bytes(bytes))])


def bytes_to_state(bytes):
    return [bytes_to_int(bytes[8 * w:8 * (w + 1)]) for w in range(5)]


def int_to_bytes(integer, nbytes):
    return to_bytes([(integer >> ((nbytes - 1 - i) * 8)) %
                    256 for i in range(nbytes)])


def bytes_to_hex(b):
    return b.hex()
    # return "".join(x.encode('hex') for x in b)


def bytes_to_hex(b, length=8):
    return hex(bytes_to_int(b))[2:].zfill(length)


# === Transform
def rotr(val, r):
    return (val >> r) | ((val & (1 << r) - 1) << (64 - r))

def rotl(val, r):
    return(((val << r) & ((1 << 64) -1)) | (val & (((1 << r) - 1) << (64-r))) >> (64-r))



def reverse_int(instr):
    return (instr & 0xff) << 24 | (instr & 0xff00) << 8 | (
        instr & 0xff0000) >> 8 | (instr & 0xff000000) >> 24


def reverse_bytes(instr):
    bytearray_instr = bytearray(instr)
    bytearray_instr.reverse()
    return bytes(bytearray_instr)


# === Print
def printstate(S, description=""):
    if debug_one_line:
        print(f"{description:<{DESCRIPTION_LENGTH}}",
              "  ".join(["{s:016x}".format(s=s) for s in S]))
    else:
        print(" " + description)
        print(" ".join(["{s:016x}".format(s=s) for s in S]))


def printwords(S, description=""):
    if debug_one_line:
        print(f"{description:<{DESCRIPTION_LENGTH}}", "  ".join(
            ["{s:016x}".format(**locals()) for i, s in enumerate(S)]))
    else:
        print(" " + description)
        print("\n".join(["  x{i}={s:016x}".format(**locals())
              for i, s in enumerate(S)]))

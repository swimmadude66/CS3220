__author__ = 'ayost'

import re

WIDTH = 32
DEPTH = 2048
ADDRESS_RADIX = 'HEX'
DATA_RADIX = 'HEX'

PCREL = [0x8B, 0x65, 0x66, 0x67, 0x6D, 0x6E, 0x6F]
HexDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']
RegNames = ['Zero', 'A0', 'A1', 'A2', 'T0', 'T1', 'S0', 'S1', 'R6', 'R7', 'R8', 'R9', 'R12', 'FP', 'SP', 'RA']
ISA = {
    'ADD'   : 0x00,
    'SUB'   : 0x01,
    'AND'   : 0x04,
    'OR'    : 0x05,
    'XOR'   : 0x06,
    'NAND'  : 0x0C,
    'NOR'   : 0x0D,
    'XNOR'  : 0x0E,
    'ADDI'  : 0x80,
    'SUBI'  : 0x81,
    'ANDI'  : 0x84,
    'ORI'   : 0x85,
    'XORI'  : 0x86,
    'NANDI' : 0x8C,
    'NORI'  : 0x8D,
    'XNORI' : 0x8E,
    'MVHI'  : 0x8B,
    'LW'    : 0x90,
    'SW'    : 0x50,
    'F'     : 0x20,
    'EQ'    : 0x21,
    'LT'    : 0x22,
    'LTE'   : 0x23,
    'T'     : 0x28,
    'NE'    : 0x29,
    'GTE'   : 0x2A,
    'GT'    : 0x2B,
    'FI'    : 0xA0,
    'EQI'   : 0xA1,
    'LTI'   : 0xA2,
    'LTEI'  : 0xA3,
    'TI'    : 0xA8,
    'NEI'   : 0xA9,
    'GTEI'  : 0xAA,
    'GTI'   : 0xAB,
    'BF'    : 0x60,
    'BEQ'   : 0x61,
    'BLT'   : 0x62,
    'BLTE'  : 0x63,
    'BEQZ'  : 0x65,
    'BLTZ'  : 0x66,
    'BLTEZ' : 0x67,
    'BT'    : 0x68,
    'BNE'   : 0x69,
    'BGTE'  : 0x6A,
    'BGT'   : 0x6B,
    'BNEZ'  : 0x6D,
    'BGTZZ' : 0x6E,
    'BGTZ'  : 0x6F,
    'JAL'   : 0xB0
    }



def toHexString(number):
    hexstring = ""
    for i in range(8):
        hexstring = HexDigits[number % 16] + hexstring
        number >>= 4
    return hexstring


def Registers(opcode, params):
    instrbytes = opcode << 16
    i = len(params)
    for param in params:
        regnum = int(param)
        if (regnum <= 15) and (regnum >= 0):
            shifted = regnum << (4*i)
            instrbytes |= shifted
            i -= 1
        else:
            print("Error: Register number out of bounds")
            exit(-1)
    out = instrbytes << 8
    print(toHexString(out))

def Immediate(opcode, params):
    instrbytes = opcode << 16
    if opcode in PCREL:
        params = [params[0], '0', params[1]]
    i = 3
    for p in range(len(params)-1):
        regnum = int(params[p])
        if (regnum <= 15) and (regnum >= 0):
            shifted = regnum << (4*i)
            instrbytes |= shifted
            i -= 1
        else:
            print("Error: Register number out of bounds")
            exit(-1)
    out = instrbytes << 8
    imm = int(params[2])
    if (imm <= 32767) and (imm >= -32768):
        out |= (imm & 0x0000FFFF)
    else:
        print('Invalid Immediate')
        exit(-1)
    print(toHexString(out))

def Offset(opcode, params):
    regOffset = re.sub(r'\s*(.*?)\((.*?)\)\s*', r'\2|\1', params[1])
    offsetArgs = regOffset.split("|")
    newparams = [params[0], offsetArgs[0], offsetArgs[1]]
    return Immediate(opcode, newparams)

def Fake(opcode, params):
    return

def parseLine(line):
    instruction = re.sub(r'^.*?([A-Za-z]{1,5})\s+', r'\1|', line)
    parts = re.split(r'\|', instruction)
    op = parts[0]
    paramstring = parts[1]
    params = re.split(r'\s*,\s*', paramstring)
    opbytes = ISA.get(op.upper())
    opcode = int(opbytes)
    family = opbytes >> 4
    if (family == 0x0) or (family == 0x2):
        Registers(opcode, params)
    elif (family == 0x6) or (family == 0x8) or (family == 0xA):
        Immediate(opcode, params)
    elif (family == 0x5) or (family == 0x9) or (family == 0xB):
        Offset(opcode, params)
    elif family == 0xF:
        Fake(opcode, params)


if __name__ == "__main__":
    parseLine('ADD 4,3,2')
    parseLine('SUB 1,2,3')
    parseLine('F 14,1,1')
    parseLine('ADDI 15,0, -2487')
    parseLine('MVHI 15, 874')
    parseLine(' JAL 15, 87(12)')

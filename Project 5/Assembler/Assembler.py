__author__ = 'ayost'

import re
import sys

WIDTH = 32
DEPTH = 2048
ADDRESS_RADIX = 'HEX'
DATA_RADIX = 'HEX'
VARIABLE_NAMES = dict()
ONEREG = [0x8B, 0x65, 0x66, 0x67, 0x6D, 0x6E, 0x6F]
HexDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']
RegNames = ['R0', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10', 'R11', 'R12', 'R13', 'R14', 'R15']
PreProcess = ['BLT', 'BLTE', 'BGT', 'BGTE']
RegAliases = {
    'A0'    : 0,
    'A1'    : 1,
    'A2'    : 2,
    'A3'    : 3,
    'RV'    : 3,
    'T0'    : 4,
    'T1'    : 5,
    'S0'    : 6,
    'S1'    : 7,
    'S2'    : 8,
    'SSP'   : 10,
    'ZERO'  : 11,
    'GP'    : 12,
    'FP'    : 13,
    'SP'    : 14,
    'RA'    : 15,
    # Special Regs
    'PCS'   : 0,
    'IHA'   : 1,
    'IRA'   : 2,
    'IDN'   : 3
}

ISA = {
    'ADD'   : 0x00,
    'SUB'   : 0x01,
    'AND'   : 0x04,
    'OR'    : 0x05,
    'XOR'   : 0x06,
    'NAND'  : 0x0C,
    'NOR'   : 0x0D,
    'XNOR'  : 0x0E,
    'NXOR'  : 0x0E,
    'ADDI'  : 0x80,
    'SUBI'  : 0x81,
    'ANDI'  : 0x84,
    'ORI'   : 0x85,
    'XORI'  : 0x86,
    'NANDI' : 0x8C,
    'NORI'  : 0x8D,
    'XNORI' : 0x8E,
    'NXORI' : 0x8E,
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
    'BEQZ'  : 0x65,
    'BLTZ'  : 0x66,
    'BLTEZ' : 0x67,
    'BT'    : 0x68,
    'BNE'   : 0x69,
    'BNEZ'  : 0x6D,
    'BGTZZ' : 0x6E,
    'BGTZ'  : 0x6F,
    'JAL'   : 0xB0,
    # Fake instructions
    'BR'    : 0xE0,
    'NOT'   : 0xE2,
    'BLT'   : 0xE3,
    'BLTE'  : 0xE4,
    'BGT'   : 0xE5,
    'BGTE'  : 0xE6,
    'CALL'  : 0xE7,
    'RET'   : 0xE8,
    'JMP'   : 0xE9,
    # System Instructions
    'RETI'  : 0xF1,
    'RSR'   : 0xF2,
    'WSR'   : 0xF3
    }

class Instruction():
    line_number = 0
    location = 0x00
    text = ""
    rawtext = ""

    def __init__(self, ln, l, t, r):
        self.line_number = ln
        self.location = l
        self.rawtext = r
        self.text = t


def toBinaryString(number):
    binstring = ""
    for i in range(WIDTH):
        binstring = str(binstring % 2) + binstring
        binstring >>= 1
    return binstring


def toHexString(number):
    hexstring = ""
    for i in range(WIDTH//4):
        hexstring = HexDigits[number % 16] + hexstring
        number >>= 4
    return hexstring.lower()

def parsenum(num):
    number = str(num)
    output = ""
    if re.match(r'0x[A-Fa-f0-9]+',number):
        number = re.sub(r'^0x', "", number).upper()
        integer = 0
        i = len(number) - 1
        for j in range(0,len(number)):
            char = number[j]
            intrep = HexDigits.index(char)
            integer += intrep * (16 ** i)
            i -= 1
        return integer
    elif re.fullmatch(r'\-?\d+', number):
        return int(number)
    else:
        print("Invalid Number Format")
        exit(-1)

def Registers(opcode, params, location, linenumber):
    instrbytes = opcode << 16
    i = len(params)
    for param in params:
        regnum = int(param)
        if (regnum <= 15) and (regnum >= 0):
            shifted = regnum << (4*i)
            instrbytes |= shifted
            i -= 1
        else:
            print("Error: Register number out of bounds @ " + str(linenumber))
            exit(-1)
    out = instrbytes << 8
    return toHexString(out)

def Immediate(opcode, params, location, linenumber):
    instrbytes = opcode << 16
    if opcode in ONEREG:
        params = [params[0], '0', params[1]]
    i = 3
    for p in range(len(params)-1):
        regnum = int(params[p])
        if (regnum <= 15) and (regnum >= 0):
            shifted = regnum << (4*i)
            instrbytes |= shifted
            i -= 1
        else:
            print("Error: Register number out of bounds @ " + str(linenumber))
            exit(-1)
    out = instrbytes << 8
    imm = params[2].strip()
    if imm in VARIABLE_NAMES.keys():
        imm = VARIABLE_NAMES[imm]
    imm = parsenum(imm)
    if ((opcode >> 4) & 0x0F == 0x06) or opcode == 0xb0:
        if opcode != 0xb0:
            imm -= (location + 4)
        imm //= 4
    if opcode == 0x8B:
        imm >>= 16
        out |= (imm & 0x0000FFFF)
    else:
        if (imm <= 32767) and (imm >= -32768):
            out |= (imm & 0x0000FFFF)
        else:
            print('Invalid Immediate @ ' + str(linenumber))
            exit(-1)
    return toHexString(out)

def Interrupt(opcode, params, location, linenumber):

    newparams = [0x0, 0x0, 0x0000]
    if opcode == 0xF1:      # RETI
        newparams = [0, 0, '0']
    elif opcode == 0xF2:    # RSR
        newparams = [params[0], params[1], '0']
    elif opcode == 0xF3:    # WSR
        newparams = [params[1], params[0], '0']
    else:
        print("Improper format @ line " + linenumber)
        exit(-1)
    return Immediate(opcode, newparams, location, linenumber)

def Offset(opcode, params, location, linenumber):
    regOffset = re.sub(r'\s*(.*?)\((.*?)\)\s*', r'\2|\1', params[1])
    offsetArgs = regOffset.split("|")
    newparams = [params[0], offsetArgs[0], offsetArgs[1]]
    if opcode == 0x50:
        newparams = [offsetArgs[0], params[0], offsetArgs[1]]
    return Immediate(opcode, newparams, location, linenumber)




def Fake(opcode, params, location, linenumber):
    # switch based on opcode
    if opcode == 0xE0:
        # br
        params = [RegNames.index('R6'), RegNames.index('R6'), params[0]]
        return Immediate(ISA['BEQ'], params, location, linenumber)
    elif opcode == 0xE2:
        # not
        params.append(params[1])
        return Registers(ISA['NAND'], params, location, linenumber)
    elif opcode == 0xE7:
        # CALL
        params = [RegAliases['RA'], params[0]]
        return Offset(ISA['JAL'], params, location, linenumber)
    elif opcode == 0xE8:
        # RET
        params = [RegNames.index('R9'), '0(' + str(RegAliases['RA']) + ')']
        return Offset(ISA['JAL'], params, location, linenumber)
    elif opcode == 0xE9:
        # JMP
        params = [RegAliases['RA'], params[0]]
        return Offset(ISA['JAL'], params, location, linenumber)
    else:
        print("Invalid instruction @ " + str(linenumber))
        exit(-1)
    return None




def parseLine(instrline):
    #if instrline.location < 0x40:
    #    return None
    instruction = re.sub(r'^.*?([A-Za-z]{1,5})\s+', r'\1|', instrline.text)
    parts = re.split(r'\|', instruction)
    op = parts[0]
    params = []
    if len(parts) > 1:
        paramstring = parts[1]
        params = re.split(r'\s*,\s*', paramstring)
    opbytes = ISA.get(op.upper())
    opcode = int(opbytes)
    family = opbytes >> 4
    if (family == 0x0) or (family == 0x2):
        return Registers(opcode, params, instrline.location, instrline.line_number)
    elif (family == 0x6) or (family == 0x8) or (family == 0xA):
        return Immediate(opcode, params, instrline.location, instrline.line_number)
    elif (family == 0x5) or (family == 0x9) or (family == 0xB):
        return Offset(opcode, params, instrline.location, instrline.line_number)
    elif family == 0xE:
        return Fake(opcode, params, instrline.location, instrline.line_number)
    elif family == 0xF:
        return Interrupt(opcode, params, instrline.location, instrline.line_number)
    else:
        print("Invalid Format @ line " + instrline.line_number)


def ReadFile(filepath):
    linenum = 0
    currentline = None
    first_line = None
    parsedlines = []
    f = open(filepath, 'r')
    for fline in f:
        nocomm = re.sub(r';.*$', "", fline).strip()
        if nocomm is not "":
            if re.search(r'\.[Nn][Aa][Mm][Ee]', nocomm):
                namestring = re.sub(r'\s*\.[Nn][Aa][Mm][Ee]\s+', "", nocomm)
                varparts = re.split(r'\s*=\s*', namestring.strip())
                name = varparts[0].upper()
                VARIABLE_NAMES[name] = parsenum(varparts[1])
                print(name + " : " + varparts[1])
            elif re.search(r'\.[Oo][Rr][Ii][Gg]', nocomm):
                # read file and assign ORIG
                origstring = re.sub(r'.*\.[Oo][Rr][Ii][Gg]\s+', "", nocomm)
                if first_line is None:
                    first_line = parsenum(origstring) - 0x04
                currentline = parsenum(origstring)
            elif re.search(r'\.[Ww][Oo][Rr][Dd]\s+', nocomm):
                if currentline is None:
                    print('No Orig statement before first mem assignment')
                    exit(-1)
                kvp = re.split(r'\s+', nocomm.strip())
                if re.search(r'(0[Xx]|\-)?[A-Fa-f0-9]+', kvp[1]):
                    VARIABLE_NAMES[currentline] = kvp[1].strip()
                elif kvp[1].upper() in VARIABLE_NAMES.keys():
                    VARIABLE_NAMES[parsenum(currentline//4)] = VARIABLE_NAMES[kvp[1]]
                else:
                    print('Word @ ' + str(linenum) + ' is not a Label or 32-bit value')
                    exit(-1)
                currentline += 0x04
            elif re.search(r'\s*[A-zA-z0-9]:\s*', nocomm):
                labelname = re.sub(r'[\s:]', "", nocomm).upper()
                VARIABLE_NAMES[labelname] = currentline
            else:
                instructionstring = re.sub(r'\s*([A-Za-z]{1,5})\s+', r'\1|', nocomm)
                instrparts = instructionstring.split('|')
                funcs = []
                arguments = []
                if instrparts[0].upper() in PreProcess:
                    # insert 2 instructions instead
                    funcs.append(re.sub(r'^[Bb]', "", instrparts[0]).upper())
                    origargs = re.split(r'\s*,\s*', instrparts[1])
                    arguments.append(['R6', origargs[0], origargs[1]])
                    funcs.append('BNE')
                    arguments.append(['R6', 'Zero', origargs[2]])
                else:
                    funcs.append(instrparts[0].upper())
                    if len(instrparts) > 1:
                        arguments.append(re.split(r'\s*,\s*', instrparts[1]))
                for i in range(len(funcs)):
                    func = funcs[i]
                    args = []
                    if len(arguments) > 0:
                        args = arguments[i]
                    for arg in args:
                        uarg = arg.upper().strip()
                        if (uarg in VARIABLE_NAMES.keys()) or (not re.match(r'^(\-?(\d+|0x[0-9A-Fa-f]+))$', arg)):
                            arg = arg.upper().strip()
                            if arg in RegNames:
                                arg = RegNames.index(arg)
                            elif arg.upper() in RegAliases.keys():
                                arg = RegAliases[arg.upper()]
                            elif re.match(r'(\-)?[A-Za-z\d]+\([A-Za-z\d]+\)', arg):
                                arg1string = re.sub(r'\(.*$', "", arg).upper()
                                arg2string = re.sub(r'^(.*\()|(\).*)$', "", arg).upper()
                                if arg2string in RegNames:
                                    arg2string = RegNames.index(arg2string)
                                elif arg2string in RegAliases.keys():
                                    arg2string = RegAliases[arg2string]
                                else:
                                    print('Invalid insruction @' + str(linenum))
                                    print(fline)
                                arg = str(arg1string) + '(' + str(arg2string) + ')'
                        else:
                            arg = parsenum(arg)
                        func += " " + str(arg) + ","
                    func = re.sub(r',$', "", func)
                    if currentline is None:
                        print("No ORIG Statement... Exiting")
                        exit(-1)
                    parsedlines.append(Instruction(linenum, currentline, func, re.sub(r'\s+', " ", nocomm)))
                    currentline += 0x04
        linenum += 1
    f.close()
    last_line = currentline
    return parsedlines, last_line, first_line

if __name__ == "__main__":
    infile = sys.argv[1]
    outfile = re.sub(r'\..*?$', ".mif", infile)
    lines, last_mem, first_mem = ReadFile(infile)
    miflines = []
    for line in lines:
        print(line.text)
        bytecodes = parseLine(line)
        if bytecodes is not None:
            miflines.append("-- @ 0x" + toHexString(line.location) + " : " + str(line.rawtext) + "\n" + toHexString(line.location//4) + " : " + bytecodes +";\n")
    fout = open(outfile, 'w')
    fout.write("WIDTH=" + str(WIDTH) + ";\n")
    fout.write("DEPTH=" + str(DEPTH) + ";\n")
    fout.write("ADDRESS_RADIX=" + ADDRESS_RADIX + ";\n")
    fout.write("DATA_RADIX=" + DATA_RADIX + ";\n")
    fout.write("CONTENT BEGIN\n")
    if first_mem > 0:
        if ADDRESS_RADIX == 'HEX':
            empty_zones = toHexString(0) + ".." + toHexString(first_mem//4)
        else:
            empty_zones = toBinaryString(0) + ".." + toBinaryString(first_mem//4)
        fout.write("[" + empty_zones + "] : DEAD;\n")
    for mifline in miflines:
        fout.write(mifline)
    if ADDRESS_RADIX == 'HEX':
        empty_zones = toHexString(last_mem//4) + ".." + toHexString(0x07ff)
    else:
        empty_zones = toBinaryString(last_mem//4) + ".." + toBinaryString(0x07ff)
    fout.write("[" + empty_zones + "] : DEAD;\n")
    fout.write('END;\n')
__author__ = 'ayost'

import re

BitWidth = 32
BitDepth = 2048
Radix = "HEX"


def ADD(instruction):
    opcode = b'00'
    paramstring = re.sub(r'^.*?[Aa][Dd][Dd]\s+', "", instruction)
    print(paramstring)
    params = re.split(r'\s*,\s*', paramstring)
    bytecodes = [opcode]

    for i in range(len(params)):
        if int(param) <= 15:
            bytecodes.append(int(param).to_bytes(length=1, byteorder='big'))
    out = b''.join(bytecodes)
    print(str(out))

if __name__ == "__main__":
    ADD('ADD    4, 3, 2')
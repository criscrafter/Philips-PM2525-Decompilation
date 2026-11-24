#!/usr/bin/env python3
"""Run the firmware's remote-command parser (task_543C -> 0x77B6) on test strings in the emulator.

Usage: python parse_cmd.py IMAGE.BIN "FNC VDC" "RNG 3" ...
Prints the parser context after the line is consumed: type byte (2Dh), command index (2Eh),
parameter flags (2Fh), numeric fields (30h, 31h, 2Bh:2Ch), the float accumulator (XDATA 0x01D1)
and the error flag 23h.6.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from emu8051 import CPU

CTX = 0x00DB      # 13 bytes <-> IRAM 2Ah..36h
CMDS = None


def fdec(b):
    if b[0] & 0x7F == 0:
        return 0.0
    return (-1 if b[0] & 0x80 else 1) * int.from_bytes(b[1:], "big") / 2 ** 24 * 2 ** ((b[0] & 0x7F) - 62)


def names(img):
    t, a = [], 0x59B1
    while all(0x20 <= c < 0x7F for c in img[a:a + 3]):
        t.append(img[a:a + 3].decode().strip())
        a += 5
    return t


def run(img, line):
    c = CPU(img)
    c.iram[0x81] = 0x60
    # reset parser state inside its context
    c.iram[0x2A:0x37] = bytes(13)
    c.call(0x7804)
    c.xram[CTX:CTX + 13] = c.iram[0x2A:0x37]
    data = line.encode()
    c.xram[0x13:0x13 + len(data)] = data
    c.iram[0x0C] = 0
    c.iram[0x0D] = 0x80 | 0x40 | len(data)     # line present + end-of-message + count
    for _ in range(4 * len(data) + 8):
        c.call(0x543C)
        if c.xram[CTX + 5] & 0x80 or not (c.iram[0x0D] & 0x80):
            break
    x = c.xram[CTX:CTX + 13]
    acc = bytes(c.xram[0x01D1:0x01D5])
    return {"type": x[3], "idx": x[4], "flags": x[5], "n30": x[6], "n31": x[7],
            "n2b": x[1] << 8 | x[2], "float": fdec(acc), "err": (c.iram[0x24] >> 6) & 1,
            "done": bool(x[5] & 0x80), "ctx": x.hex()}


def main():
    img = open(sys.argv[1], "rb").read()
    nm = names(img)
    for line in sys.argv[2:]:
        r = run(img, line)
        cmd = nm[r["idx"]] if r["idx"] < len(nm) else "?"
        print("%-16r idx=%02X(%-3s) type=%02X flags=%02X n30=%3d n31=%3d n2B=%5d float=%-10g err=%d done=%d" % (
            line, r["idx"], cmd, r["type"], r["flags"], r["n30"], r["n31"], r["n2b"], r["float"], r["err"], r["done"]))


if __name__ == "__main__":
    main()

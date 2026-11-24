#!/usr/bin/env python3
"""Probe number-library routines in the emulator: call with R0/R1 pointing at test operands and print
what changed (as float, as 24-bit int, A, C, OV).

Operand layout (as used by the firmware): R0/R1 point at the TOP byte.
  float: [top]=sign|exp(bias 62), [top-1..top-3] = mantissa (big-endian downwards)
  i24  : [top]=MSB, [top-1], [top-2]=LSB

Usage: python probe_lib.py IMAGE.BIN ADDR [ADDR...] [--a 5.5 --b 2.0 --ia 1000 --ib 7 --acc 3]
"""
import argparse
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from emu8051 import CPU, Halt

RA, RB = 0x43, 0x4B     # operand tops


def fenc(x):
    if x == 0:
        return bytes(4)
    s = 0x80 if x < 0 else 0
    m, e = math.frexp(abs(x))
    mi = int(round(m * 2 ** 24))
    if mi >= 1 << 24:
        mi >>= 1
        e += 1
    return bytes([s | (e + 62)]) + mi.to_bytes(3, "big")


def fdec(b):
    if b[0] & 0x7F == 0:
        return 0.0
    return (-1 if b[0] & 0x80 else 1) * int.from_bytes(b[1:], "big") / 2 ** 24 * 2 ** ((b[0] & 0x7F) - 62)


def put_f(c, top, x):
    b = fenc(x)
    for i in range(4):
        c.iram[top - i] = b[i]


def get_f(c, top):
    return fdec(bytes(c.iram[top - i] for i in range(4)))


def put_i(c, top, v):
    v &= 0xFFFFFF
    c.iram[top], c.iram[top - 1], c.iram[top - 2] = v >> 16, (v >> 8) & 0xFF, v & 0xFF


def get_i(c, top):
    v = c.iram[top] << 16 | c.iram[top - 1] << 8 | c.iram[top - 2]
    return v - (1 << 24) if v & 0x800000 else v


def probe(img, addr, mode, a, b, acc):
    c = CPU(img)
    c.iram[0x81] = 0x60
    if mode == "f":
        put_f(c, RA, a); put_f(c, RB, b)
    else:
        put_i(c, RA, int(a)); put_i(c, RB, int(b))
    c.iram[0], c.iram[1] = RA, RB
    c.a = acc
    before = bytes(c.iram[0:0x80])
    try:
        c.call(addr, max_steps=200000)
        st = "ok"
    except Halt as e:
        st = "HALT " + str(e)
    ch = [i for i in range(0x80) if c.iram[i] != before[i] and i not in (0, 1)]
    return ("%s R0=%02X R1=%02X A=%02X C=%d OV=%d | A-op: f=%.7g i=%d | B-op: f=%.7g i=%d | changed %s" % (
        st, c.iram[0], c.iram[1], c.a, c.cy, (c.iram[0xD0] >> 2) & 1, get_f(c, RA), get_i(c, RA),
        get_f(c, RB), get_i(c, RB), " ".join("%02X" % i for i in ch)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("addrs", nargs="+")
    ap.add_argument("--a", type=float, default=5.5)
    ap.add_argument("--b", type=float, default=2.0)
    ap.add_argument("--ia", type=int, default=1000)
    ap.add_argument("--ib", type=int, default=7)
    ap.add_argument("--acc", type=lambda x: int(x, 0), default=3)
    o = ap.parse_args()
    img = open(o.image, "rb").read()
    for s in o.addrs:
        addr = int(s, 16)
        print("%04X float: %s" % (addr, probe(img, addr, "f", o.a, o.b, o.acc)))
        print("%04X int  : %s" % (addr, probe(img, addr, "i", o.ia, o.ib, o.acc)))


if __name__ == "__main__":
    main()

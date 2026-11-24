#!/usr/bin/env python3
"""Emulate the firmware's reply to "CDP?" (task_remote_reply, 0x4D2B) with known calibration values.

Fills the 114 calibration slots (all three copies) with test floats, sets the pending query to CDP,
calls task_remote_reply until all items are sent, and prints the text the meter would hand to the
interface board (captured at the send routine 0x7C24).

Usage: python emu_cdp.py IMAGE.BIN [--cal-enable] [--altered] [--bad-slot N] [--query DMP]
"""
import argparse
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from emu8051 import CPU

R3_BANK1 = 0x0B          # reply length/state (bit7 = sending, bit6 = last part)
DESC = 0x0056            # interface channel descriptor used for the test


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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("--cal-enable", action="store_true")
    ap.add_argument("--bad-slot", type=int, default=0, help="make the three copies of this slot all differ")
    ap.add_argument("--one-bad-copy", type=int, default=0, help="corrupt only copy 2 of this slot")
    ap.add_argument("--query", default="CDP", choices=["CDP", "DMP"])
    ap.add_argument("--altered", action="store_true", help="seal byte = 'a' (after CDP S)")
    ap.add_argument("--max-items", type=int, default=200)
    a = ap.parse_args()
    img = open(a.image, "rb").read()
    c = CPU(img)
    c.iram[0x81] = 0x60
    # calibration slots: slot n (1-based) = n + 0.25, at 0x0200 + 4(n-1) in all three copies
    for n in range(1, 115):
        v = fenc(n + 0.25)
        for k, base in enumerate((0x0200, 0x03CF, 0x059E)):
            w = bytearray(v)
            if n == a.bad_slot:
                w[1] ^= (k + 1)                 # all three copies differ
            if n == a.one_bad_copy and k == 1:
                w[2] ^= 0x55                    # copy 2 wrong, majority still good
            c.xram[base + 4 * (n - 1):base + 4 * n] = w
    # interface state: channel descriptor active, talker (bit6), nothing being received
    c.iram[0x1D], c.iram[0x1E] = DESC >> 8, DESC & 0xFF
    c.xram[DESC + 2] = 0x40
    c.xram[0x00E8] = {"CDP": 0x22, "DMP": 0x21}[a.query]
    c.xram[0x00E9] = 0
    if a.cal_enable:
        c.bit_wr(0x15, 1)
    out = []

    def send(cpu):
        n = cpu.iram[R3_BANK1] & 0x3F
        out.append(bytes(cpu.xram[0x34:0x34 + n]).decode("latin1") + ("<END>" if cpu.iram[R3_BANK1] & 0x40 else ""))
        cpu.iram[R3_BANK1] = 0           # pretend the interface took the buffer
    c.call_hooks[0x7C24] = send

    # setting byte 4 (3 copies at 0x03CD/0x059C/0x076B): 'N' = normal, 'a' = cal data altered (CDP S)
    for adr in (0x03CD, 0x059C, 0x076B):
        c.xram[adr] = ord("a" if a.altered else "N")
    for _ in range(a.max_items):
        c.call(0x4D2B)
        if c.xram[0x00E8] == 0:
            break
    text = "".join(out)
    print("items sent: %d, reply length %d chars" % (len(out), len(text)))
    for part in out[:6]:
        print(repr(part))
    if len(out) > 6:
        print("...")
        for part in out[-3:]:
            print(repr(part))


if __name__ == "__main__":
    main()

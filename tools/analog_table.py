#!/usr/bin/env python3
"""Dump the per-function/range analog configuration (shift registers 08h/09h, ADC latch 0Ah).

Source: index table 0x29D0 (2 bytes per function: flags, base) and 3-byte entries at 0x29EC + base + range*3,
loaded by the function/range setup block (0x272F..0x276A). Flags: bit0 -> P3.1, bit4 -> P1.4, bit5 -> 2Bh.3.
Usage: python analog_table.py IMAGE.BIN out.md
"""
import sys

img = open(sys.argv[1], "rb").read()
FN = ["Vpeak", "VDC", "VAC", "Vrms", "Ω4W", "Ω2W", "IDC", "IAC", "Time", "CAP", "FRQ", "TempC", "Diode", "Cont"]
masks = [img[0x6ED4 + 3 * f:0x6ED4 + 3 * f + 3] for f in range(14)]
rows = ["| Function | Flags (P3.1 / P1.4 / 2Bh.3) | Range | 08h | 09h | 0Ah (ADC latches) |", "|---|---|---|---|---|---|"]
for f in range(14):
    fl, base = img[0x29D0 + 2 * f], img[0x29D0 + 2 * f + 1]
    fs = "%d / %d / %d" % (fl & 1, fl >> 4 & 1, fl >> 5 & 1)
    for r in range(8):
        if not any(m >> r & 1 for m in masks[f]):
            continue
        i = (base + 3 * r) & 0xFF
        b = img[0x29EC + i:0x29EC + i + 3]
        rows.append("| %s | %s | %d | %s | %s | %s |" % (FN[f], fs, r, *("%02X (%s)" % (x, format(x, "08b")) for x in b)))
open(sys.argv[2], "w", encoding="utf-8").write("# Analog configuration per function/range (tools/analog_table.py)\n\n" + "\n".join(rows) + "\n")
print("rows:", len(rows) - 2)

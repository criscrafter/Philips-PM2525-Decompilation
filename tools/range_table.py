#!/usr/bin/env python3
"""Builds out/range_table.md from the firmware's range data (see DECOMPILATION.md, 'Ranges').

Sources in the image: valid_range_masks (0x6ED4), range_scale_exp bases (0x165A),
count thresholds selected by range_param_lookup (0x19A8, values at 0x6FE9..0x7031).
Usage: python range_table.py IMAGE.BIN out.md
"""
import sys

img = open(sys.argv[1], "rb").read()
fn = ["V peak", "V DC", "V AC", "V rms", "Ω 4-wire (RFW)", "Ω 2-wire (RTW)", "I DC", "I AC",
      "Time interval", "Capacitance", "Frequency", "Temperature", "Diode", "Continuity"]
unit = ["V", "V", "V", "V", "Ω", "Ω", "A", "A", "", "F", "Hz", "°C", "V", "Ω"]
base = [-4, -5, -5, -5, -2, -2, -11, -11, 0, -14, -3, -1, -4, -2]   # from range_scale_exp


def lim(f, r):  # mirrors range_param_lookup; r&4 = meter_state bit 6, r&2 = bit 5
    hi, b5 = bool(r & 4), bool(r & 2)
    if f == 0: return (180, 1000, 1100) if hi else (180, 2000, 2100)
    if f in (1, 2, 3): return (1800, 10000, 11000) if hi else (1800, 20000, 21000)
    if f in (4, 5, 9): return (1800, 20000, 21000)
    if f in (6, 7): return (900, 10000, 11000)
    if f == 8: return (0, 100000, 110000)
    if f == 10: return (9000, 200000, 210000) if (hi and b5) else (9000, 100000, 110000)
    if f == 11: return (0, 4000, 4000)
    return (0, 21000, 21000)


def eng(v, u):
    for e, p in ((1e6, "M"), (1e3, "k"), (1, ""), (1e-3, "m"), (1e-6, "µ"), (1e-9, "n"), (1e-12, "p")):
        if abs(v) >= e * 0.999:
            return "%g %s%s" % (v / e, p, u)
    return "%g %s" % (v, u)


rows = ["| # | Function | Range | Down / up / overload (counts) | Full scale | Count weight | SPEED |",
        "|---|---|---|---|---|---|---|"]
for f in range(14):
    m = img[0x6ED4 + 3 * f:0x6ED4 + 3 * f + 3]
    for r in range(8):
        sp = [str(s + 1) for s in range(3) if m[s] >> r & 1]
        if not sp:
            continue
        lo, fs, ov = lim(f, r)
        e = base[f] + r - (1 if (f == 10 and r == 6) else 0)
        w = 10.0 ** e
        if f == 8:   # time is measured directly in seconds (1 us timer), range r = 10^(r-1) s, overload at 1.1x
            fsv, rv = eng(10.0 ** (r - 1), "s"), "1 µs timer"
        else:
            fsv, rv = eng(fs * w, unit[f]), eng(w, unit[f])
        rows.append("| %d | %s | %d | %d / %d / %d | %s | %s | %s |" % (f, fn[f], r, lo, fs, ov, fsv, rv, ",".join(sp)))
open(sys.argv[2], "w", encoding="utf-8").write("\n".join(rows) + "\n")
print("rows:", len(rows) - 2)

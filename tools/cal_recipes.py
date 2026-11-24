#!/usr/bin/env python3
"""Decode the calibration recipe table (0x76A2) of the PM2525 S25 image.

Table entry per function/range (cal_recipe_ptr, 0x06F0): 2-byte recipe pointer + 2 flag bytes
(flag bit 7 = recipe has two coefficient sets). Index = cal_recipe_offsets[function] + range*4,
or range+2 for current on the 10 A input (flag 25h.6). Offsets are not hard boundaries: a
function's high ranges spill into the next function's slice.

Record layout, from cal_record_layout (0x0754):
  [h0 h1]  A x nA  B x nB  X  C x (nA+1)  D x nD      (16-bit big-endian pointers)
  nA = (h0&1)+1, nB = (h0>>3)&7, nD = (h1>>3)&7
Pointers < 0x0800 are XDATA calibration slots (4-byte floats, copy 1 at 0x0200..0x03C7);
pointers >= 0x0800 are ROM float constants.

Coefficients (cal_f_* modes 0-5) and their use in cal_temp_compensate (0x12BD):
  zero_eff = K0 + K4*(T-K2), gain_eff = K1 + K5*(T-K3), T = internal_temp (XDATA 0x0119).
Usage: python cal_recipes.py IMAGE.BIN out.md
"""
import sys

img = open(sys.argv[1], "rb").read()
FN = ["Vpeak", "VDC", "VAC", "Vrms", "Ω4W", "Ω2W", "IDC", "IAC", "Time", "CAP", "FRQ", "TempC", "Diode", "Cont"]
offs = [int.from_bytes(img[0x738 + 2 * i:0x73A + 2 * i], "big") for i in range(14)]
offs = [o - 0x10000 if o >= 0x8000 else o for o in offs]


def fval(p):
    b = img[p:p + 4]
    if b[0] & 0x7F == 0:
        return 0.0
    s = -1 if b[0] & 0x80 else 1
    return s * int.from_bytes(b[1:], "big") / 2 ** 24 * 2 ** ((b[0] & 0x7F) - 62)


def name(p):
    return "x%03X" % p if p < 0x0800 else "%g" % fval(p)


def parse_record(a):
    h0, h1 = img[a], img[a + 1]
    nA, nB, nD = (h0 & 1) + 1, (h0 >> 3) & 7, (h1 >> 3) & 7
    p = a + 2

    def take(n):
        nonlocal p
        r = [int.from_bytes(img[p + 2 * i:p + 2 * i + 2], "big") for i in range(n)]
        p += 2 * n
        return r
    rec = {"h0": h0, "h1": h1, "A": take(nA), "B": take(nB), "X": take(1), "C": take(nA + 1), "D": take(nD)}
    return rec, p


def fields(rec):
    A, B, X, C, D = (rec[k] for k in "ABXCD")
    nmul = rec["h0"] >> 6
    g = name(B[0]) if B else "1"
    for j, p in enumerate(B[1:]):
        g += (" * " if j < nmul else " / ") + name(p)

    def prod(L):
        return " * ".join(name(p) for p in L) if L else "0"
    return ["K0 zero=%s" % prod(A), "K1 gain=%s" % g, "K2 zTref=%s" % name(X[0]),
            "K3 gTref=%s" % name(C[0]), "K4 zSlope=%s" % prod(C[1:]), "K5 gSlope=%s" % prod(D)]


masks = [img[0x6ED4 + 3 * f:0x6ED4 + 3 * f + 3] for f in range(14)]
starts = sorted(set(int.from_bytes(img[a:a + 2], "big") for a in range(0x76A2, 0x76A2 + 0x10C, 4)))
out = ["| Function | Range | Table @ | Recipe @ | Sets | Cal slots used (XDATA copy 1) |",
       "|---|---|---|---|---|---|"]
detail, problems, used = [], [], set()
for f in range(14):
    variants = [(r, r, "") for r in range(8) if any(m >> r & 1 for m in masks[f])]
    if f in (6, 7):
        variants += [(r, r + 2, " (10 A input)") for r in (5, 6)]
    for r, ri, note in variants:
        e = 0x76A2 + offs[f] + 4 * ri
        ptr = int.from_bytes(img[e:e + 2], "big")
        nrec = 2 if img[e + 2] & 0x80 else 1
        a, recs = ptr, []
        for _ in range(nrec):
            rec, a = parse_record(a)
            recs.append(rec)
        nxt = min([x for x in starts if x > ptr] + [0x76A2])
        if a > nxt:
            problems.append("%s r%d: records run past next recipe (%04X > %04X)" % (FN[f], r, a, nxt))
        slots = sorted(set(p for rec in recs for k in "ABXCD" for p in rec[k] if p < 0x0800))
        used.update(slots)
        out.append("| %s | %d%s | %04X | %04X | %d | %s |" % (
            FN[f], r, note, e, ptr, nrec, " ".join("%03X" % x for x in slots) or "-"))
        for k, rec in enumerate(recs):
            detail.append("%-5s r%d%s set%d: %s" % (FN[f], r, note, k, "; ".join(fields(rec))))

# Calibration points: flag byte (cal_point_flags) bits, matched to the service manual's adjustment
# numbers (section 5.6.6 overview). The match is inferred from function/range/step, not traced.
MANUAL = {
    ("Vpeak", 1, "zero"): "27 (2 VPU zero), 28 (2 VPL zero, set 1)",
    ("Vpeak", 1, "gain"): "33 (2 VPU 2 V), 34 (2 VPL -2 V, set 1)",
    ("VDC", 0, "zero"): "23", ("VDC", 1, "zero"): "24", ("VDC", 2, "zero"): "25", ("VDC", 3, "zero"): "26",
    ("VDC", 0, "gain"): "29", ("VDC", 1, "gain"): "30", ("VDC", 2, "gain"): "31, 32 (-20 V, set 1)",
    ("VDC", 3, "gain"): "46", ("VDC", 4, "gain"): "47",
    ("VAC", 0, "gain"): "35", ("VAC", 1, "gain"): "36", ("VAC", 2, "gain"): "37",
    ("VAC", 3, "gain"): "44", ("VAC", 4, "gain"): "45",
    ("Ω4W", 0, "zero"): "14a", ("Ω4W", 1, "gain"): "15", ("Ω4W", 2, "gain"): "16",
    ("Ω2W", 0, "zero"): "14c", ("Ω2W", 1, "zero"): "14b", ("Ω2W", 3, "gain"): "38",
    ("Ω2W", 4, "gain"): "39", ("Ω2W", 5, "gain"): "40", ("Ω2W", 6, "gain"): "19",
    ("IDC", 1, "zero"): "11", ("IDC", 1, "gain"): "20", ("IDC", 2, "gain"): "21",
    ("IDC", 3, "zero"): "12a", ("IDC", 4, "gain"): "41", ("IDC", 6, "gain"): "42",
    ("IDC", "5 (10 A input)", "zero"): "12b", ("IDC", "5 (10 A input)", "gain"): "22",
    ("IAC", 4, "gain"): "43", ("CAP", 2, "zero"): "13", ("FRQ", 4, "gain"): "10",
    ("TempC", 0, "zero"): "17", ("TempC", 0, "gain"): "18",
}
pts = ["| Function | Range | Flags | Zero cold/hot | Gain cold/hot | Manual adjustment no. |",
       "|---|---|---|---|---|---|"]
for f in range(14):
    variants = [(r, r, "") for r in range(8) if any(m >> r & 1 for m in masks[f])]
    if f in (6, 7):
        variants += [(r, r + 2, " (10 A input)") for r in (5, 6)]
    for r, ri, note in variants:
        fl = img[0x76A2 + offs[f] + 4 * ri + 2]
        if not fl & 0x3F:
            continue
        key = (r if not note else "%d%s" % (r, note))
        z = "%s/%s" % ("x" if fl & 1 else "-", "x" if fl & 0x10 else "-")
        g = "%s/%s" % ("x" if fl & 2 else "-", "x" if fl & 0x20 else "-")
        man = "; ".join(MANUAL[(FN[f], key, s)] for s in ("zero", "gain") if (FN[f], key, s) in MANUAL)
        pts.append("| %s | %s | %02X | %s | %s | %s |" % (FN[f], key, fl, z, g, man or "?"))

lines = [
    "# Calibration recipes (generated by tools/cal_recipes.py)",
    "",
    "## Calibration points",
    "",
    "Flags = cal_point_flags (bit0 zero-cold, 1 gain-cold, 2 store zero Tref, 3 store gain Tref,",
    "4 zero-hot, 5 gain-hot, 7 two coefficient sets). Manual numbers: service manual 5.6.6 (inferred match).",
    "",
] + pts + [
    "",
    "## Recipes",
    "",
    "Per set: zero_eff = K0 + K4*(T-K2), gain_eff = K1 + K5*(T-K3), T = internal_temp (XDATA 0x0119).",
    "Set 1 exists when the table flag bit 7 is set (Vpeak, VDC, CAP); it is swapped in for the second",
    "polarity/direction. Slot names are XDATA addresses in copy 1 (copies 2/3 at +0x1CF/+0x39E).",
    "%d distinct slots are referenced." % len(used),
    "",
] + out + ["", "## Coefficients", "", "```"] + detail + ["```"]
if problems:
    lines += ["", "## Problems", ""] + ["- " + p for p in problems]
open(sys.argv[2], "w", encoding="utf-8").write("\n".join(lines) + "\n")
print("rows", len(out) - 2, "slots", len(used), "problems", len(problems))
for p in problems:
    print(" ", p)

#!/usr/bin/env python3
"""Generate the relocatable assembler source of the PM2525 S25 firmware for sdas8051 (SDCC).

Usage: python make_asm.py IMAGE.BIN SYMS OUT.asm [--shift N]

Layout (link addresses set by fw/build.ps1):
  VECT    (ABS)  0x0000-0x002A  reset and interrupt vectors
  CODE_A  (REL)  0x002B-0x6DAA  code and its tables; may grow/shrink, moves freely
  PINNED  (ABS)  0x6DAB-0x77B5  strings, float constants, calibration recipes: many routines
                                address this block with separately loaded high/low bytes
                                (e.g. MOV 2Dh,#6Eh / MOV 2Eh,#9Dh), so it stays where it is
  CODE_B  (REL)  0x77B6-0x7FFF  remote parser, interface link; moves freely
All references from code into CODE_A/CODE_B are symbolic (labels or label+offset), so routines
can be edited, grown or removed. The 0xFF gaps are kept as `.db` lines marked FREE; deleting them
gives the space back. --shift N inserts N bytes at the start of CODE_A and removes N FREE bytes
(experiment; the relocation test is tools/test_fw.py).
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dis8051 as D8

ap = argparse.ArgumentParser()
ap.add_argument("image")
ap.add_argument("syms")
ap.add_argument("out")
ap.add_argument("--shift", type=int, default=0)
ap.add_argument("--force", action="store_true", help="overwrite an existing source file")
args = ap.parse_args()
if os.path.exists(args.out) and not args.force:
    raise SystemExit("%s exists. It is the maintained source: regenerating would discard your edits. "
                     "Use --force to overwrite." % args.out)

img = open(args.image, "rb").read()
syms = D8.load_syms(args.syms)
size = len(img)
VECT_END, PIN_START, PIN_END = 0x002B, 0x6DAB, 0x77B6


def moving(v):
    return VECT_END <= v < PIN_START or PIN_END <= v < size


# data tables inside the moving windows (everything else that the tracer misses is code)
DATA_TABLES = [(0x0738, 0x0753), (0x0D0B, 0x0D22), (0x29C2, 0x2AA8), (0x35C9, 0x35CA), (0x35D3, 0x35D3),
               (0x35E4, 0x35E5), (0x35EA, 0x35EB), (0x3A91, 0x3AE1), (0x532B, 0x5343), (0x580C, 0x5933),
               (0x5974, 0x5983), (0x59A5, 0x5A83), (0x6543, 0x656E), (0x68DF, 0x6976)]


def in_data_table(a):
    return any(s <= a <= e for s, e in DATA_TABLES)


def run_trace(extra):
    D = D8.Disasm(img, syms)
    D.ccase_helpers = set(syms["ccase"].keys())
    for s, e in syms["dataregion"]:
        D.data_regions.append((s, e, "forced", None))
    entries = [e for e in (0x0000, 0x0003, 0x000B, 0x0013, 0x001B, 0x0023) if img[e] != 0xFF]
    entries += syms["entries"] + extra
    D.syms["entries"] = sorted(set(entries))
    D.trace(entries)
    return D


D = run_trace([])
# untraced fragments in the moving windows: trace them as code too (dead code or reached through
# computed jumps); repeat until stable
extra = []
for _ in range(10):
    new = []
    a = VECT_END
    while a < size:
        if a in D.owner or not moving(a) or in_data_table(a) or img[a] == 0xFF:
            a += 1
            continue
        new.append(a)
        while a < size and a not in D.owner and img[a] != 0xFF and not in_data_table(a):
            a += 1
    new = [x for x in new if x not in extra]
    if not new:
        break
    extra += new
    D = run_trace(extra)

RESERVED = {"a", "b", "c", "ab", "dptr", "pc", "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
            "ar0", "ar1", "ar2", "ar3", "ar4", "ar5", "ar6", "ar7"}
used = set()


def clean(name):
    n = "".join(ch if ch.isalnum() or ch == "_" else "_" for ch in name)
    if n.lower() in RESERVED or n[0].isdigit():
        n = "_" + n
    return n


# ---- labels ----------------------------------------------------------------------------
label_at = {}


def want_label(a):
    if a in label_at or a >= size:
        return
    if a in D.owner and a not in D.insns:
        return                      # inside an instruction: use label+offset
    n = clean(D.name_code(a)) if (a in D.insns or a in syms["code"]) else "T_%04X" % a
    if n in used:
        n = "%s_%04X" % (n, a)
    used.add(n)
    label_at[a] = n


for a in sorted(set(D.call_targets) | set(D.xrefs) | set(D.labels) | set(syms["code"]) | set(D.syms["entries"])):
    want_label(a)
for ins in D.insns.values():                  # DPTR constants into ROM
    if ins.op == 0x90 and ins.imm16 is not None and 0x0800 <= ins.imm16 < size:
        want_label(ins.imm16)
for s, e in DATA_TABLES:
    want_label(s)


def code_ref(t):
    """symbolic reference to ROM address t (label, or nearest label + offset in the same block)"""
    if t in label_at:
        return label_at[t]
    if not moving(t):
        return "0x%04X" % t
    # nearest label at or before t in the same block, else after
    blk = (VECT_END, PIN_START) if t < PIN_START else (PIN_END, size)
    for d in range(1, 64):
        if t - d >= blk[0] and (t - d) in label_at:
            return "%s+%d" % (label_at[t - d], d)
        if t + d < blk[1] and (t + d) in label_at:
            return "%s-%d" % (label_at[t + d], d)
    raise SystemExit("no label near %04X" % t)


# ---- 16-bit pointers stored as data (calibration recipe records in PINNED point to float
# constants; some of them lie in pow10_table, which moves with CODE_A) ----------------------
rd16 = lambda q: img[q] << 8 | img[q + 1]
ptr_words = {}
for e in range(0x76A2, 0x76A2 + 0x10C, 4):
    st = rd16(e)
    if not (PIN_START <= st < PIN_END):
        continue
    q = st
    for _k in range(2 if img[e + 2] & 0x80 else 1):
        h0, h1 = img[q], img[q + 1]
        nA, nB, nD = (h0 & 1) + 1, (h0 >> 3) & 7, (h1 >> 3) & 7
        for i in range(nA + nB + 1 + nA + 1 + nD):
            v = rd16(q + 2 + 2 * i)
            if v >= 0x0800 and moving(v):
                ptr_words[q + 2 + 2 * i] = v
        q += 2 + 2 * (nA + nB + 1 + nA + 1 + nD)
for v in set(ptr_words.values()):
    want_label(v)


# ---- equates -----------------------------------------------------------------------------
equ, dir_name, bit_name, x_name = {}, {}, {}, {}


def add_equ(name, value):
    n = clean(name)
    if n in used:
        n = n + "_"
    used.add(n)
    equ[n] = value
    return n


for v, n in sorted(D8.SFR.items()):
    dir_name[v] = add_equ("sfr_" + n, v)
for v, n in sorted(D8.SFRBITS.items()):
    bit_name[v] = add_equ("sbit_" + n, v)
for v, (n, _) in sorted(syms["data"].items()):
    dir_name[v] = add_equ(n, v)
for v, (n, _) in sorted(syms["bit"].items()):
    bit_name[v] = add_equ(n, v)
for v, (n, _) in sorted(syms["xdata"].items()):
    x_name[v] = add_equ("x_" + n, v)

REGS = {"A": "a", "C": "c", "AB": "ab", "DPTR": "dptr", "@DPTR": "@dptr", "@A+DPTR": "@a+dptr",
        "@A+PC": "@a+pc", "@R0": "@r0", "@R1": "@r1"}


def dptr_is_code(ins):
    """MOV DPTR,#v with v < 0x0800: XDATA unless the following code reads ROM through DPTR"""
    a = ins.addr + ins.size
    for _ in range(8):
        n = D.insns.get(a)
        if n is None:
            return False
        if n.op == 0x93:                          # MOVC A,@A+DPTR
            return True
        if n.op in (0xE0, 0xF0) or n.op == 0x90:  # MOVX / new DPTR
            return False
        if n.mn in ("LCALL", "LJMP"):
            nm = D.name_code(n.targets[0])
            return "code" in nm
        if n.flow in ("ret", "jump", "ijump"):
            return False
        a += n.size
    return False


def fmt(ins):
    parts = []
    for x in ins.args:
        k = x[0]
        if k == "code":
            parts.append(code_ref(x[1]))
        elif k == "dir":
            parts.append(dir_name.get(x[1], "0x%02X" % x[1]))
        elif k == "imm":
            parts.append("#0x%02X" % x[1])
        elif k == "imm16":
            v = x[1]
            if v < 0x0800 and not (v >= VECT_END and dptr_is_code(ins)):
                parts.append("#" + x_name[v] if v in x_name else "#0x%04X" % v)
            elif v < size:
                parts.append("#" + code_ref(v))
            else:
                parts.append("#0x%04X" % v)
        elif k == "bit":
            parts.append(("/" if x[2] else "") + bit_name.get(x[1], "0x%02X" % x[1]))
        elif k == "reg":
            parts.append(REGS.get(x[1], x[1].lower()))
    if ins.mn == "DB_A5":
        return ".db 0xA5"
    return ("%-6s %s" % (ins.mn.lower(), ", ".join(parts))).rstrip()


# ---- emit --------------------------------------------------------------------------------
L = []
w = L.append
w("; PM2525 firmware S25 - relocatable source for sdas8051 (SDCC 4.5)")
w("; Generated once by tools/make_asm.py; from now on this file is the source. Build: python tools/build_fw.py")
w(";")
w("; Areas: VECT (fixed 0x0000), CODE_A (moves, from 0x002B), PINNED (fixed 0x6DAB-0x77B5:")
w("; strings, constants, recipes), CODE_B (moves, from 0x77B6). Code in CODE_A/CODE_B may be")
w("; edited, grown or deleted; the linker moves everything after it. 'FREE' .db lines are unused")
w("; 0xFF bytes: delete them to make room. CODE_A must end before 0x6DAB and CODE_B before 0x8000")
w("; (build_fw.py checks). Do not move anything inside PINNED.")
w("")
w("        .module pm2525")
w("")
w("; ---- equates: SFRs, IRAM, bits, XDATA ----")
for n, v in sorted(equ.items(), key=lambda t: (t[1], t[0])):
    w("%-28s = 0x%04X" % (n, v))
w("")

shift_left = args.shift


def area_header(a):
    if a == 0:
        w("        .area   VECT    (ABS,CODE)")
        w("        .org    0x0000")
    elif a == VECT_END:
        w("")
        w("        .area   CODE_A  (REL,CON,CODE)")
        if args.shift:
            w("        .db " + ", ".join(["0x00"] * args.shift) + " ; relocation test padding")
    elif a == PIN_START:
        w("")
        w("        .area   PINNED  (ABS,CODE)")
        w("        .org    0x%04X" % PIN_START)
    elif a == PIN_END:
        w("")
        w("        .area   CODE_B  (REL,CON,CODE)")


boundaries = {0, VECT_END, PIN_START, PIN_END}
a = 0
while a < size:
    if a in boundaries:
        area_header(a)
    if a in D.insns:
        ins = D.insns[a]
        if a in label_at:
            if a in D.call_targets or a in syms["code"]:
                c = syms["code"].get(a, (None, ""))[1]
                w("")
                if c:
                    w("; " + c)
            w("%s::" % label_at[a])
        cm = syms["comment"].get(a, "")
        w("        %-44s ; %04X%s" % (fmt(ins), a, ("  " + cm) if cm else ""))
        a += ins.size
        continue
    s = a
    a += 1
    while a < size and a not in D.insns and a not in boundaries:
        a += 1
    p = s
    while p < a:
        if p in label_at:
            w("%s::" % label_at[p])
        if p in ptr_words:
            w("        .dw %-80s ; %04X pointer" % (code_ref(ptr_words[p]), p))
            p += 2
            continue
        n = 1
        while n < 16 and p + n < a and (p + n) not in label_at and (p + n) not in ptr_words:
            n += 1
        chunk = bytearray(img[p:p + n])
        free = moving(p) and not in_data_table(p) and all(b == 0xFF for b in chunk)
        if free and shift_left and p >= 0x0100 and p < PIN_START:
            k = min(shift_left, len(chunk))
            chunk = chunk[k:]
            shift_left -= k
        if not chunk:
            p += n
            continue
        tag = "FREE" if free else "".join(chr(b) if 0x20 <= b < 0x7F else "." for b in chunk)
        w("        .db %-80s ; %04X %s" % (", ".join("0x%02X" % b for b in chunk), p, tag))
        p += n

if shift_left:
    raise SystemExit("could not remove %d FREE bytes for the shift" % shift_left)
open(args.out, "w", encoding="utf-8", newline="\n").write("\n".join(L) + "\n")
print("%s: %d lines, %d labels, %d equates, %d extra traced fragments" % (
    args.out, len(L), len(label_at), len(equ), len(extra)))

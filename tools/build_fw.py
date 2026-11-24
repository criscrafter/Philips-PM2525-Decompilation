#!/usr/bin/env python3
"""Build the PM2525 firmware from fw/ (assembly + optional C) into fw/out/pm2525.bin.

Usage: python tools/build_fw.py [--asm fw/pm2525.asm] [--ref firmware/PM2525_S25.BIN]

Steps: sdas8051 each .asm, sdcc -c each fw/c/*.c (large model, no startup code), sdld with the
area addresses below, then checks (areas inside their windows, no overlaps, 32 KB) and writes
the .bin (unused bytes 0xFF). With --ref it reports IDENTICAL or the differing address ranges.

C code: functions go to area CSEG right after CODE_B (so they must fit in the ROM left over);
their variables go to XDATA 0x07A3-0x07FC (unused by the original firmware). IRAM is full: the
build fails if C code needs any DSEG/OSEG/ISEG/BSEG space.
"""
import argparse
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SDCC = os.environ.get("SDCC_BIN", r"C:\Program Files\SDCC\bin")
XRAM_C = (0x07A3, 0x07FC)          # free XDATA for C variables
LIMITS = {"VECT": (0x0000, 0x002B), "CODE_A": (0x002B, 0x6DAB), "PINNED": (0x6DAB, 0x77B6),
          "CODE_B": (0x77B6, 0x8000)}
ROM_AREAS = ("CSEG", "CONST", "HOME", "GSINIT", "GSFINAL")


def run(cmd, cwd):
    env = dict(os.environ)
    env["PATH"] = SDCC + os.pathsep + env.get("PATH", "")      # sdcpp needs cc1 from SDCC's bin
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, env=env)
    out = "\n".join(l for l in (r.stdout + r.stderr).splitlines()
                    if l.strip() and "No definition of area" not in l)
    if out:
        print(out)
    if (r.returncode != 0 and out) or re.search(r"(?i)error", out):
        print(" ".join(cmd))
        sys.exit("build failed")
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--asm", default=os.path.join(ROOT, "fw", "pm2525.asm"))
    ap.add_argument("--ref", default=os.path.join(ROOT, "firmware", "PM2525_S25.BIN"))
    ap.add_argument("--out", default=os.path.join(ROOT, "fw", "out"))
    ap.add_argument("--test-layout", action="store_true",
                    help="relocation test: CODE_A at 0x8100, CODE_B at 0xF000, 64 KB image, no limits")
    a = ap.parse_args()
    a.out = os.path.abspath(a.out)
    os.makedirs(a.out, exist_ok=True)
    rels = []
    src_dir = os.path.dirname(os.path.abspath(a.asm))
    asm_files = [os.path.abspath(a.asm)] + sorted(
        f for f in glob.glob(os.path.join(src_dir, "*.asm")) if os.path.abspath(f) != os.path.abspath(a.asm))
    for f in asm_files:
        base = os.path.join(a.out, os.path.splitext(os.path.basename(f))[0])
        run([os.path.join(SDCC, "sdas8051"), "-plosgff", base + ".rel", f], a.out)
        rels.append(base + ".rel")
    for f in sorted(glob.glob(os.path.join(src_dir, "c", "*.c"))):
        base = os.path.join(a.out, os.path.splitext(os.path.basename(f))[0])
        run([os.path.join(SDCC, "sdcc"), "-mmcs51", "--model-large", "--no-xinit-opt", "--opt-code-size",
             "-I", os.path.join(src_dir, "c"), "-c", f, "-o", base + ".rel"], a.out)
        rels.append(base + ".rel")
    ihx = os.path.join(a.out, "pm2525.ihx")
    lib = os.path.join(os.path.dirname(SDCC), "lib", "large")
    base_a = 0x8100 if a.test_layout else 0x002B
    base_b = 0xF000 if a.test_layout else 0x77B6

    def link(c_at):
        cmd = [os.path.join(SDCC, "sdld"), "-n", "-m", "-w", "-u", "-i",
               "-b", "CODE_A=0x%04X" % base_a, "-b", "CODE_B=0x%04X" % base_b,
               "-b", "XSEG=0x%04X" % XRAM_C[0], "-b", "PSEG=0x%04X" % XRAM_C[0]]
        for name, addr in c_at:
            cmd += ["-b", "%s=0x%04X" % (name, addr)]
        run(cmd + ["-k", lib, "-l", "mcs51", ihx] + rels, a.out)
        mp = open(os.path.join(a.out, "pm2525.map"), encoding="latin1").read()
        ar = {}
        for m in re.finditer(r"^(\w+)\s+([0-9A-F]{8})\s+([0-9A-F]{8})\s+=\s+(\d+)\.\s+bytes", mp, re.M):
            ar[m.group(1)] = (int(m.group(2), 16), int(m.group(3), 16))
        return ar

    # pass 1: C areas out of the way, to learn the sizes
    C_AREAS = ["CSEG", "CONST", "HOME", "GSINIT", "GSFINAL"]
    areas = link([(n, 0xC000 + 0x0800 * i) for i, n in enumerate(C_AREAS)])
    c_sizes = [(n, areas.get(n, (0, 0))[1]) for n in C_AREAS]
    c_total = sum(n for _, n in c_sizes)
    if areas.get("XINIT", (0, 0))[1]:
        print("ERROR: C code has initialised xdata variables; there is no startup code to set them. "
              "Initialise them in code instead.")
        sys.exit("build failed")
    if c_total and not a.test_layout:
        gaps = [(base_a + areas["CODE_A"][1], 0x6DAB), (base_b + areas["CODE_B"][1], 0x8000)]
        place = next((g for g in gaps if g[1] - g[0] >= c_total), None)
        if place is None:
            print("ERROR: C code needs %d bytes; free ROM: %s. Delete FREE lines or replace assembly "
                  "routines to make room." % (c_total, ", ".join("%d bytes at 0x%04X" % (g[1] - g[0], g[0])
                                                                 for g in gaps)))
            sys.exit("build failed")
        at, p = [], place[0]
        for n, sz in c_sizes:
            at.append((n, p))
            p += sz
        areas = link(at)
        print("C code: %d bytes at 0x%04X" % (c_total, place[0]))
    elif c_total:
        areas = link([(n, 0xC000 + 0x0800 * i) for i, n in enumerate(C_AREAS)])
    ok = True
    # internal RAM: the firmware uses all of it. Sizes come from the object files (the map reports
    # DSEG after the register banks even when it is empty). REG_BANK_0 is the firmware's own bank 0.
    for r in rels:
        for m in re.finditer(r"^A (DSEG|OSEG|ISEG|BSEG|SSEG|BIT_BANK|REG_BANK_[123]) size ([0-9A-F]+)",
                             open(r, encoding="latin1").read(), re.M):
            if int(m.group(2), 16):
                print("ERROR: %s uses %d bytes of internal RAM (%s); IRAM is fully used by the firmware. "
                      "Use __xdata variables." % (os.path.basename(r), int(m.group(2), 16), m.group(1)))
                ok = False
    for name, (start, n) in sorted(areas.items(), key=lambda t: t[1][0]):
        if n == 0:
            continue
        lim = LIMITS.get(name)
        if name in ("XSEG", "PSEG") and start + n - 1 > XRAM_C[1]:
            print("ERROR: C variables need %d bytes XDATA, only %d free" % (n, XRAM_C[1] - XRAM_C[0] + 1))
            ok = False
        if name in ROM_AREAS and not a.test_layout and start + n > 0x8000:
            print("ERROR: area %s beyond the 32 KB EPROM" % name)
            ok = False
        if lim and not a.test_layout and not (lim[0] <= start and start + n <= lim[1]):
            print("ERROR: area %s 0x%04X-0x%04X outside its window 0x%04X-0x%04X" % (
                name, start, start + n - 1, lim[0], lim[1] - 1))
            ok = False
    code_end = max((s + n for nm, (s, n) in areas.items() if nm not in ("XSEG", "PSEG", "DSEG", "OSEG",
                    "ISEG", "BSEG", "SSEG", "XISEG", "XINIT", "IABS", "XABS", "PINNED", "VECT", "CODE_A") and n
                    and s >= 0x77B6), default=0x8000)
    # ---- ihx -> bin with overlap check
    romsize = 0x10000 if a.test_layout else 0x8000
    data = bytearray(b"\xFF" * romsize)
    written = bytearray(romsize)
    hi = 0
    for line in open(ihx):
        line = line.strip()
        if not line.startswith(":"):
            continue
        b = bytes.fromhex(line[1:])
        n, ad, typ = b[0], b[1] << 8 | b[2], b[3]
        if typ == 4:
            hi = (b[4] << 8 | b[5]) << 16
        if typ != 0:
            continue
        ad += hi
        if ad >= 0x10000:
            continue                     # XDATA initialisers are not part of the ROM
        for i in range(n):
            p = ad + i
            if p >= romsize:
                print("ERROR: code at 0x%04X is beyond the 32 KB EPROM" % p)
                ok = False
                break
            if written[p]:
                print("ERROR: two areas overlap at 0x%04X" % p)
                ok = False
                break
            written[p] = 1
            data[p] = b[4 + i]
    if not ok:
        sys.exit("build failed")
    binf = os.path.join(a.out, "pm2525.bin")
    open(binf, "wb").write(data)
    used = sum(written)
    print("built %s: %d bytes used, %d free (CODE_B+C end 0x%04X)" % (binf, used, romsize - used, code_end))
    for name in ("CODE_A", "CODE_B", "CSEG", "CONST", "HOME", "XSEG"):
        if name in areas and areas[name][1]:
            s, n = areas[name]
            print("  %-7s 0x%04X-0x%04X  %5d bytes" % (name, s, s + n - 1, n))
    if a.ref and os.path.exists(a.ref) and not a.test_layout:
        ref = open(a.ref, "rb").read()
        diff = [i for i in range(len(ref)) if ref[i] != data[i]]
        if not diff:
            print("IDENTICAL to %s" % os.path.relpath(a.ref, ROOT))
        else:
            rng, s = [], diff[0]
            for x, y in zip(diff, diff[1:] + [None]):
                if y != x + 1:
                    rng.append((s, x))
                    s = y
            print("differs from %s in %d bytes, %d ranges: %s%s" % (
                os.path.relpath(a.ref, ROOT), len(diff), len(rng),
                " ".join("%04X-%04X" % r if r[0] != r[1] else "%04X" % r[0] for r in rng[:12]),
                " ..." if len(rng) > 12 else ""))


if __name__ == "__main__":
    main()

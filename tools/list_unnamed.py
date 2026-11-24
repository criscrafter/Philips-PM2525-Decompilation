#!/usr/bin/env python3
"""Compact one-line-per-instruction listing of every unnamed function, for bulk naming.

Usage: python list_unnamed.py IMAGE.BIN SYMS [--max-insns 18] [--start 0 --end 0x8000]
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from match_versions import analyze


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("sym")
    ap.add_argument("--max-insns", type=int, default=18)
    ap.add_argument("--start", type=lambda x: int(x, 0), default=0)
    ap.add_argument("--end", type=lambda x: int(x, 0), default=0x8000)
    a = ap.parse_args()
    d, f = analyze(a.image, a.sym)
    names = set()
    for l in open(a.sym, encoding="utf-8"):
        x = l.split("#")[0].split()
        if len(x) >= 3 and x[0] == "code":
            names.add(int(x[1], 16))
    for e in sorted(f):
        if e in names or not (a.start <= e < a.end):
            continue
        body = f[e]
        size = sum(d.insns[x].size for x in body)
        callers = sorted(x for x in d.xrefs.get(e, ()) if x in d.insns)
        cf = sorted(set(d.name_code(max(k for k in f if k <= c)) for c in callers))[:4]
        ops = []
        for x in body[:a.max_insns]:
            ops.append(" ".join(d.fmt_insn(d.insns[x]).split()))
        more = " …" if len(body) > a.max_insns else ""
        print("%04X [%dB, from %s]: %s%s" % (e, size, ",".join(cf) or "-", " | ".join(ops), more))


if __name__ == "__main__":
    main()

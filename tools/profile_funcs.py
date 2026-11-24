#!/usr/bin/env python3
"""Per-function profile: size, callers, callees, SFR/bit use, xdata, code-pointer refs.

Usage: python profile_funcs.py IMAGE.BIN SYMS out.txt
"""
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dis8051 as D
from match_versions import analyze

img_path, sym_path, out = sys.argv[1:4]
d, funcs = analyze(img_path, sym_path)
img = d.img
callers = {}
for e in funcs:
    callers[e] = sorted(x for x in d.xrefs.get(e, ()) if x in d.insns and d.insns[x].flow == "call")

with open(out, "w", encoding="utf-8") as w:
    for e, body in sorted(funcs.items()):
        size = sum(d.insns[a].size for a in body)
        sfr = Counter(); bits = Counter(); xd = Counter(); ptr = Counter(); calls = []
        for a in body:
            ins = d.insns[a]
            for v in ins.dir_refs:
                if v >= 0x80:
                    sfr[D.SFR.get(v, "%02X" % v)] += 1
            for b in ins.bit_refs:
                bits[d.fmt_bit(b)] += 1
            if ins.op == 0x90:
                v = ins.imm16
                if v < 0x0800 or v >= 0x8000:
                    xd["%04X" % v] += 1
                else:
                    s = d.peek_string(v, 3)
                    ptr["%04X%s" % (v, ("'" + s[:12] + "'") if s else "")] += 1
            if ins.flow == "call":
                calls.append(d.name_code(ins.targets[0]))
        w.write("%04X %-10s size=%-4d callers=%-3d %s\n" % (e, d.name_code(e), size, len(callers[e]),
                                                         " ".join("%04X" % c for c in callers[e][:8])))
        if sfr: w.write("   sfr: %s\n" % " ".join("%s:%d" % kv for kv in sfr.most_common()))
        if bits: w.write("   bits: %s\n" % " ".join("%s:%d" % kv for kv in bits.most_common(14)))
        if xd: w.write("   xdata: %s\n" % " ".join(sorted(xd)))
        if ptr: w.write("   cptr: %s\n" % " ".join(sorted(ptr)))
        if calls: w.write("   calls: %s\n" % " ".join(dict.fromkeys(calls)))
print("ok")

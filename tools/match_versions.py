#!/usr/bin/env python3
"""Match functions between two 8051 firmware versions (S25 target, S08 reference).

Usage: python match_versions.py A.BIN A.sym B.BIN B.sym out_prefix
Writes out_prefix.csv (A_addr,A_name,B_addr,method,score,sizeA,sizeB) and out_prefix.txt summary.
"""
import difflib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dis8051 as D


def analyze(img_path, sym_path):
    img = open(img_path, "rb").read()
    syms = D.load_syms(sym_path)
    d = D.Disasm(img, syms)
    d.ccase_helpers = set(syms["ccase"].keys())
    entries = [e for e in (0, 3, 0xB, 0x13, 0x1B, 0x23) if img[e] != 0xFF] + syms["entries"]
    d.syms["entries"] = sorted(set(entries))
    d.trace(entries)
    funcs = d.functions()
    return d, funcs


def tokens(d, body, mask_data=False):
    """Normalized token list for a function body (in address order)."""
    out = []
    for a in body:
        ins = d.insns[a]
        t = [ins.mn]
        for x in ins.args:
            k = x[0]
            if k == "code":
                # keep only relative shape: is it inside the function?
                t.append("C")
            elif k == "imm16":
                v = x[1]
                t.append("X" if (mask_data or v >= 0x0100) else "#%04X" % v)
            elif k == "dir":
                t.append("D" if mask_data and x[1] < 0x80 else "%02X" % x[1])
            elif k == "bit":
                t.append("B" if mask_data and x[1] < 0x80 else "b%02X" % x[1])
            elif k == "imm":
                t.append("#%02X" % x[1])
            else:
                t.append(x[1])
        out.append(" ".join(t))
    return out


def callees(d, body):
    r = []
    for a in body:
        ins = d.insns[a]
        if ins.flow == "call":
            r.append(ins.targets[0])
    return r


def main():
    a_img, a_sym, b_img, b_sym, prefix = sys.argv[1:6]
    A, Af = analyze(a_img, a_sym)
    B, Bf = analyze(b_img, b_sym)
    info = {}
    for tag, d, fs in (("A", A, Af), ("B", B, Bf)):
        info[tag] = {}
        for e, body in fs.items():
            if not body:
                continue
            info[tag][e] = {
                "exact": tuple(tokens(d, body)),
                "loose": tuple(tokens(d, body, True)),
                "calls": callees(d, body),
                "size": sum(d.insns[x].size for x in body),
            }
    match = {}   # A -> (B, method, score)
    usedB = set()

    def add(a, b, m, s):
        if a in match or b in usedB:
            return False
        match[a] = (b, m, s)
        usedB.add(b)
        return True

    # 1) unique exact / loose hashes
    for key in ("exact", "loose"):
        ha, hb = {}, {}
        for e, v in info["A"].items():
            ha.setdefault(v[key], []).append(e)
        for e, v in info["B"].items():
            hb.setdefault(v[key], []).append(e)
        for h, la in ha.items():
            lb = hb.get(h, [])
            la2 = [x for x in la if x not in match]
            lb2 = [x for x in lb if x not in usedB]
            if len(la2) == 1 and len(lb2) == 1:
                add(la2[0], lb2[0], key, 1.0)
            elif la2 and len(la2) == len(lb2) and len(la2[0:1]) and len(info["A"][la2[0]][key]) > 3:
                # identical duplicates: pair in address order
                for x, y in zip(sorted(la2), sorted(lb2)):
                    add(x, y, key + "-ordered", 1.0)

    def sim(a, b):
        return difflib.SequenceMatcher(None, info["A"][a]["loose"], info["B"][b]["loose"], autojunk=False).ratio()

    # 2) call-graph propagation: matched callers -> callees in same call order
    changed = True
    while changed:
        changed = False
        for a, (b, m, s) in list(match.items()):
            ca, cb = info["A"][a]["calls"], info["B"][b]["calls"]
            sm = difflib.SequenceMatcher(None, ["x"] * 0 + [str(len(info["A"].get(x, {}).get("loose", ()))) for x in ca],
                                         [str(len(info["B"].get(x, {}).get("loose", ()))) for x in cb], autojunk=False)
            # align by position when call counts equal, else by opcodes of callee
            pairs = list(zip(ca, cb)) if len(ca) == len(cb) else []
            if not pairs:
                for blk in difflib.SequenceMatcher(None, [str(x in match) for x in ca], [str(x in usedB) for x in cb], autojunk=False).get_matching_blocks():
                    pass
            for x, y in pairs:
                if x in info["A"] and y in info["B"] and x not in match and y not in usedB:
                    s2 = sim(x, y)
                    if s2 >= 0.6:
                        add(x, y, "callgraph", round(s2, 3))
                        changed = True

    # 3) fuzzy: remaining A functions vs remaining B near expected offset (neighbour delta)
    def expected(a):
        ks = sorted(match)
        lo = max([k for k in ks if k < a], default=None)
        hi = min([k for k in ks if k > a], default=None)
        ds = [match[k][0] - k for k in (lo, hi) if k is not None]
        return [a + dd for dd in ds]

    for a in sorted(info["A"]):
        if a in match:
            continue
        best = None
        cands = [b for b in info["B"] if b not in usedB]
        exp = expected(a)
        near = [b for b in cands if any(abs(b - e) < 0x400 for e in exp)] or cands
        for b in near:
            la, lb = len(info["A"][a]["loose"]), len(info["B"][b]["loose"])
            if min(la, lb) / max(la, lb, 1) < 0.5:
                continue
            s = sim(a, b)
            if best is None or s > best[1]:
                best = (b, s)
        if best and best[1] >= 0.55:
            add(a, best[0], "fuzzy", round(best[1], 3))

    # output
    with open(prefix + ".csv", "w") as w:
        w.write("s25_addr,s25_name,s08_addr,method,score,s25_size,s08_size,delta\n")
        for a in sorted(info["A"]):
            if a in match:
                b, m, s = match[a]
                w.write("%04X,%s,%04X,%s,%s,%d,%d,%+d\n" % (a, A.name_code(a), b, m, s,
                                                         info["A"][a]["size"], info["B"][b]["size"], b - a))
            else:
                w.write("%04X,%s,,unmatched,0,%d,,\n" % (a, A.name_code(a), info["A"][a]["size"]))
    unA = [a for a in info["A"] if a not in match]
    unB = [b for b in info["B"] if b not in usedB]
    changed_f = [a for a, (b, m, s) in match.items() if m not in ("exact", "exact-ordered")]
    with open(prefix + ".txt", "w") as w:
        w.write("S25 functions: %d, S08 functions: %d, matched: %d\n" % (len(info["A"]), len(info["B"]), len(match)))
        from collections import Counter
        w.write("by method: %s\n" % dict(Counter(m for b, m, s in match.values())))
        w.write("\nS25-only functions (new or heavily changed):\n")
        for a in sorted(unA):
            w.write("  %04X  %-12s %5d bytes\n" % (a, A.name_code(a), info["A"][a]["size"]))
        w.write("\nS08-only functions (removed or heavily changed):\n")
        for b in sorted(unB):
            w.write("  %04X  %5d bytes\n" % (b, info["B"][b]["size"]))
        w.write("\nMatched but changed (not instruction-identical):\n")
        for a in sorted(changed_f):
            b, m, s = match[a]
            w.write("  %04X <- %04X  %-14s %.3f  %d/%d bytes\n" % (a, b, m, s, info["A"][a]["size"], info["B"][b]["size"]))
    print(open(prefix + ".txt").read()[:3000])


if __name__ == "__main__":
    main()

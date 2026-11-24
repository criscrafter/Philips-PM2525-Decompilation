#!/usr/bin/env python3
"""Compare the grammar of src/clean/remote_parser.c (mirrored here in Python) with the original
parser running in the emulator, token by token.

Usage: python check_parser.py IMAGE.BIN
Compared per token: command index, parameter kind (flags bits 0-2 / word), integer value,
word position/length, number value. The type byte is not compared (the original clears the bits it
has used; the C version keeps the table value).
"""
import itertools
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from emu8051 import CPU

# --- optional: run the routines from a rebuilt firmware instead of the original image.
# PM_EXEC = the built .bin; PM_MAP = its linker map. Routines are found by label name: the address
# of the label in the original layout (PM_REFMAP, default fw/out_ref/pm2525.map) -> its new address.
# Without PM_MAP the relocation-test layout (build_fw.py --test-layout) is assumed.
EXEC_PATH = os.environ.get("PM_EXEC")
EXEC_IMG = open(EXEC_PATH, "rb").read() if EXEC_PATH else None


def _read_map(path):
    m = {}
    for line in open(path, encoding="latin1"):
        g = re.match(r"^C:\s+([0-9A-F]{8})\s+(\w+)", line)
        if g:
            m[g.group(2)] = int(g.group(1), 16)
    return m


_NEW = _read_map(os.environ["PM_MAP"]) if os.environ.get("PM_MAP") else None
_OLD = {}
if _NEW is not None:
    _ref = os.environ.get("PM_REFMAP", os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                                                    "fw", "out_ref", "pm2525.map"))
    for _n, _a in _read_map(_ref).items():
        _OLD.setdefault(_a, _n)


def RA(addr):
    if not EXEC_PATH:
        return addr
    if _NEW is not None:
        return _NEW[_OLD[addr]]
    if 0x002B <= addr < 0x6DAB:
        return addr + 0x8100 - 0x002B
    if 0x77B6 <= addr < 0x8000:
        return addr + 0xF000 - 0x77B6
    return addr
    if 0x002B <= addr < 0x6DAB:
        return addr + 0x8100 - 0x002B
    if 0x77B6 <= addr < 0x8000:
        return addr + 0xF000 - 0x77B6
    return addr
import parse_cmd as P


def orig_tokens(img, line):
    c = CPU(EXEC_IMG if EXEC_PATH else img)
    c.iram[0x81] = 0x60
    c.iram[0x2A:0x37] = bytes(13)
    c.call(RA(0x7804))
    c.xram[0xDB:0xDB + 13] = c.iram[0x2A:0x37]
    d = line.encode()
    c.xram[0x13:0x13 + len(d)] = d
    c.iram[0x0C] = 0
    c.iram[0x0D] = 0xC0 | len(d)
    out = []
    for _ in range(400):
        c.call(RA(0x543C))
        x = c.xram[0xDB:0xDB + 13]
        if x[5] & 0x80:
            out.append(decode(x))
            c.xram[0xDB + 5] &= 0x7F
        if not (c.iram[0x0D] & 0x80):
            break
    return out


def decode(x):
    idx, fl = x[4], x[5]
    if idx == 0x30:
        return ("END",)
    if (fl & 0x70) == 0x70:
        return (idx, "word", x[6], x[7])
    k = fl & 7
    if k == 4:
        return (idx, "num", round(P.fdec(bytes([x[9], x[8], x[7], x[6]])), 6))
    if k in (2, 3):
        return (idx, "int%d" % k, x[6] if k == 2 else x[6] | x[7] << 8)
    return (idx, {0: "off", 1: "on", 5: "none", 6: "query"}.get(k, "k%d" % k))


def mirror_tokens(table, line):
    """Python mirror of parse_line() in src/clean/remote_parser.c"""
    out, p, L = [], 0, line
    sep = " ,;"

    def param_at(p, typ, idx):
        s = L[p:]
        if s.startswith("?"):
            if typ & 0x20:
                return (idx, "query"), p + 1
            if typ & 0x10:
                return (idx, "word", p, 1), p + 1
            return None, p
        if typ & 0x01 and (s[:2].upper() == "ON" or s[:3].upper() == "OFF"):
            on = s[:2].upper() == "ON" and not (len(s) > 2 and s[2].isalpha())
            return (idx, "on" if on else "off"), p + (2 if on else 3)
        if typ & 0x02 and s[:1].isdigit():
            q = p
            while q < len(L) and L[q].isdigit():
                q += 1
            plain = q >= len(L) or L[q] in sep
            v = int(L[p:q])
            if not (typ & 0x08) or (plain and v <= 255):
                return (idx, "int2", min(v, 255)), q
        if typ & 0x04 and s[:1] and (s[0].isdigit() or (s[0] in "+-" and s[1:2].isdigit())):
            q = p + 1
            while q < len(L) and L[q].isdigit():
                q += 1
            return (idx, "int3", int(L[p:q]) & 0xFFFF), q
        if typ & 0x08 and s[:1] and (s[0] in "+-." or s[0].isdigit()):
            q = p + 1
            while q < len(L) and (L[q].isdigit() or L[q] in ".eE" or (L[q] in "+-" and L[q - 1] in "eE")):
                q += 1
            return (idx, "num", round(float(L[p:q]), 6)), q
        if typ & 0x10:
            q = p
            while q < len(L) and L[q] not in sep:
                q += 1
            return (idx, "word", p, q - p), q
        return None, p

    while True:
        while p < len(L) and L[p] == " ":
            p += 1
        if p >= len(L):
            break
        word = ""
        q = p
        while q < len(L) and L[q].isalpha():
            q += 1
        word = L[p:q].upper()
        p = q
        ent = None
        for e in table:
            nm = e[0]
            if all(nm[i] == " " or (i < len(word) and word[i] == nm[i]) for i in range(3)) and len(word) >= len(nm.strip()):
                ent = e
                break
        if ent is not None:
            _, typ, idx = ent
            while p < len(L) and L[p] == " ":
                p += 1
            if typ == 0:
                out.append((idx, "none"))
            elif p >= len(L) or L[p] == ";":
                if typ & 0x80:
                    out.append((idx, "none"))
            else:
                tok, p = param_at(p, typ, idx)
                if tok:
                    out.append(tok)
                    while p < len(L) and L[p] == " ":
                        p += 1
                    if p < len(L) and L[p] == "," and typ & 0x40:
                        tok2, p = param_at(p + 1, typ, idx)
                        if tok2:
                            out.append(tok2)
        if ent is not None and not (ent[1] & 0x40):
            while p < len(L) and L[p] not in ";,":      # ',' starts a new command here
                p += 1
        else:
            while p < len(L) and L[p] != ";":
                p += 1
        p += 1
    out.append(("END",))
    return out


def main():
    img = open(sys.argv[1], "rb").read()
    table, a = [], 0x59B1
    while all(0x20 <= c < 0x7F for c in img[a:a + 3]):
        table.append((img[a:a + 3].decode(), img[a + 3], img[a + 4]))
        a += 5
    names = [t[0].strip() for t in table]
    params = ["", "?", " 1", " 12", " 1900", " ON", " OFF", " VDC", " AUTO", " B", " 2.5E3", " -3", " .5",
              " ON,0", " ON,1.5", " 1,2", " ON,600"]
    lines = [n + p for n, p in itertools.product(names, params)]
    lines += ["fnc vdc", "FNC VDC;RNG 3", "OUT ON;TRG B", "XYZ", "XYZ;VDC", "CAL ON,0;CAL?", "TRG B,X"]
    bad = 0
    for l in lines:
        o, m = orig_tokens(img, l), mirror_tokens(table, l)
        if o != m:
            bad += 1
            if bad <= 25:
                print("DIFF %-16r orig=%s\n                      c  =%s" % (l, o, m))
    print("%d lines compared, %d differ" % (len(lines), bad))


if __name__ == "__main__":
    main()

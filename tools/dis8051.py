#!/usr/bin/env python3
"""8051 recursive-descent disassembler for the Philips PM2525 firmware.

Usage:
    python dis8051.py IMAGE.BIN [--sym symbols.txt] [--extra 0x1234,...] -o out.asm [--json out.json]

symbols.txt format (one per line, '#' comments):
    code  0x51FA  reset            [optional comment]
    xdata 0x00A2  timer_counter
    data  0x1D    ptr_hi
    bit   0x21    flag_x
    jtab  JMPADDR FIRST N STRIDE   # JMP @A+DPTR at JMPADDR -> N code entries at FIRST+i*STRIDE
    ccase 0x1234                   # (auto) Keil ?C?CCASE-style table after the LCALL
    dataregion 0x7000 0x7FFF       # force bytes as data
"""
import argparse
import json
import re
import sys
from collections import defaultdict

SFR = {
    0x80: "P0", 0x81: "SP", 0x82: "DPL", 0x83: "DPH", 0x87: "PCON", 0x88: "TCON",
    0x89: "TMOD", 0x8A: "TL0", 0x8B: "TL1", 0x8C: "TH0", 0x8D: "TH1", 0x90: "P1",
    0x98: "SCON", 0x99: "SBUF", 0xA0: "P2", 0xA8: "IE", 0xB0: "P3", 0xB8: "IP",
    0xD0: "PSW", 0xE0: "ACC", 0xF0: "B",
}
SFRBITS = {
    0x88: "IT0", 0x89: "IE0", 0x8A: "IT1", 0x8B: "IE1", 0x8C: "TR0", 0x8D: "TF0", 0x8E: "TR1", 0x8F: "TF1",
    0x98: "RI", 0x99: "TI", 0x9A: "RB8", 0x9B: "TB8", 0x9C: "REN", 0x9D: "SM2", 0x9E: "SM1", 0x9F: "SM0",
    0xA8: "EX0", 0xA9: "ET0", 0xAA: "EX1", 0xAB: "ET1", 0xAC: "ES", 0xAF: "EA",
    0xB0: "RXD", 0xB1: "TXD", 0xB2: "INT0", 0xB3: "INT1", 0xB4: "T0", 0xB5: "T1", 0xB6: "WR", 0xB7: "RD",
    0xB8: "PX0", 0xB9: "PT0", 0xBA: "PX1", 0xBB: "PT1", 0xBC: "PS",
    0xD0: "P", 0xD2: "OV", 0xD3: "RS0", 0xD4: "RS1", 0xD5: "F0", 0xD6: "AC", 0xD7: "CY",
}

# operand kinds: A,C,AB,DPTR,@DPTR,@A+DPTR,@A+PC,Rn,@Ri, dir, #imm, #imm16, bit, /bit, rel, addr11, addr16
def build_table():
    T = {}
    def d(op, mn, *ops):
        T[op] = (mn, ops)
    d(0x00, "NOP")
    for i in range(8):
        d(0x01 + i * 0x20, "AJMP", "addr11")
        d(0x11 + i * 0x20, "ACALL", "addr11")
    d(0x02, "LJMP", "addr16"); d(0x12, "LCALL", "addr16")
    d(0x03, "RR", "A"); d(0x13, "RRC", "A"); d(0x23, "RL", "A"); d(0x33, "RLC", "A")
    d(0x04, "INC", "A"); d(0x05, "INC", "dir"); d(0x14, "DEC", "A"); d(0x15, "DEC", "dir")
    for i in range(2):
        d(0x06 + i, "INC", "@R%d" % i); d(0x16 + i, "DEC", "@R%d" % i)
    for i in range(8):
        d(0x08 + i, "INC", "R%d" % i); d(0x18 + i, "DEC", "R%d" % i)
    d(0x10, "JBC", "bit", "rel"); d(0x20, "JB", "bit", "rel"); d(0x30, "JNB", "bit", "rel")
    d(0x40, "JC", "rel"); d(0x50, "JNC", "rel"); d(0x60, "JZ", "rel"); d(0x70, "JNZ", "rel")
    d(0x80, "SJMP", "rel")
    d(0x22, "RET"); d(0x32, "RETI")
    for base, mn in ((0x20, "ADD"), (0x30, "ADDC"), (0x40, "ORL"), (0x50, "ANL"), (0x60, "XRL"), (0x90, "SUBB")):
        d(base + 4, mn, "A", "#imm"); d(base + 5, mn, "A", "dir")
        d(base + 6, mn, "A", "@R0"); d(base + 7, mn, "A", "@R1")
        for i in range(8):
            d(base + 8 + i, mn, "A", "R%d" % i)
    for base, mn in ((0x40, "ORL"), (0x50, "ANL"), (0x60, "XRL")):
        d(base + 2, mn, "dir", "A"); d(base + 3, mn, "dir", "#imm")
    d(0x72, "ORL", "C", "bit"); d(0x82, "ANL", "C", "bit"); d(0xA0, "ORL", "C", "/bit"); d(0xB0, "ANL", "C", "/bit")
    d(0x73, "JMP", "@A+DPTR"); d(0x83, "MOVC", "A", "@A+PC"); d(0x93, "MOVC", "A", "@A+DPTR")
    d(0x74, "MOV", "A", "#imm"); d(0x75, "MOV", "dir", "#imm")
    d(0x76, "MOV", "@R0", "#imm"); d(0x77, "MOV", "@R1", "#imm")
    for i in range(8):
        d(0x78 + i, "MOV", "R%d" % i, "#imm")
        d(0x88 + i, "MOV", "dir", "R%d" % i)
        d(0xA8 + i, "MOV", "R%d" % i, "dir")
        d(0xB8 + i, "CJNE", "R%d" % i, "#imm", "rel")
        d(0xC8 + i, "XCH", "A", "R%d" % i)
        d(0xD8 + i, "DJNZ", "R%d" % i, "rel")
        d(0xE8 + i, "MOV", "A", "R%d" % i)
        d(0xF8 + i, "MOV", "R%d" % i, "A")
    d(0x84, "DIV", "AB"); d(0xA4, "MUL", "AB")
    d(0x85, "MOV", "dir2", "dir1")  # encoding: 85 src dst
    d(0x86, "MOV", "dir", "@R0"); d(0x87, "MOV", "dir", "@R1")
    d(0x90, "MOV", "DPTR", "#imm16"); d(0x92, "MOV", "bit", "C"); d(0xA2, "MOV", "C", "bit")
    d(0xA3, "INC", "DPTR")
    d(0xA5, "DB_A5")
    d(0xA6, "MOV", "@R0", "dir"); d(0xA7, "MOV", "@R1", "dir")
    d(0xB2, "CPL", "bit"); d(0xB3, "CPL", "C"); d(0xC2, "CLR", "bit"); d(0xC3, "CLR", "C")
    d(0xD2, "SETB", "bit"); d(0xD3, "SETB", "C")
    d(0xB4, "CJNE", "A", "#imm", "rel"); d(0xB5, "CJNE", "A", "dir", "rel")
    d(0xB6, "CJNE", "@R0", "#imm", "rel"); d(0xB7, "CJNE", "@R1", "#imm", "rel")
    d(0xC0, "PUSH", "dir"); d(0xD0, "POP", "dir")
    d(0xC4, "SWAP", "A"); d(0xC5, "XCH", "A", "dir"); d(0xC6, "XCH", "A", "@R0"); d(0xC7, "XCH", "A", "@R1")
    d(0xD4, "DA", "A"); d(0xD5, "DJNZ", "dir", "rel"); d(0xD6, "XCHD", "A", "@R0"); d(0xD7, "XCHD", "A", "@R1")
    d(0xE0, "MOVX", "A", "@DPTR"); d(0xE2, "MOVX", "A", "@R0"); d(0xE3, "MOVX", "A", "@R1")
    d(0xE4, "CLR", "A"); d(0xE5, "MOV", "A", "dir"); d(0xE6, "MOV", "A", "@R0"); d(0xE7, "MOV", "A", "@R1")
    d(0xF0, "MOVX", "@DPTR", "A"); d(0xF2, "MOVX", "@R0", "A"); d(0xF3, "MOVX", "@R1", "A")
    d(0xF4, "CPL", "A"); d(0xF5, "MOV", "dir", "A"); d(0xF6, "MOV", "@R0", "A"); d(0xF7, "MOV", "@R1", "A")
    assert len(T) == 256, len(T)
    return T

TABLE = build_table()
OPLEN = {"addr11": 1, "addr16": 2, "dir": 1, "dir1": 1, "dir2": 1, "#imm": 1, "#imm16": 2,
         "bit": 1, "/bit": 1, "rel": 1}


def oplen(op):
    mn, ops = TABLE[op]
    return 1 + sum(OPLEN.get(o, 0) for o in ops)


class Insn:
    __slots__ = ("addr", "op", "size", "mn", "args", "targets", "flow", "dir_refs", "bit_refs", "imm16")

    def __init__(self, img, a):
        self.addr = a
        self.op = op = img[a]
        mn, ops = TABLE[op]
        self.mn = mn
        self.size = oplen(op)
        self.args = []
        self.targets = []
        self.dir_refs = []
        self.bit_refs = []
        self.imm16 = None
        p = a + 1
        nxt = a + self.size
        raw = {}
        for o in ops:
            if o == "addr11":
                t = (nxt & 0xF800) | ((op >> 5) << 8) | img[p]; p += 1
                self.targets.append(t); self.args.append(("code", t))
            elif o == "addr16":
                t = (img[p] << 8) | img[p + 1]; p += 2
                self.targets.append(t); self.args.append(("code", t))
            elif o == "rel":
                r = img[p]; p += 1
                if r >= 0x80:
                    r -= 0x100
                t = (nxt + r) & 0xFFFF
                self.targets.append(t); self.args.append(("code", t))
            elif o in ("dir", "dir1", "dir2"):
                raw[o] = img[p]; p += 1
                self.args.append(("dir", None, o))
            elif o == "#imm":
                self.args.append(("imm", img[p])); p += 1
            elif o == "#imm16":
                v = (img[p] << 8) | img[p + 1]; p += 2
                self.imm16 = v
                self.args.append(("imm16", v))
            elif o in ("bit", "/bit"):
                self.args.append(("bit", img[p], o == "/bit")); self.bit_refs.append(img[p]); p += 1
            else:
                self.args.append(("reg", o))
        # resolve MOV dir,dir encoding (85 src dst)
        if op == 0x85:
            src, dst = img[a + 1], img[a + 2]
            self.args = [("dir", dst), ("dir", src)]
            self.dir_refs = [dst, src]
        else:
            fixed = []
            for x in self.args:
                if x[0] == "dir":
                    v = raw[x[2]]
                    fixed.append(("dir", v)); self.dir_refs.append(v)
                else:
                    fixed.append(x)
            self.args = fixed
        if mn in ("LJMP", "AJMP", "SJMP"):
            self.flow = "jump"
        elif mn in ("LCALL", "ACALL"):
            self.flow = "call"
        elif mn in ("RET", "RETI"):
            self.flow = "ret"
        elif mn == "JMP":
            self.flow = "ijump"
        elif self.targets:
            self.flow = "cond"
        elif mn == "DB_A5":
            self.flow = "bad"
        else:
            self.flow = "seq"


class Disasm:
    def __init__(self, img, syms):
        self.img = img
        self.size = len(img)
        self.syms = syms
        self.insns = {}          # addr -> Insn
        self.owner = {}          # byte addr -> insn addr
        self.labels = {}         # addr -> label name
        self.xrefs = defaultdict(set)
        self.call_targets = set()
        self.jtabs = {}          # addr -> list of targets (data bytes region)
        self.data_regions = []   # (start, end, kind, comment)
        self.problems = []
        self.ccase_helpers = set()  # function addrs that are Keil-like case helpers
        self.noreturn = set(syms.get("noreturn", []))

    def is_code(self, a):
        return a in self.owner

    def trace(self, entries):
        work = list(entries)
        while work:
            a = work.pop()
            while True:
                if a >= self.size or a < 0:
                    self.problems.append("flow out of image at %04X" % a)
                    break
                if a in self.insns:
                    break
                if a in self.owner:
                    self.problems.append("overlapping insn at %04X (inside %04X)" % (a, self.owner[a]))
                    break
                if any(s <= a <= e for s, e, *_ in self.data_regions):
                    self.problems.append("flow into data region at %04X" % a)
                    break
                ins = Insn(self.img, a)
                if a + ins.size > self.size:
                    break
                if ins.flow == "bad":
                    self.problems.append("invalid opcode A5 at %04X" % a)
                    break
                self.insns[a] = ins
                for k in range(ins.size):
                    self.owner[a + k] = a
                for t in ins.targets:
                    self.xrefs[t].add(a)
                    if ins.flow == "call":
                        self.call_targets.add(t)
                    work.append(t)
                if ins.flow in ("jump", "ret", "ijump"):
                    if ins.flow == "ijump":
                        self.handle_ijump(ins, work)
                    break
                if ins.flow == "call":
                    t = ins.targets[0]
                    if t in self.ccase_helpers:
                        nxt = self.handle_case_table(a + ins.size, t, work)
                        if nxt is None:
                            break
                        a = nxt
                        continue
                    if t in self.noreturn:
                        break
                a += ins.size

    # --- JMP @A+DPTR handling -------------------------------------------------
    def handle_ijump(self, ins, work):
        a = ins.addr
        if a in self.syms["jtab_at"]:
            base, n, stride = self.syms["jtab_at"][a]
            self.add_jtab(base, n, stride, work, src=a)
            return
        base = None
        for back in range(3, 24):
            b = a - back
            if b in self.insns and self.insns[b].op == 0x90:
                base = self.insns[b].imm16
                break
        if base is None:
            self.problems.append("unresolved JMP @A+DPTR at %04X" % a)
            return
        n = 0
        if self.img[base] == 0x02:
            while base + 3 * n < self.size and self.img[base + 3 * n] == 0x02 and n < 64:
                n += 1
            self.add_jtab(base, n, 3, work, src=a)
        elif (self.img[base] & 0x1F) == 0x01:
            while base + 2 * n < self.size and (self.img[base + 2 * n] & 0x1F) == 0x01 and n < 128:
                n += 1
            self.add_jtab(base, n, 2, work, src=a)
        else:
            self.problems.append("JMP @A+DPTR at %04X with DPTR=%04X: unknown table" % (a, base))

    def add_jtab(self, base, n, stride, work, src=None):
        if base in self.jtabs:
            return
        for i in range(n):
            e = base + stride * i
            work.append(e)
            self.xrefs[e].add(src if src is not None else base)
        self.jtabs[base] = (stride, n, src)

    def handle_case_table(self, a, helper, work):
        kind = self.syms["ccase"].get(helper, "ccase")
        # Keil ?C?CCASE: entries (addr16, byte) terminated by addr16 0x0000, then default addr16
        # Keil ?C?ICASE: entries (addr16, word16) ... 0x0000, default addr16
        # Keil ?C?LCASE: entries (addr16, dword) ... 0x0000, default
        vsize = {"ccase": 1, "icase": 2, "lcase": 4}[kind]
        p = a
        entries = []
        while p + 2 <= self.size:
            t = (self.img[p] << 8) | self.img[p + 1]
            if t == 0:
                p += 2
                break
            v = int.from_bytes(self.img[p + 2:p + 2 + vsize], "big")
            entries.append((t, v))
            p += 2 + vsize
            if len(entries) > 256:
                self.problems.append("case table at %04X too long" % a)
                return None
        default = p
        self.data_regions.append((a, p - 1, "case", entries))
        for t, v in entries:
            self.xrefs[t].add(a)
            work.append(t)
        return default

    # --- naming -----------------------------------------------------------------
    def name_code(self, a):
        if a in self.syms["code"]:
            return self.syms["code"][a][0]
        if a in self.labels:
            return self.labels[a]
        if a in self.call_targets:
            return "sub_%04X" % a
        return "L_%04X" % a

    def fmt_dir(self, v):
        if v in self.syms["data"]:
            return self.syms["data"][v][0]
        if v >= 0x80:
            return SFR.get(v, "SFR_%02X" % v)
        if v < 0x08:
            return "AR%d" % v if False else "0%02Xh" % v
        return "0%02Xh" % v if v >= 0x10 else "%02Xh" % v

    def fmt_bit(self, b):
        if b in self.syms["bit"]:
            return self.syms["bit"][b][0]
        if b >= 0x80:
            if b in SFRBITS:
                return SFRBITS[b]
            byte = b & 0xF8
            return "%s.%d" % (SFR.get(byte, "SFR_%02X" % byte), b & 7)
        return "%02Xh.%d" % (0x20 + (b >> 3), b & 7)

    def fmt_insn(self, ins):
        parts = []
        for x in ins.args:
            k = x[0]
            if k == "code":
                parts.append(self.name_code(x[1]))
            elif k == "dir":
                parts.append(self.fmt_dir(x[1]))
            elif k == "imm":
                parts.append("#0%02Xh" % x[1])
            elif k == "imm16":
                v = x[1]
                if v in self.syms["xdata"]:
                    parts.append("#" + self.syms["xdata"][v][0])
                elif v in self.syms["code"] and (v in self.insns or v in self.syms["code"]):
                    parts.append("#" + self.syms["code"][v][0])
                else:
                    parts.append("#0%04Xh" % v)
            elif k == "bit":
                parts.append(("/" if x[2] else "") + self.fmt_bit(x[1]))
            elif k == "reg":
                parts.append(x[1])
        return "%-6s %s" % (ins.mn, ", ".join(parts))

    # --- listing -----------------------------------------------------------------
    def functions(self):
        """Approximate function bodies: each call target + vectors; body = reachable
        via non-call flow until another function entry."""
        entries = sorted(set(self.call_targets) | set(self.syms["entries"]))
        res = {}
        for e in entries:
            if e not in self.insns:
                continue
            seen = set()
            st = [e]
            while st:
                a = st.pop()
                if a in seen or a not in self.insns:
                    continue
                if a != e and a in entries and a in self.call_targets:
                    continue
                seen.add(a)
                ins = self.insns[a]
                if ins.flow in ("seq", "cond", "call"):
                    st.append(a + ins.size)
                if ins.flow in ("jump", "cond"):
                    st.extend(ins.targets)
                if ins.addr in self.syms["jtab_at"] or ins.flow == "ijump":
                    for base, (kind, n, src) in self.jtabs.items():
                        if src == a:
                            st.extend(base + kind * i for i in range(n))
            res[e] = sorted(seen)
        return res

    def listing(self, out):
        img = self.img
        a = 0
        ccase_regions = {s: (e, ents) for s, e, k, ents in self.data_regions if k == "case"}
        forced = [(s, e) for s, e, k, _ in self.data_regions if k == "forced"]
        w = out.write
        w("; PM2525 firmware disassembly (generated by dis8051.py)\n")
        w("; %d instructions, %d code bytes of %d\n\n" % (len(self.insns), len(self.owner), self.size))
        while a < self.size:
            if a in self.insns:
                ins = self.insns[a]
                is_entry = a in self.call_targets or a in self.syms["entries"] or a in self.syms["code"]
                if is_entry:
                    w("\n;" + "-" * 70 + "\n")
                    c = self.syms["code"].get(a, (None, ""))[1]
                    if c:
                        w("; %s\n" % c)
                    xr = sorted(self.xrefs.get(a, ()))
                    if xr:
                        w("; xrefs: %s\n" % " ".join("%04X" % x for x in xr[:16]) + (" ..." if len(xr) > 16 else "") + "\n")
                if is_entry or a in self.xrefs or a in self.labels:
                    w("%s:\n" % self.name_code(a))
                hx = " ".join("%02X" % b for b in img[a:a + ins.size])
                cm = self.syms["comment"].get(a, "")
                extra = ""
                if ins.op == 0x90 and ins.imm16 is not None:
                    v = ins.imm16
                    if v >= 0x0100 and v < self.size and v not in self.syms["xdata"]:
                        s = self.peek_string(v)
                        if s:
                            extra = '"%s"' % s
                w("  %04X  %-9s  %-40s%s\n" % (a, hx, self.fmt_insn(ins),
                                                ("; " + "  ".join(x for x in (cm, extra) if x)) if (cm or extra) else ""))
                a += ins.size
                continue
            # data
            if a in ccase_regions:
                e, ents = ccase_regions[a]
                w("  ; case table\n")
                p = a
                while p <= e:
                    pass_ = 0
                    t = (img[p] << 8) | img[p + 1]
                    if t == 0:
                        w("  %04X  %02X %02X      DW 0          ; end, default follows\n" % (p, img[p], img[p + 1]))
                        p += 2
                        continue
                    vs = e - p + 1
                    # each entry 2+vsize; infer vsize from entries count
                    break
                # fall back: print entries list
                vsize = 1
                if ents:
                    vsize = ((e - a + 1) - 2) // len(ents) - 2
                p = a
                for t, v in ents:
                    w("  %04X  %-9s  DW %-12s, %s   ; case 0x%X -> %s\n" % (
                        p, " ".join("%02X" % b for b in img[p:p + 2 + vsize]), self.name_code(t),
                        "0x%X" % v, v, self.name_code(t)))
                    p += 2 + vsize
                w("  %04X  %02X %02X      DW 0             ; end, default follows\n" % (p, img[p], img[p + 1]))
                a = e + 1
                continue
            # run of non-code bytes
            s = a
            while a < self.size and a not in self.insns and a not in ccase_regions:
                a += 1
            self.dump_data(out, s, a)
        return out

    def peek_string(self, a, minlen=3):
        s = []
        while a < self.size and 0x20 <= self.img[a] < 0x7F and len(s) < 40:
            s.append(chr(self.img[a])); a += 1
        if len(s) >= minlen:
            return "".join(s).replace('"', "'")
        return None

    def dump_data(self, out, s, e):
        img = self.img
        if all(b == 0xFF for b in img[s:e]):
            out.write("  %04X  ; %d bytes 0xFF (unused)\n" % (s, e - s))
            return
        lab = self.syms["code"].get(s) or ((self.syms["xdata"].get(s),) if False else None)
        out.write("\n; ---- data %04X-%04X (%d bytes) ----\n" % (s, e - 1, e - s))
        if s in self.syms["code"]:
            out.write("%s:\n" % self.syms["code"][s][0])
        p = s
        while p < e:
            if p in self.syms["code"] and p != s:
                out.write("%s:\n" % self.syms["code"][p][0])
            n = min(16, e - p)
            # stop line at next label
            for q in range(p + 1, p + n):
                if q in self.syms["code"] or q in self.xrefs:
                    n = q - p
                    break
            chunk = img[p:p + n]
            asc = "".join(chr(b) if 0x20 <= b < 0x7F else "." for b in chunk)
            out.write("  %04X  DB %-48s ; %s\n" % (p, ",".join("%02X" % b for b in chunk), asc))
            p += n


def load_syms(path):
    syms = {"code": {}, "xdata": {}, "data": {}, "bit": {}, "entries": [], "jtab_at": {},
            "ccase": {}, "dataregion": [], "comment": {}, "noreturn": []}
    if not path:
        return syms
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        cm = ""
        if "#" in line:
            line, cm = line.split("#", 1)
            cm = cm.strip()
        f = line.split()
        k = f[0]
        if k in ("code", "xdata", "data", "bit"):
            syms[k][int(f[1], 16)] = (f[2], cm)
            if k == "code" and len(f) > 3 and f[3] == "entry":
                syms["entries"].append(int(f[1], 16))
        elif k == "entry":
            syms["entries"].append(int(f[1], 16))
        elif k == "noreturn":
            syms["noreturn"].append(int(f[1], 16))
        elif k == "jtab":
            # jtab JMPADDR FIRST_ENTRY N STRIDE
            syms["jtab_at"][int(f[1], 16)] = (int(f[2], 16), int(f[3]), int(f[4]))
        elif k in ("ccase", "icase", "lcase"):
            syms["ccase"][int(f[1], 16)] = k
        elif k == "dataregion":
            syms["dataregion"].append((int(f[1], 16), int(f[2], 16)))
        elif k == "comment":
            syms["comment"][int(f[1], 16)] = cm or " ".join(f[2:])
    return syms


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("--sym")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("--json")
    ap.add_argument("--extra", default="")
    args = ap.parse_args()
    img = open(args.image, "rb").read()
    syms = load_syms(args.sym)
    D = Disasm(img, syms)
    D.ccase_helpers = set(syms["ccase"].keys())
    for s, e in syms["dataregion"]:
        D.data_regions.append((s, e, "forced", None))
    entries = [0x0000, 0x0003, 0x000B, 0x0013, 0x001B, 0x0023]
    entries = [e for e in entries if img[e] != 0xFF]
    entries += syms["entries"]
    entries += [int(x, 16) for x in args.extra.split(",") if x]
    D.syms["entries"] = sorted(set(entries))
    D.trace(entries)
    with open(args.out, "w", encoding="utf-8") as f:
        D.listing(f)
    funcs = D.functions()
    if args.json:
        js = {
            "code_bytes": len(D.owner),
            "insns": len(D.insns),
            "functions": {"%04X" % k: {"name": D.name_code(k), "n_insns": len(v),
                                       "callers": sorted("%04X" % x for x in D.xrefs.get(k, ()))}
                          for k, v in funcs.items()},
            "jtabs": {"%04X" % k: v for k, v in D.jtabs.items()},
            "problems": D.problems,
        }
        json.dump(js, open(args.json, "w"), indent=1)
    print("insns=%d code_bytes=%d/%d funcs=%d jtabs=%d problems=%d" % (
        len(D.insns), len(D.owner), len(img), len(funcs), len(D.jtabs), len(D.problems)))
    for p in D.problems[:40]:
        print("  ", p)


if __name__ == "__main__":
    main()

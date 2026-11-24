#!/usr/bin/env python3
"""Size optimizer: build fw/ with short jumps and calls wherever they reach.

Usage: python tools/shrink_fw.py [--asm fw/pm2525.asm] [--out fw/out]

The source keeps the long forms. This tool writes a copy (fw/out_shrink/src/pm2525.asm) in which
    LJMP  -> SJMP  (target within -128..+127) or AJMP (same 2 KB page)
    LCALL -> ACALL (same 2 KB page)
and builds it into --out. All four take 2 machine cycles, exactly like the long forms, so timing
is unchanged; each conversion saves one byte. Because shrinking moves code (and page boundaries),
it iterates: pick short forms from the current layout, relink, put back to long form anything
that no longer reaches, until stable.

Never touched:
  - jump-table entries (JMP @A+DPTR tables index 3-byte LJMPs),
  - code between a label and a `label+k` / `label-k` reference (table bases computed from it),
  - code around the two MOVC A,@A+PC tables (the table offset counts the bytes in between),
  - lines marked `; keep` (use this for anything whose size must not change).
"""
import argparse
import glob
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))

CAND = re.compile(r"^(\s+)(ljmp|lcall|sjmp|ajmp|acall)(\s+)([A-Za-z_]\w*)(\s*(;.*)?)$")


def protected_original_addresses(src_lines):
    """original addresses (from the '; XXXX' comments) whose instructions must keep their size"""
    import dis8051 as D8
    from fwpaths import original_image
    img = open(original_image(), "rb").read()
    syms = D8.load_syms(os.path.join(ROOT, "tools", "s25.sym"))
    D = D8.Disasm(img, syms)
    D.ccase_helpers = set(syms["ccase"].keys())
    ent = [e for e in (0x0000, 0x0003, 0x000B, 0x0013, 0x001B, 0x0023) if img[e] != 0xFF] + syms["entries"]
    D.syms["entries"] = sorted(set(ent))
    D.trace(ent)
    prot = set()
    for base, (kind, n, src) in D.jtabs.items():           # jump-table entries
        for i in range(n):
            prot.update(range(base + kind * i, base + kind * i + kind))
    for ins in D.insns.values():                          # MOVC A,@A+PC: +-24 bytes around
        if ins.op == 0x83:
            prot.update(range(ins.addr - 24, ins.addr + 24))
    # label+k / label-k references in the source: protect the span between label and target and
    # 48 bytes beyond (the table that the base is computed for)
    lab_addr = {}
    for i, l in enumerate(src_lines):
        m = re.match(r"^(\w+)::?", l)
        if m:
            for j in range(i + 1, min(i + 6, len(src_lines))):
                g = re.search(r";\s*([0-9A-F]{4})\b", src_lines[j])
                if g and not src_lines[j].lstrip().startswith(";"):
                    lab_addr[m.group(1)] = int(g.group(1), 16)
                    break
    for l in src_lines:
        for m in re.finditer(r"#?\b([A-Za-z_]\w*)\s*([+-])\s*(\d+)\b", l.split(";")[0]):
            if m.group(1) in lab_addr:
                a = lab_addr[m.group(1)]
                t = a + int(m.group(3)) * (1 if m.group(2) == "+" else -1)
                prot.update(range(min(a, t) - 8, max(a, t) + 48))
    return prot


def page_ok(pc, t):
    """AJMP/ACALL at pc reaches t. The CPU uses the page of pc+2; sdld checks against the page of the
    instruction itself. Require both (an instruction straddling a page boundary stays long)."""
    return (t >> 11) == ((pc + 2) >> 11) == (pc >> 11)


def build(src, out, ref=""):
    r = subprocess.run([sys.executable, "-I", os.path.join(ROOT, "tools", "build_fw.py"), "--asm", src,
                        "--out", out] + (["--ref", ref] if ref is not None else []), capture_output=True, text=True)
    return r.returncode, (r.stdout + r.stderr)


def layout(out, name):
    """source line number -> address, label -> address, from the relocated listing (.rst)"""
    addr_of_line, labels = {}, {}
    for l in open(os.path.join(out, name + ".rst"), encoding="latin1"):
        m = re.match(r"^\s+([0-9A-F]{6,8})\s(?:[0-9A-F]{2}\s)*\s*(?:\[\s*\d+\])?\s*(\d+)\s(.*)$", l)
        if not m:
            continue
        a, ln, text = int(m.group(1), 16), int(m.group(2)), m.group(3)
        addr_of_line.setdefault(ln, a)
        g = re.match(r"^(\w+)::?", text)
        if g:
            labels[g.group(1)] = a
    return addr_of_line, labels


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--asm", default=os.path.join(ROOT, "fw", "pm2525.asm"))
    ap.add_argument("--out", default=os.path.join(ROOT, "fw", "out"))
    ap.add_argument("--max-iter", type=int, default=25)
    ap.add_argument("--ref", default=None, help="image to compare the result with (passed to build_fw)")
    a = ap.parse_args()
    src_dir = os.path.dirname(os.path.abspath(a.asm))
    work = os.path.join(ROOT, "fw", "out_shrink")
    wsrc = os.path.join(work, "src")
    if os.path.isdir(wsrc):
        shutil.rmtree(wsrc)
    os.makedirs(wsrc)
    for f in glob.glob(os.path.join(src_dir, "*.asm")):
        if os.path.abspath(f) != os.path.abspath(a.asm):
            shutil.copy(f, wsrc)
    if os.path.isdir(os.path.join(src_dir, "c")):
        shutil.copytree(os.path.join(src_dir, "c"), os.path.join(wsrc, "c"))
    lines = open(a.asm, encoding="utf-8").read().split("\n")
    prot = protected_original_addresses(lines)
    name = os.path.splitext(os.path.basename(a.asm))[0]
    target_asm = os.path.join(wsrc, os.path.basename(a.asm))

    cands = {}                      # line index -> (indent, kind 'jmp'/'call', sep, target, rest)
    skipped = 0
    for i, l in enumerate(lines):
        m = CAND.match(l)
        if not m or m.group(2) not in ("ljmp", "lcall"):     # existing short forms stay as they are
            continue
        g = re.search(r";\s*([0-9A-F]{4})\b", l)
        if (g and int(g.group(1), 16) in prot) or "; keep" in l:
            skipped += 1
            continue
        kind = "call" if m.group(2) in ("lcall", "acall") else "jmp"
        cands[i] = (m.group(1), kind, m.group(3), m.group(4), m.group(5) or "")
    form = {i: ("lcall" if c[1] == "call" else "ljmp") for i, c in cands.items()}
    banned = set()
    tmp_out = os.path.join(work, "out")

    def write():
        L = list(lines)
        for i, (ind, kind, sep, tgt, rest) in cands.items():
            L[i] = "%s%s%s%s%s" % (ind, form[i], sep, tgt, rest)
        open(target_asm, "w", encoding="utf-8", newline="\n").write("\n".join(L))

    write()
    rc, msg = build(target_asm, tmp_out)
    if rc:
        sys.exit("baseline build failed:\n" + msg)
    for it in range(a.max_iter):
        addr, labels = layout(tmp_out, name)
        changed = 0
        for i, (ind, kind, sep, tgt, rest) in cands.items():
            ln = i + 1
            if ln not in addr or tgt not in labels:
                continue
            pc, t = addr[ln], labels[tgt]
            cur = form[i]
            size = 3 if cur in ("ljmp", "lcall") else 2
            nxt_short = pc + 2                      # next instruction if this one is 2 bytes
            want = cur
            if kind == "jmp":
                if (i, "sjmp") not in banned and -128 <= t - nxt_short <= 127:
                    want = "sjmp"
                elif (i, "ajmp") not in banned and page_ok(pc, t):
                    want = "ajmp"
                else:
                    want = "ljmp"
            else:
                want = "acall" if (i, "acall") not in banned and page_ok(pc, t) else "lcall"
            # a short form that the current layout proves invalid is banned for good (no oscillation)
            if cur in ("sjmp", "ajmp", "acall"):
                ok = (cur == "sjmp" and -128 <= t - (pc + 2) <= 127) or \
                     (cur in ("ajmp", "acall") and page_ok(pc, t))
                if not ok:
                    banned.add((i, cur))
                    want = "lcall" if kind == "call" else "ljmp"
            if want != cur:
                form[i] = want
                changed += 1
        write()
        rc, msg = build(target_asm, tmp_out)
        if rc and "2K Page relocation error" in msg and "ASxxxx-Error" not in msg:
            rc = 0      # some AJMP/ACALL crossed a page after the move: the next pass bans them
        if rc:
            # assembler range errors: ban the short form on the reported lines and retry
            bad = [int(x) for x in re.findall(r"(?m)^\?ASxxxx-Error-<[ar]>.*?line (\d+)", msg)]
            if not bad:
                sys.exit("build failed:\n" + msg)
            for ln in bad:
                i = ln - 1
                if i in form:
                    banned.add((i, form[i]))
                    form[i] = "lcall" if cands[i][1] == "call" else "ljmp"
            write()
            continue
        short = sum(1 for f in form.values() if f in ("sjmp", "ajmp", "acall"))
        print("pass %d: %d changed, %d short forms" % (it + 1, changed, short), flush=True)
        if not changed and "2K Page relocation error" not in msg:
            break
    # final verification of every short form against the final layout
    addr, labels = layout(tmp_out, name)
    for i, f in form.items():
        if f in ("sjmp", "ajmp", "acall"):
            pc, t = addr[i + 1], labels[cands[i][3]]
            ok = (f == "sjmp" and -128 <= t - (pc + 2) <= 127) or (f != "sjmp" and page_ok(pc, t))
            if not ok:
                sys.exit("internal error: %s at line %d does not reach" % (f, i + 1))
    rc, msg = build(target_asm, a.out, a.ref)
    print(msg.strip())
    counts = {k: sum(1 for f in form.values() if f == k) for k in ("sjmp", "ajmp", "acall")}
    print("shrink: %d candidates (%d protected): %d sjmp, %d ajmp, %d acall = %d bytes saved" % (
        len(cands), skipped, counts["sjmp"], counts["ajmp"], counts["acall"], sum(counts.values())))
    sys.exit(rc)


if __name__ == "__main__":
    main()

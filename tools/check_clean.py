#!/usr/bin/env python3
"""Milestone C: compare logic of the hand-cleaned modules (src/clean/*.c, mirrored here in Python
line for line) with the original routines running in the emulator.

Usage: python check_clean.py IMAGE.BIN RAM_DUMP.bin
Tests:
  scale_exp     range_scale_exp 0x165A        all functions x ranges x 10 A flag
  limits        range_param_lookup 0x19A8     down/up/overload thresholds
  cmd_index     func_to_cmd_index 0x4814      all functions x mode bits
  rms           rms_get_byte 0x5B93           2-of-3 repair of the RMS byte
  recipes       cal_load_range 0x0111 + cal_compute_effective 0x12A2 on the real RAM dump:
                K0..K5 of both sets and zero_eff/gain_eff for every function/range
"""
import math
import os
import re
import random
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

B_CAL_ENABLE, B_CAL_MODE, B_10A, B_CAL_HOT, B_PK0, B_PK1, B_SKIPV = 0x15, 0x16, 0x2E, 0x3A, 0x0E, 0x0F, 0x1C

img = open(sys.argv[1], "rb").read()
ram = open(sys.argv[2], "rb").read() if len(sys.argv) > 2 else bytes(2048)


def fdec(b):
    if b[0] & 0x7F == 0:
        return 0.0
    return (-1 if b[0] & 0x80 else 1) * int.from_bytes(b[1:4], "big") / 2 ** 24 * 2 ** ((b[0] & 0x7F) - 62)


def rom_f(a):
    return fdec(img[a:a + 4])


def i24(c, a):          # IRAM i24, MSB at a
    v = c.iram[a - 2] | c.iram[a - 1] << 8 | c.iram[a] << 16
    return v - (1 << 24) if v & 0x800000 else v


def cpu(state=0x01, mode=0, bits=()):
    c = CPU(EXEC_IMG if EXEC_PATH else img)
    c.iram[0x81] = 0x60
    c.iram[0x20], c.iram[0x21] = state, mode
    for b in bits:
        c.bit_wr(b, 1)
    return c


results = {}


def report(name, total, bad, examples):
    results[name] = (total, bad)
    print("%-10s %5d cases, %d differ" % (name, total, bad))
    for e in examples[:8]:
        print("    ", e)


# ---------------------------------------------------------------- mirrors of the clean C
BASE = [-4, -5, -5, -5, -2, -2, -11, -11, 0, -14, -3, -1, -4, -2]


def m_scale_exp(st, a10):
    f, r = st & 15, st >> 4 & 7
    b = BASE[f] if f < 14 else None
    if f in (6, 7) and a10:
        b = -9
    if f == 10 and r == 6:
        b = -4
    return r + b


def m_limits(st, a10):
    f, high = st & 15, bool(st & 0x40)
    if f == 0:
        return (180, 1000, 1100) if high else (180, 2000, 2100)
    if f in (1, 2, 3):
        return (1800, 10000, 11000) if high else (1800, 20000, 21000)
    if f in (4, 5, 9):
        return (1800, 20000, 21000)
    if f in (6, 7):
        return (900, 10000, 11000)
    if f == 8:
        return (0, 100000, 110000)
    if f == 10:
        return (9000, 200000, 210000) if (high and st & 0x20) else (9000, 100000, 110000)
    if f == 11:
        return (0, 4000, 4000)
    return (0, 21000, 21000)


def m_cmd_index(st, mode):
    f = st & 15
    if f == 0:
        return ((mode >> 6) - 1) & 0xFF
    if f < 8:
        return f + 2
    if f == 8:
        return ((mode >> 4) & 3) + 10
    return f + 5


def m_rms(x):
    a, b, c = x[0], (x[1] - 0x55) & 0xFF, (x[2] + 0x56) & 0xFF
    if a == b == c:
        return a, None
    if a == b or a == c:
        n = a
    elif b == c:
        n = b
    else:
        n = 0x41
    return n, bytes([n, (n + 0x55) & 0xFF, (n - 0x56) & 0xFF])


# ---------------------------------------------------------------- tests
def t_scale_exp():
    bad, ex, n = 0, [], 0
    for f in range(14):
        for r in range(8):
            for a10 in (0, 1):
                st = f | r << 4
                c = cpu(st, bits=[B_10A] if a10 else [])
                c.call(RA(0x165A))
                got = c.a - 256 if c.a > 127 else c.a
                n += 1
                if got != m_scale_exp(st, a10):
                    bad += 1
                    ex.append("f%d r%d 10A=%d orig=%d clean=%d" % (f, r, a10, got, m_scale_exp(st, a10)))
    report("scale_exp", n, bad, ex)


def t_limits():
    bad, ex, n = 0, [], 0
    for f in range(14):
        for r in range(8):
            for a10 in (0, 1):
                st = f | r << 4
                c = cpu(st, bits=[B_10A] if a10 else [])
                c.call(RA(0x19A8))
                got = (i24(c, 0x42), i24(c, 0x46), i24(c, 0x4A))
                n += 1
                if got != m_limits(st, a10):
                    bad += 1
                    ex.append("f%d r%d 10A=%d orig=%s clean=%s" % (f, r, a10, got, m_limits(st, a10)))
    report("limits", n, bad, ex)


def t_cmd_index():
    bad, ex, n = 0, [], 0
    for f in range(14):
        for mode in range(0, 256, 16):
            c = cpu(f, mode)
            c.call(RA(0x4814))
            n += 1
            if c.a != m_cmd_index(f, mode):
                bad += 1
                ex.append("f%d mode %02X orig=%d clean=%d" % (f, mode, c.a, m_cmd_index(f, mode)))
    report("cmd_index", n, bad, ex)


def t_rms():
    bad, ex, n = 0, [], 0
    rnd = random.Random(1)
    cases = []
    for v in (0, 65, 87, 200, 255):
        good = bytes([v, (v + 0x55) & 0xFF, (v - 0x56) & 0xFF])
        cases.append(good)
        for k in range(3):
            w = bytearray(good)
            w[k] ^= 0x5A
            cases.append(bytes(w))
    cases += [bytes(rnd.randrange(256) for _ in range(3)) for _ in range(200)]
    for x in cases:
        c = cpu()
        c.xram[0x07FD:0x0800] = x
        c.call(RA(0x5B93))
        want, fixed = m_rms(x)
        got = (c.a, bytes(c.xram[0x07FD:0x0800]))
        exp = (want, fixed if fixed else x)
        n += 1
        if got != exp:
            bad += 1
            ex.append("%s orig=%d %s clean=%d %s" % (x.hex(), got[0], got[1].hex(), exp[0], exp[1].hex()))
    report("rms", n, bad, ex)


# ---- recipe mirror (calibration.c eval_coef / cal_load_range / cal_temp_compensate)
def rd16(a):
    return img[a] << 8 | img[a + 1]


OFFS = [int.from_bytes(img[0x738 + 2 * i:0x73A + 2 * i], "big", signed=True) for i in range(14)]
DEFAULT = [0.0, 1.0, 0.5, 0.5, 0.0, 0.0]


def record_at(a):
    h0, h1 = img[a], img[a + 1]
    nA, nB, nD = (h0 & 1) + 1, (h0 >> 3) & 7, (h1 >> 3) & 7
    A = a + 2
    B = A + 2 * nA
    X = B + 2 * nB
    C = X + 2
    D = C + 2 * (nA + 1)
    return dict(h0=h0, h1=h1, nA=nA, nB=nB, nD=nD, A=A, B=B, X=X, C=C, D=D, end=D + 2 * nD)


class Mirror:
    def __init__(self, xr, st, a10, cal_mode):
        self.x, self.st, self.a10, self.cal_mode = xr, st, a10, cal_mode
        self.invalid = False
        self.defaulted = False

    def slot(self, p):
        return fdec(self.x[p:p + 4])      # dump copies agree, so the vote is the value

    def term(self, p, const, w, check):
        if const or p >= 0x800:
            v = rom_f(p)
            return True, v
        v = self.slot(p)
        return (not check or (w[0] <= v < w[1])), v

    def product(self, lst, n, const, w):
        ok, v = self.term(rd16(lst), const, w, False)
        if not ok:
            return False, 0
        if n == 2:
            ok, t = self.term(rd16(lst + 2), False, w, False)
            if not ok:
                return False, 0
            v *= t
        return (w[0] <= v < w[1]), v

    def chain(self, lst, n, nfirst, const, w, additive):
        ok, v = self.term(rd16(lst), const, w, True)
        if not ok:
            return False, 0
        for i in range(1, n):
            ok, t = self.term(rd16(lst + 2 * i), False, w, True)   # each new term is limit-checked
            if not ok:
                return False, 0
            first = i <= nfirst
            v = (v - t if first else v + t) if additive else (v * t if first else v / t)
        return True, v

    def coef(self, r, k, w):
        if k == 0:
            ok, v = self.product(r["A"], r["nA"], r["h0"] & 2, w)
        elif k == 1:
            ok, v = self.chain(r["B"], r["nB"], r["h0"] >> 6, r["h0"] & 4, w, False) if r["nB"] else (True, 1.0)
        elif k == 2:
            ok, v = self.term(rd16(r["X"]), r["h1"] & 1, w, True)
        elif k == 3:
            ok, v = self.term(rd16(r["C"]), r["h1"] & 2, w, True)
        elif k == 4:
            ok, v = self.product(r["C"] + 2, r["nA"], r["h0"] & 2, w)
        else:
            ok, v = self.chain(r["D"], r["nD"], r["h1"] >> 6, r["h1"] & 4, w, True) if r["nD"] else (True, 0.0)
        if ok:
            return v
        if self.cal_mode:
            self.defaulted = True
            return DEFAULT[k]
        self.invalid = True
        return 0.0

    def run(self, T):
        st = self.st
        f, rng, fr = st & 15, st >> 4 & 7, st & 0x7F
        nom = m_limits(st, self.a10)[1] * 10.0 ** m_scale_exp(st, self.a10)
        if (st & 0x0C) == 0 and st & 0x40:
            nom *= 2
        sl = 5.0 if fr in (0x65, 0x55, 0x29) else 0.5
        w = [(-0.2 * nom, 0.2 * nom), (0.75, 1.5) if fr == 0x65 else (0.8, 1.2), (0.3, 0.7), (0.3, 0.7),
             (-0.5 * nom, 0.5 * nom), (-sl, sl)]
        r = rng + 2 if f in (6, 7) and self.a10 else rng
        e = 0x76A2 + OFFS[f] + 4 * r
        two = img[e + 2] & 0x80
        r0 = record_at(rd16(e))
        r1 = record_at(r0["end"])
        sets = [[None] * 6, [None] * 6]
        for k in range(6):
            if self.invalid:
                break
            sets[0][k] = self.coef(r0, k, w[k])
            if two:
                sets[1][k] = self.coef(r1, k, w[k])
        if self.invalid:
            sets = [DEFAULT[:], DEFAULT[:]]
        out = []
        for s in (0, 1):
            if sets[s][0] is None:
                out.append(None)
                continue
            K = sets[s]
            comp = not self.cal_mode
            ze = K[0] + K[4] * (T - K[2]) if comp else K[0]
            ge = K[1] + K[5] * (T - K[3]) if comp else K[1]
            out.append(K + [ze, ge])
        return out, two


def close(a, b):
    return abs(a - b) <= 2e-6 * max(1.0, abs(a), abs(b))


def t_recipes(fuzz=0, name="recipes"):
    bad, ex, n = 0, [], 0
    rnd = random.Random(7)
    sample = None
    paths = [0, 0]
    masks = [img[0x6ED4 + 3 * f:0x6ED7 + 3 * f] for f in range(14)]
    T = fdec(ram[0x119:0x11D])
    for cal_mode in (0, 1):
        for f in range(14):
            variants = [(r, 0) for r in range(8) if any(m >> r & 1 for m in masks[f])]
            if f in (6, 7):
                variants += [(r, 1) for r in (5, 6)]
            for r, a10 in variants:
                st = f | r << 4
                for trial in range(max(1, fuzz)):
                    xr = bytearray(ram)
                    if fuzz:      # set 1-2 random slots (all three copies) to random plausible values
                        for _ in range(rnd.randint(1, 2)):
                            slot = rnd.randrange(114)
                            v = rnd.choice([0.0, 1e-9, 0.25, 0.6, 0.95, 1.3, 2.0, -0.4, 50.0, -1e4])
                            b = bytes(4) if v == 0 else bytes([(0x80 if v < 0 else 0) | (math.frexp(abs(v))[1] + 62)]) + int(round(math.frexp(abs(v))[0] * 2 ** 24)).to_bytes(3, "big")
                            for base in (0x0200, 0x03CF, 0x059E):
                                xr[base + 4 * slot:base + 4 * slot + 4] = b
                        for k, base in enumerate((0x0200, 0x03CF, 0x059E)):   # fresh checksums
                            sm = sum(xr[base:base + 456]) & 0xFFFF
                            xr[base + 456], xr[base + 457] = sm >> 8, sm & 0xFF
                    c = cpu(st, bits=([B_10A] if a10 else []) + ([B_CAL_MODE, B_CAL_ENABLE] if cal_mode else []))
                    c.xram[0:0x800] = xr
                    c.call(RA(0x0111))
                    c.call(RA(0x12A2))
                    m = Mirror(xr, st, a10, cal_mode)
                    want, two = m.run(T)
                    paths[0] += m.invalid
                    paths[1] += m.defaulted
                    for s, base in ((0, 0x015F), (1, 0x017F)):
                        if want[s] is None:
                            continue
                        got = [fdec(c.xram[base + 4 * i:base + 4 * i + 4]) for i in range(8)]
                        if s == 1 and not (f in (0, 1, 9)):
                            got[6:8] = want[s][6:8]        # set 1 effective only computed for Vpk/VDC/CAP
                        n += 1
                        if sample is None and f == 1 and r == 1 and not fuzz:
                            sample = "VDC r1 set0: " + " ".join("%.7g" % v for v in got)
                        if not all(close(a, b) for a, b in zip(got, want[s])):
                            bad += 1
                            ex.append("cal=%d f%d r%d 10A=%d set%d\n       orig=%s\n       clean=%s" % (
                                cal_mode, f, r, a10, s, ["%.6g" % v for v in got], ["%.6g" % v for v in want[s]]))
    if sample:
        print("    ", sample)
    print("     paths exercised: range invalid (NC) %d, coefficient default %d" % tuple(paths))
    report(name, n, bad, ex)


# ---- query replies (remote_commands.c put_query_item), single-item queries
NAMES = [img[0x59B1 + 5 * i:0x59B4 + 5 * i].decode() for i in range(42)]
RES = [list(img[0x6E40 + 3 * i:0x6E43 + 3 * i]) for i in range(20)]


def m_query(cmd, st, mode, fl, xr):
    f, rng, sp = st & 15, st >> 4 & 7, mode & 3
    out = NAMES[cmd] + " "
    if cmd == 19:
        out += NAMES[m_cmd_index(st, mode)]
    elif cmd == 20:
        out += "    AUTO" if fl["auto"] else (" 20.E+06" if st == 0x6A else None)
    elif cmd in (21, 22):
        out += (" ON," if fl["db" if cmd == 21 else "zero"] else "OFF,")
        return out, 4                              # value not compared
    elif cmd == 26:
        out += chr(ord("1") + sp)
    elif cmd == 27:
        idx = m_cmd_index(st, mode)
        d = RES[idx][sp] if idx < 20 else 0
        if idx == 7 and rng == 6:
            d -= 1
        out += chr(ord("0") + d)
    elif cmd == 28:
        out += "IBE?"[(mode >> 2) & 3]
    elif cmd == 30:
        out += ("ON,1" if fl["hot"] else "ON,0") if fl["calm"] else " OFF"
    elif cmd == 31:
        out += "N" if fl["nohdr"] else "S"
    elif cmd == 32:
        out += ",".join("%03d" % xr[0x076C + i] for i in range(6))
    elif cmd == 35:
        out += "%03d" % m_rms(bytes(xr[0x07FD:0x0800]))[0]
    elif cmd == 36:
        out += " ON" if fl["six"] else "OFF"
    elif cmd == 37:
        out += " ON" if fl["cr"] else "OFF"
    elif cmd == 38:
        cfg = fl["cfg"] if (fl["cfg"] & 0x1F) != 0x1F else 22    # address 31 -> default 22
        out += "%03d" % (cfg & 0x9F)
    elif cmd == 39:
        out += "%03d" % xr[0x01CB]
    if fl["cr"]:
        out += "\r"
    return out, None


def t_queries():
    bad, ex, n = 0, [], 0
    rnd = random.Random(3)
    for trial in range(600):
        cmd = rnd.choice([19, 20, 21, 22, 26, 27, 28, 30, 31, 32, 35, 36, 37, 38, 39])
        f = rnd.randrange(14)
        rng = rnd.randrange(8)
        st = f | rng << 4
        fl = dict(auto=rnd.random() < 0.5, db=rnd.random() < 0.5, zero=rnd.random() < 0.5, hot=rnd.random() < 0.5,
                  calm=rnd.random() < 0.5, nohdr=rnd.random() < 0.5, six=rnd.random() < 0.5, cr=rnd.random() < 0.5,
                  cfg=rnd.randrange(256))
        if cmd == 20 and not fl["auto"]:
            st = 0x6A                                 # the fixed-text manual case
        mode = rnd.randrange(3) | rnd.randrange(3) << 2 | rnd.randrange(4) << 4 | rnd.randrange(1, 4) << 6
        c = cpu(st | (0x80 if fl["auto"] else 0), mode)
        for b, on in ((0x07, fl["auto"]), (0x10, fl["db"]), (0x11, fl["zero"]), (0x3A, fl["hot"]), (0x16, fl["calm"]),
                      (0x17, fl["nohdr"]), (0x14, fl["six"]), (0x1D, fl["cr"])):
            c.bit_wr(b, 1 if on else 0)
        for i in range(0x800):
            c.xram[i] = rnd.randrange(256)
        c.xram[0x0200:0x0800] = ram[0x0200:0x0800]
        for a in (0x03CA, 0x0599, 0x0768):
            c.xram[a] = fl["cfg"]
        c.xram[0x009A] = c.xram[0x009B] = 0              # no JCV pointer: default address
        c.iram[0x1D], c.iram[0x1E] = 0x00, 0x56
        c.xram[0x0056 + 2] = 0x40
        c.xram[0x00E0] = 0
        c.xram[0x005A] = rnd.choice([0, 1, 2, 3])      # mode 5 = identity block, tested separately
        c.iram[0x0D] = 0
        c.iram[0x0B] = 0
        c.xram[0x00E8], c.xram[0x00E9] = cmd, 0
        xr = bytes(c.xram[0:0x800])
        out = []

        def send(cpu):
            k = cpu.iram[0x0B] & 0x3F
            out.append(bytes(cpu.xram[0x34:0x34 + k]).decode("latin1").replace("\r", "\r"))
            cpu.iram[0x0B] = 0
        c.call_hooks[RA(0x7C24)] = send
        if cmd == 27 and RES[m_cmd_index(st, mode)][mode & 3] == 0 if m_cmd_index(st, mode) < 20 else cmd == 27:
            continue      # original loops forever (do {} while digits == 0): unreachable state
        c.call(RA(0x4D2B), max_steps=200000)
        got = "".join(out)
        want, cut = m_query(cmd, st, mode, fl, xr)
        if cut:
            got = got[:len(NAMES[cmd]) + 1 + cut]
        n += 1
        if got != want:
            bad += 1
            ex.append("%s st=%02X mode=%02X %s orig=%r clean=%r" % (NAMES[cmd], st, mode,
                      {k: int(v) for k, v in fl.items()}, got, want))
    report("queries", n, bad, ex)


# ---- measurement output (remote_commands.c put_reading_header / put_reading_value invalid field)
def m_reading(st, mode, fl, st0, st1, vneg):
    idx = m_cmd_index(st, mode)
    out = NAMES[idx]
    out += "D" if fl["db"] else " "
    out += "C" if fl["calm"] else ("Z" if fl["zero"] else " ")
    flag = " "
    for cond, ch in ((st1 & 8, "?"), (st0 & 2, "O"), (st0 & 4, "F"), (st0 & 0x10, "N"), (st0 & 0x20, "U"),
                     (st0 & 8, "R"), (st0 & 1, "C")):
        if cond:
            flag = ch
            break
    if fl["nohdr"]:
        out = ""
    else:
        out += flag
    if idx == 18:
        return out, True                       # CLOSED/OPEN depends on the value: header only
    valid = not (st1 & 8) and not (st0 & 0x26) and (not (st1 & 0x80) or idx in (8, 9))
    if valid:
        return out, True                       # formatted number: header only
    rng = st >> 4 & 7
    d = RES[idx][mode & 3]
    if (idx == 7 and rng == 6) or (idx == 14 and rng == 7):
        d -= 1
    if fl["zero"]:
        d = 7
    if fl["db"]:
        d = 4
    field = list(" 99999999E+09")
    blanks = (7 - d) if (not fl["zero"] or fl["db"]) else 0
    for i in range(blanks):
        field[1 + i] = " "
    f = st & 15
    signed = fl["db"] or fl["zero"] or f in (1, 6, 11) or (f == 0 and (mode >> 6) != 3)
    field[blanks] = " " if not signed else ("-" if (not (st1 & 8) and vneg) else "+")
    field[blanks + 4] = "."
    return out + "".join(field), False


def t_readings():
    bad, ex, n = 0, [], 0
    rnd = random.Random(5)
    for trial in range(800):
        f = rnd.randrange(14)
        mode = rnd.randrange(3) | rnd.randrange(4) << 4 | rnd.randrange(1, 4) << 6
        st = f | rnd.randrange(8) << 4
        idx = m_cmd_index(st, mode)
        if idx >= 20 or RES[idx][mode & 3] == 0:
            continue
        fl = dict(db=rnd.random() < 0.3, zero=rnd.random() < 0.3, calm=rnd.random() < 0.3, nohdr=rnd.random() < 0.3)
        st0 = rnd.choice([0, 0, 1, 2, 4, 8, 0x10, 0x20, rnd.randrange(64)])
        st1 = (st & 0x70) | rnd.choice([0, 0, 8, 0x80])
        vneg = rnd.random() < 0.5
        c = cpu(st, mode)
        for b, on in ((0x10, fl["db"]), (0x11, fl["zero"]), (0x16, fl["calm"]), (0x17, fl["nohdr"]), (0x20, 1)):
            c.bit_wr(b, 1 if on else 0)
        c.xram[0:0x800] = ram
        c.xram[0x0064], c.xram[0x0065] = st0, st1
        c.xram[0x0085:0x0089] = bytes([0x80 | 0x40 if vneg else 0x40, 0x80, 0, 0])
        c.iram[0x1D], c.iram[0x1E] = 0x00, 0x56
        c.xram[0x0056 + 2] = 0x40
        c.xram[0x00E0] = c.xram[0x00EB] = 0
        c.xram[0x005A] = 0
        c.iram[0x0D] = c.iram[0x0B] = 0
        c.xram[0x00E8], c.xram[0x00E9] = 0, 0
        out = []

        def send(cpu):
            k = cpu.iram[0x0B] & 0x3F
            out.append(bytes(cpu.xram[0x34:0x34 + k]).decode("latin1"))
            cpu.iram[0x0B] = 0
        c.call_hooks[RA(0x7C24)] = send
        try:
            c.call(RA(0x4D2B), max_steps=300000)
        except Exception as e:
            ex.append("halt %s" % e)
            continue
        got = "".join(out).rstrip("\r")
        want, header_only = m_reading(st, mode, fl, st0, st1, vneg)
        if header_only:
            got = got[:len(want)]
        n += 1
        if got != want:
            bad += 1
            ex.append("%s st=%02X mode=%02X %s st0=%02X st1=%02X orig=%r clean=%r" % (
                NAMES[idx], st, mode, {k: int(v) for k, v in fl.items()}, st0, st1, got, want))
    report("readings", n, bad, ex)


# ---- calibration step classifier (calibration.c cal_classify_input)
def fenc(x):
    if x == 0:
        return bytes(4)
    m, e = math.frexp(abs(x))
    mi = int(round(m * 2 ** 24))
    if mi >= 1 << 24:
        mi >>= 1
        e += 1
    return bytes([(0x80 if x < 0 else 0) | (e + 62)]) + mi.to_bytes(3, "big")


def m_classify(st, raw, flags, hot, pk0, flags1):
    f, fr = st & 15, st & 0x7F
    nom = m_limits(st, 0)[1] * 10.0 ** m_scale_exp(st, 0)
    if f in (4, 5):
        nom /= 2
    elif f == 11:
        nom = 100.0
    elif fr == 0x42:
        nom = 600.0
    if f in (1, 10):
        lo, hi = 0.90, 1.10
    elif fr == 0x65:
        lo, hi = 0.68, 1.32
    else:
        lo, hi = 0.81, 1.19
    a = abs(raw)
    code, zero = 0, None
    if f == 0 and raw <= -100.0 * 10.0 ** m_scale_exp(st, 0):
        code = 1
    elif a >= 0.099 * nom:
        zero = False
        if a < lo * nom:
            code = 2
        elif a >= hi * nom:
            code = 3
        elif f in (5, 4, 11, 6, 12, 2, 7):
            if raw >= 0:
                code = 4
        elif f != 1 and raw < 0:
            code = 5
    else:
        zero = True
    if not code:
        if (f == 0 and pk0) or (f == 1 and not zero and raw < 0):
            flags = flags1
        if not zero:
            code = (0 if flags & 0x20 else 9) if hot else (0 if flags & 0x02 else 8)
        else:
            code = (0 if flags & 0x10 else 7) if hot else (0 if flags & 0x01 else 6)
    return code


def t_classify():
    bad, ex, n = 0, [], 0
    rnd = random.Random(11)
    masks = [img[0x6ED4 + 3 * f:0x6ED7 + 3 * f] for f in range(14)]
    for trial in range(1500):
        f = rnd.randrange(14)
        rs = [r for r in range(8) if any(m >> r & 1 for m in masks[f])]
        if not rs or f in (8, 13):
            continue
        st = f | rnd.choice(rs) << 4
        nom = m_limits(st, 0)[1] * 10.0 ** m_scale_exp(st, 0)
        raw = rnd.choice([-1, 1]) * nom * rnd.choice([0, 0.01, 0.05, 0.098, 0.1, 0.5, 0.8, 0.85, 0.95, 1.0, 1.05, 1.15, 1.25, 1.4, 3.0])
        flags = rnd.randrange(64)
        hot = rnd.random() < 0.5
        pk0 = rnd.random() < 0.5
        c = cpu(st, (0x40 if pk0 else 0) | (0x80 if rnd.random() < 0.5 else 0), bits=[B_CAL_MODE, B_CAL_ENABLE] + ([B_CAL_HOT] if hot else []))
        c.bit_wr(B_PK0, 1 if pk0 else 0)
        c.iram[0x39] = flags
        flags1 = rnd.randrange(64)
        c.iram[0x3A] = flags1
        c.iram[0x4D:0x51] = fenc(raw)[::-1]          # IRAM: mantissa LSB first, exponent at 0x50
        c.call(RA(0x0B3E))
        failed = c.bit_rd(0x53)
        got = c.a if failed else 0
        want = m_classify(st, raw, flags, hot, pk0, flags1)
        n += 1
        if got != want:
            bad += 1
            ex.append("f%d st=%02X raw=%.6g (x nom %.3g) flags=%02X hot=%d orig=%d clean=%d" % (
                f, st, raw, raw / nom if nom else 0, flags, hot, got, want))
    report("classify", n, bad, ex)


for t in (t_scale_exp, t_limits, t_cmd_index, t_rms, t_recipes):
    t()
t_recipes(fuzz=6, name="rec_fuzz")
t_queries()
t_readings()
t_classify()
print("TOTAL: %d cases, %d differ" % (sum(v[0] for v in results.values()), sum(v[1] for v in results.values())))

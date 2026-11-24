#!/usr/bin/env python3
"""Minimal 8051 emulator for running individual PM2525 firmware routines.

Not cycle-accurate; no peripherals beyond plain SFR storage. Ports read back what was written
unless a read hook is installed. Intended for calling a routine with prepared RAM state and
inspecting the result, e.g.:

    from emu8051 import CPU
    c = CPU(open("PM2525_S25.BIN","rb").read())
    c.call(0x7804)            # runs until the routine returns
    print(hex(c.iram[0x2E]))
"""

ACC, B_, PSW, SP, DPL, DPH = 0xE0, 0xF0, 0xD0, 0x81, 0x82, 0x83


class Halt(Exception):
    pass


class CPU:
    def __init__(self, code):
        self.code = bytearray(code) + bytearray(0x10000 - len(code))
        self.iram = bytearray(256)          # 0x00-0x7F IRAM (8031 has 128), 0x80-0xFF SFR
        self.xram = bytearray(0x10000)
        self.pc = 0
        self.iram[SP] = 0x07
        self.read_hooks = {}                # SFR addr -> fn() returning byte (ports)
        self.call_hooks = {}                # code addr -> fn(cpu) emulating a routine (then RET)
        self.steps = 0
        self.trace = None

    # ---- memory helpers
    def d_rd(self, a):
        if a >= 0x80 and a in self.read_hooks:
            return self.read_hooks[a]() & 0xFF
        return self.iram[a]

    def d_wr(self, a, v):
        self.iram[a] = v & 0xFF
        if a == ACC:
            self._parity()

    def i_rd(self, a):
        return self.iram[a & 0x7F if a < 0x80 else a]   # indirect: 8031 only has 128 bytes; keep 256 for safety

    def i_wr(self, a, v):
        self.iram[a] = v & 0xFF

    def _parity(self):
        p = bin(self.iram[ACC]).count("1") & 1
        self.iram[PSW] = (self.iram[PSW] & 0xFE) | p

    @property
    def a(self):
        return self.iram[ACC]

    @a.setter
    def a(self, v):
        self.iram[ACC] = v & 0xFF
        self._parity()

    @property
    def cy(self):
        return self.iram[PSW] >> 7

    @cy.setter
    def cy(self, v):
        self.iram[PSW] = (self.iram[PSW] & 0x7F) | (0x80 if v else 0)

    @property
    def dptr(self):
        return self.iram[DPH] << 8 | self.iram[DPL]

    @dptr.setter
    def dptr(self, v):
        self.iram[DPH] = (v >> 8) & 0xFF
        self.iram[DPL] = v & 0xFF

    def r(self, n):
        return ((self.iram[PSW] >> 3) & 3) * 8 + n

    def bit_addr(self, b):
        return (b & 0xF8, b & 7) if b >= 0x80 else (0x20 + (b >> 3), b & 7)

    def bit_rd(self, b):
        a, n = self.bit_addr(b)
        return (self.d_rd(a) >> n) & 1

    def bit_wr(self, b, v):
        a, n = self.bit_addr(b)
        x = self.iram[a]
        x = (x | (1 << n)) if v else (x & ~(1 << n))
        self.d_wr(a, x)

    def push(self, v):
        self.iram[SP] = (self.iram[SP] + 1) & 0xFF
        self.iram[self.iram[SP]] = v & 0xFF

    def pop(self):
        v = self.iram[self.iram[SP]]
        self.iram[SP] = (self.iram[SP] - 1) & 0xFF
        return v

    def fetch(self):
        v = self.code[self.pc]
        self.pc = (self.pc + 1) & 0xFFFF
        return v

    def rel(self):
        r = self.fetch()
        return (self.pc + (r - 256 if r > 127 else r)) & 0xFFFF

    # ---- arithmetic with flags
    def add(self, v, c=0):
        a = self.a
        res = a + v + c
        ac = ((a & 0xF) + (v & 0xF) + c) > 0xF
        ov = ((a ^ res) & (v ^ res) & 0x80) != 0
        psw = self.iram[PSW] & 0x3B
        psw |= (0x80 if res > 0xFF else 0) | (0x40 if ac else 0) | (0x04 if ov else 0)
        self.iram[PSW] = psw
        self.a = res

    def subb(self, v):
        a, c = self.a, self.cy
        res = a - v - c
        ac = ((a & 0xF) - (v & 0xF) - c) < 0
        ov = ((a ^ v) & (a ^ res) & 0x80) != 0
        psw = self.iram[PSW] & 0x3B
        psw |= (0x80 if res < 0 else 0) | (0x40 if ac else 0) | (0x04 if ov else 0)
        self.iram[PSW] = psw
        self.a = res & 0xFF

    # ---- run
    def call(self, addr, max_steps=2_000_000):
        """Call routine at addr; return when it RETs to the sentinel."""
        sentinel = 0xFFFF
        self.push(sentinel & 0xFF)
        self.push(sentinel >> 8)
        self.pc = addr
        start_sp = self.iram[SP]
        while True:
            if self.pc == sentinel:
                return
            if self.pc in self.call_hooks:
                self.call_hooks[self.pc](self)
                hi, lo = self.pop(), self.pop()
                self.pc = hi << 8 | lo
                continue
            self.step()
            if self.steps > max_steps:
                raise Halt("step limit at %04X" % self.pc)

    def step(self):
        self.steps += 1
        pc0 = self.pc
        if self.trace:
            self.trace(self, pc0)
        op = self.fetch()
        lo = op & 0x0F
        # register / indirect operand decode for regular ops
        if lo >= 8:
            reg = lambda: self.r(op & 7)
            src_rd = lambda: self.iram[self.r(op & 7)]
            src_wr = lambda v: self.d_wr(self.r(op & 7), v)
        elif lo in (6, 7):
            src_rd = lambda: self.i_rd(self.iram[self.r(op & 1)])
            src_wr = lambda v: self.i_wr(self.iram[self.r(op & 1)], v)
        hi = op >> 4
        if lo == 1:   # AJMP / ACALL
            t = (self.pc & 0xF800) | ((op >> 5) << 8) | self.fetch()
            if op & 0x10:
                self.push(self.pc & 0xFF)
                self.push(self.pc >> 8)
            self.pc = t
            return
        if op == 0x00:
            return
        if op == 0x02:
            self.pc = self.fetch() << 8 | self.fetch()
            return
        if op == 0x12:
            t = self.fetch() << 8 | self.fetch()
            self.push(self.pc & 0xFF)
            self.push(self.pc >> 8)
            self.pc = t
            return
        if op in (0x22, 0x32):
            hi_, lo_ = self.pop(), self.pop()
            self.pc = hi_ << 8 | lo_
            return
        if op == 0x03:
            self.a = (self.a >> 1) | ((self.a & 1) << 7); return
        if op == 0x13:
            c = self.a & 1; self.a = (self.a >> 1) | (self.cy << 7); self.cy = c; return
        if op == 0x23:
            self.a = ((self.a << 1) | (self.a >> 7)) & 0xFF; return
        if op == 0x33:
            c = self.a >> 7; self.a = ((self.a << 1) | self.cy) & 0xFF; self.cy = c; return
        if op == 0x04:
            self.a = self.a + 1; return
        if op == 0x14:
            self.a = self.a - 1; return
        if op == 0x05:
            d = self.fetch(); self.d_wr(d, self.d_rd(d) + 1); return
        if op == 0x15:
            d = self.fetch(); self.d_wr(d, self.d_rd(d) - 1); return
        if hi in (0, 1) and lo >= 6:
            src_wr(src_rd() + (1 if hi == 0 else -1)); return
        if op in (0x10, 0x20, 0x30):
            b = self.fetch(); t = self.rel(); v = self.bit_rd(b)
            if op == 0x10 and v:
                self.bit_wr(b, 0); self.pc = t
            elif op == 0x20 and v:
                self.pc = t
            elif op == 0x30 and not v:
                self.pc = t
            return
        if op in (0x40, 0x50, 0x60, 0x70, 0x80):
            t = self.rel()
            c = {0x40: self.cy == 1, 0x50: self.cy == 0, 0x60: self.a == 0, 0x70: self.a != 0, 0x80: True}[op]
            if c:
                self.pc = t
            return
        # ALU group: ADD 2x, ADDC 3x, ORL 4x, ANL 5x, XRL 6x, SUBB 9x
        if hi in (2, 3, 4, 5, 6, 9) and lo >= 4:
            if lo == 4:
                v = self.fetch()
            elif lo == 5:
                v = self.d_rd(self.fetch())
            else:
                v = src_rd()
            if hi == 2: self.add(v)
            elif hi == 3: self.add(v, self.cy)
            elif hi == 4: self.a = self.a | v
            elif hi == 5: self.a = self.a & v
            elif hi == 6: self.a = self.a ^ v
            else: self.subb(v)
            return
        if hi in (4, 5, 6) and lo in (2, 3):
            d = self.fetch()
            v = self.a if lo == 2 else self.fetch()
            x = self.d_rd(d)
            x = x | v if hi == 4 else (x & v if hi == 5 else x ^ v)
            self.d_wr(d, x); return
        if op in (0x72, 0x82, 0xA0, 0xB0):
            v = self.bit_rd(self.fetch())
            if op == 0x72: self.cy = self.cy | v
            elif op == 0x82: self.cy = self.cy & v
            elif op == 0xA0: self.cy = self.cy | (v ^ 1)
            else: self.cy = self.cy & (v ^ 1)
            return
        if op == 0x73:
            self.pc = (self.a + self.dptr) & 0xFFFF; return
        if op == 0x83:
            self.a = self.code[(self.a + self.pc) & 0xFFFF]; return
        if op == 0x93:
            self.a = self.code[(self.a + self.dptr) & 0xFFFF]; return
        if op == 0x74:
            self.a = self.fetch(); return
        if op == 0x75:
            d = self.fetch(); self.d_wr(d, self.fetch()); return
        if op in (0x76, 0x77):
            self.i_wr(self.iram[self.r(op & 1)], self.fetch()); return
        if 0x78 <= op <= 0x7F:
            self.d_wr(self.r(op & 7), self.fetch()); return
        if op == 0x84:
            a, b = self.a, self.iram[B_]
            psw = self.iram[PSW] & 0x7B
            if b == 0:
                self.iram[PSW] = psw | 0x04
            else:
                self.a = a // b; self.iram[B_] = a % b; self.iram[PSW] = psw
            return
        if op == 0xA4:
            p = self.a * self.iram[B_]
            self.a = p & 0xFF; self.iram[B_] = p >> 8
            self.iram[PSW] = (self.iram[PSW] & 0x7B) | (0x04 if p > 0xFF else 0)
            return
        if op == 0x85:
            s = self.fetch(); d = self.fetch(); self.d_wr(d, self.d_rd(s)); return
        if op in (0x86, 0x87):
            d = self.fetch(); self.d_wr(d, src_rd()); return
        if 0x88 <= op <= 0x8F:
            d = self.fetch(); self.d_wr(d, src_rd()); return
        if op == 0x90:
            self.dptr = self.fetch() << 8 | self.fetch(); return
        if op == 0x92:
            self.bit_wr(self.fetch(), self.cy); return
        if op == 0xA2:
            self.cy = self.bit_rd(self.fetch()); return
        if op == 0xA3:
            self.dptr = (self.dptr + 1) & 0xFFFF; return
        if op in (0xA6, 0xA7):
            src_wr(self.d_rd(self.fetch())); return
        if 0xA8 <= op <= 0xAF:
            src_wr(self.d_rd(self.fetch())); return
        if op == 0xB2:
            b = self.fetch(); self.bit_wr(b, self.bit_rd(b) ^ 1); return
        if op == 0xB3:
            self.cy ^= 1; return
        if op == 0xC2:
            self.bit_wr(self.fetch(), 0); return
        if op == 0xC3:
            self.cy = 0; return
        if op == 0xD2:
            self.bit_wr(self.fetch(), 1); return
        if op == 0xD3:
            self.cy = 1; return
        if 0xB4 <= op <= 0xBF:
            if op == 0xB4:
                x, v = self.a, self.fetch()
            elif op == 0xB5:
                x, v = self.a, self.d_rd(self.fetch())
            else:
                x, v = src_rd(), self.fetch()
            t = self.rel()
            self.cy = 1 if x < v else 0
            if x != v:
                self.pc = t
            return
        if op == 0xC0:
            self.push(self.d_rd(self.fetch())); return
        if op == 0xD0:
            self.d_wr(self.fetch(), self.pop()); return
        if op == 0xC4:
            self.a = ((self.a << 4) | (self.a >> 4)) & 0xFF; return
        if op == 0xC5:
            d = self.fetch(); x = self.d_rd(d); self.d_wr(d, self.a); self.a = x; return
        if op in (0xC6, 0xC7) or 0xC8 <= op <= 0xCF:
            x = src_rd(); src_wr(self.a); self.a = x; return
        if op == 0xD4:
            a = self.a
            if (a & 0xF) > 9 or (self.iram[PSW] & 0x40):
                a += 6
            if (a >> 4) > 9 or self.cy or a > 0xFF:
                a += 0x60
            if a > 0xFF:
                self.cy = 1
            self.a = a & 0xFF; return
        if op == 0xD5:
            d = self.fetch(); t = self.rel(); v = (self.d_rd(d) - 1) & 0xFF; self.d_wr(d, v)
            if v:
                self.pc = t
            return
        if op in (0xD6, 0xD7):
            x = src_rd(); src_wr((x & 0xF0) | (self.a & 0xF)); self.a = (self.a & 0xF0) | (x & 0xF); return
        if 0xD8 <= op <= 0xDF:
            t = self.rel(); v = (src_rd() - 1) & 0xFF; src_wr(v)
            if v:
                self.pc = t
            return
        if op == 0xE0:
            self.a = self.xram[self.dptr]; return
        if op in (0xE2, 0xE3):
            self.a = self.xram[self.iram[self.r(op & 1)] | (self.iram[0xA0] << 8)]; return
        if op == 0xE4:
            self.a = 0; return
        if op == 0xE5:
            self.a = self.d_rd(self.fetch()); return
        if op in (0xE6, 0xE7) or 0xE8 <= op <= 0xEF:
            self.a = src_rd(); return
        if op == 0xF0:
            self.xram[self.dptr] = self.a; return
        if op in (0xF2, 0xF3):
            self.xram[self.iram[self.r(op & 1)] | (self.iram[0xA0] << 8)] = self.a; return
        if op == 0xF4:
            self.a = self.a ^ 0xFF; return
        if op == 0xF5:
            self.d_wr(self.fetch(), self.a); return
        if op in (0xF6, 0xF7) or 0xF8 <= op <= 0xFF:
            src_wr(self.a); return
        raise Halt("unimplemented opcode %02X at %04X" % (op, pc0))

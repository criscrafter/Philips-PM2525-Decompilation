#!/usr/bin/env python3
"""Run the whole PM2525 firmware from reset in the emulator and log the I2C traffic on bus A
(SDA=P1.1, SCL=P3.2), i.e. what an interface board / Pico emulating one sees.

Bus-A and bus-B bit-bang primitives are replaced by hooks; bus B (LCD, ADC interface, PCF8574 0x48)
devices always ACK and read as 0. A scriptable slave answers on bus A.

Usage: python emu_iface.py IMAGE.BIN [--steps N] [--slave-reads HEX...]
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from emu8051 import CPU, Halt


class BusLog:
    def __init__(self, name):
        self.name, self.cur, self.tx = name, None, []

    def start(self, cpu, addr):
        if self.cur:
            self.tx.append(self.cur)
        self.cur = {"step": cpu.steps, "pc": None, "addr": addr, "bytes": [], "rd": addr & 1}

    def byte(self, b, d):
        if self.cur is None:
            self.cur = {"step": 0, "addr": None, "bytes": [], "rd": 0}
        self.cur["bytes"].append((d, b))

    def stop(self):
        if self.cur:
            self.tx.append(self.cur)
            self.cur = None


def install(c, slave_read):
    A, B = BusLog("A"), BusLog("B")

    def ack(cpu, nak=False):
        cpu.cy = 1 if nak else 0

    def a_present(addr):
        return (addr & 0xFE) in (0x4E, 0x58, 0x5A, 0x5C, 0x5E)

    # ---- bus A
    def a_start_w(cpu):
        A.start(cpu, cpu.a & 0xFE); ack(cpu, not a_present(cpu.a))

    def a_start_r(cpu):
        A.start(cpu, cpu.a | 1); ack(cpu, not a_present(cpu.a))

    def a_send(cpu):
        A.byte(cpu.a, "w"); ack(cpu)

    def a_recv(cpu):
        v = slave_read(A.cur["addr"] if A.cur else None, len(A.cur["bytes"]) if A.cur else 0)
        A.byte(v, "r"); cpu.a = v

    def a_recv_ack(cpu):
        a_recv(cpu)

    def a_recv_nack_stop(cpu):
        a_recv(cpu); A.stop(); cpu.cy = 0

    def a_send_stop(cpu):
        A.byte(cpu.a, "w"); A.stop(); cpu.cy = 0

    def a_stop(cpu):
        A.stop()

    def a_read1(cpu):
        A.start(cpu, cpu.a | 1)
        if not a_present(cpu.a):
            cpu.cy = 1; A.stop(); return
        a_recv(cpu); A.stop(); cpu.cy = 0

    def a_write1(cpu):
        A.start(cpu, cpu.a & 0xFE)
        if not a_present(cpu.a):
            cpu.cy = 1; A.stop(); return
        A.byte(cpu.iram[cpu.r(3)], "w"); A.stop(); cpu.cy = 0

    hooks = {0x6377: a_start_w, 0x6388: a_start_r, 0x6397: a_send, 0x63FA: a_recv, 0x63DD: a_recv_ack,
             0x6359: a_recv_nack_stop, 0x635C: lambda cpu: (A.stop(), setattr(cpu, "cy", 0)),
             0x6369: a_send_stop, 0x63C8: a_stop, 0x63E1: lambda cpu: None, 0x63AD: lambda cpu: ack(cpu),
             0x6354: a_read1, 0x6363: a_write1}

    # ---- bus B: everything ACKs, reads 0
    def b_start(cpu):
        B.start(cpu, cpu.a); ack(cpu)
    hooks.update({0x6B55: lambda cpu: (B.start(cpu, cpu.a & 0xFE), ack(cpu)),
                  0x6B62: lambda cpu: (B.start(cpu, cpu.a | 1), ack(cpu)),
                  0x6B64: b_start,
                  0x6B6F: lambda cpu: (B.byte(cpu.a, "w"), ack(cpu)),
                  0x6B81: lambda cpu: ack(cpu),
                  0x6B8F: lambda cpu: B.stop(),
                  0x6BB0: lambda cpu: setattr(cpu, "a", 0),
                  0x6B44: lambda cpu: (B.start(cpu, cpu.a), B.byte(cpu.iram[cpu.r(3)], "w"), B.stop(), ack(cpu)),
                  0x6B9B: lambda cpu: (B.start(cpu, cpu.a), setattr(cpu, "a", 0), B.stop(), ack(cpu)),
                  0x6B3A: lambda cpu: (setattr(cpu, "a", 0), B.stop(), ack(cpu)),
                  0x6B4A: lambda cpu: (B.byte(cpu.a, "w"), B.stop(), ack(cpu))})
    c.call_hooks.update(hooks)
    c.read_hooks[0xB0] = lambda: 0xFF          # P3 pins idle high (CAL key not pressed, READY high)
    return A, B


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("--steps", type=int, default=3_000_000)
    ap.add_argument("--show", type=int, default=60)
    a = ap.parse_args()
    img = open(a.image, "rb").read()
    c = CPU(img)

    def slave_read(addr, idx):
        return 0x00
    A, B = install(c, slave_read)
    try:
        c.call(0x0000, max_steps=a.steps)
    except Halt as e:
        print("stopped:", e)
    A.stop()
    print("bus A transactions: %d" % len(A.tx))
    for t in A.tx[:a.show]:
        print("  @%9d addr=%s %s" % (t["step"], ("%02X" % t["addr"]) if t["addr"] is not None else "--",
                                     " ".join("%s%02X" % (d, b) for d, b in t["bytes"])))


if __name__ == "__main__":
    main()

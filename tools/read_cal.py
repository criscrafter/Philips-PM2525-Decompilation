#!/usr/bin/env python3
"""Read the PM2525's battery-backed RAM and calibration listing through the Pico AR488/Prologix bridge.

Read-only: only `JCV <addr>` (sets a one-shot read pointer), `JCV ?` and `CDP ?` are sent.

Usage: python read_cal.py COM20 OUTPREFIX [--start 0] [--end 2048] [--no-cdp]
Writes OUTPREFIX_ram.bin (2048 bytes, unread bytes 0), OUTPREFIX_ram_log.txt, OUTPREFIX_cdp.txt.
"""
import argparse
import re
import sys
import time

import serial


class Bridge:
    def __init__(self, port):
        self.s = serial.Serial(port, 115200, timeout=0.05)
        time.sleep(0.2)
        self.s.reset_input_buffer()

    def send(self, line):
        self.s.write((line + "\n").encode())

    def read(self, timeout=3.0, idle=0.08):
        """++read and collect bytes until the line goes idle."""
        self.send("++read")
        buf, t0, last = b"", time.time(), None
        while time.time() - t0 < timeout:
            c = self.s.read(256)
            if c:
                buf += c
                last = time.time()
            elif last and time.time() - last > idle:
                break
        return buf.decode("latin1").strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("port")
    ap.add_argument("out")
    ap.add_argument("--start", type=lambda x: int(x, 0), default=0)
    ap.add_argument("--end", type=lambda x: int(x, 0), default=0x800)
    ap.add_argument("--no-cdp", action="store_true")
    a = ap.parse_args()
    b = Bridge(a.port)
    ram = bytearray(0x800)
    got = bytearray(0x800)
    log = open(a.out + "_ram_log.txt", "w")
    t0 = time.time()
    addr = a.start
    while addr < a.end:
        for attempt in range(3):
            b.send("JCV %d" % addr)
            b.send("JCV ?")
            r = b.read()
            m = re.match(r"JCV (\d{3}),(\d{3}),(\d{3}),(\d{3}),(\d{3}),(\d{3})$", r)
            if m:
                break
            time.sleep(0.3)
        log.write("%04X %s\n" % (addr, r))
        if not m:
            print("\nno valid answer at %04X: %r" % (addr, r))
            sys.exit(1)
        for i, v in enumerate(m.groups()):
            if addr + i < 0x800:
                ram[addr + i] = int(v)
                got[addr + i] = 1
        addr += 6
        if (addr // 6) % 20 == 0:
            el = time.time() - t0
            print("\r%04X  %.0f s" % (addr, el), end="", flush=True)
    print("\nRAM read done in %.0f s" % (time.time() - t0))
    open(a.out + "_ram.bin", "wb").write(bytes(ram))
    log.close()
    if not a.no_cdp:
        b.send("CDP ?")
        lines = []
        for n in range(114):
            r = b.read()
            lines.append(r)
            if not r.startswith("CDP "):
                print("unexpected CDP answer %d: %r" % (n + 1, r))
        open(a.out + "_cdp.txt", "w").write("\n".join(lines) + "\n")
        print("CDP listing: %d lines" % len(lines))


if __name__ == "__main__":
    main()

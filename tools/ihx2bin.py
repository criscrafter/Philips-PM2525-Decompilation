#!/usr/bin/env python3
"""Intel HEX -> 32 KB EPROM image (unused bytes 0xFF), and compare with a reference image.
Usage: python ihx2bin.py IN.ihx OUT.bin [REFERENCE.bin]"""
import sys
data = bytearray(b"\xFF" * 0x8000)
hi = 0
for line in open(sys.argv[1]):
    line = line.strip()
    if not line.startswith(":"):
        continue
    b = bytes.fromhex(line[1:])
    n, addr, typ = b[0], b[1] << 8 | b[2], b[3]
    if sum(b) & 0xFF:
        sys.exit("checksum error in " + line)
    if typ == 0:
        a = hi + addr
        if a + n > len(data):
            sys.exit("data beyond 32 KB at %04X" % a)
        data[a:a + n] = b[4:4 + n]
    elif typ == 4:
        hi = (b[4] << 8 | b[5]) << 16
open(sys.argv[2], "wb").write(data)
if len(sys.argv) > 3:
    ref = open(sys.argv[3], "rb").read()
    diff = [i for i in range(len(ref)) if ref[i] != data[i]]
    if diff:
        print("DIFFERENT: %d bytes, first at 0x%04X (built %02X, original %02X)" % (
            len(diff), diff[0], data[diff[0]], ref[diff[0]]))
        sys.exit(1)
    print("IDENTICAL to %s (%d bytes)" % (sys.argv[3], len(ref)))

#!/usr/bin/env python3
"""Check a PM2525 RAM backup (from read_cal.py): checksums, copy agreement, settings, and the
RAM floats against the meter's own CDP listing.

Usage: python check_cal_backup.py PREFIX   (reads PREFIX_ram.bin and PREFIX_cdp.txt, writes PREFIX_report.md)
"""
import re
import sys

COPIES = (0x0200, 0x03CF, 0x059E)
SUMS = (0x03C8, 0x0597, 0x0766)
SETTINGS = (0x03CA, 0x0599, 0x0768)
N = 0x1C8


def fdec(b):
    if b[0] & 0x7F == 0:
        return 0.0
    return (-1 if b[0] & 0x80 else 1) * int.from_bytes(b[1:], "big") / 2 ** 24 * 2 ** ((b[0] & 0x7F) - 62)


def main():
    pre = sys.argv[1]
    ram = open(pre + "_ram.bin", "rb").read()
    cdp = {}
    for line in open(pre + "_cdp.txt"):
        m = re.match(r"CDP (.)(\d{3}),(\S+)", line.rstrip("\n"))
        if m:
            cdp[int(m.group(2))] = (m.group(1), float(m.group(3)))
    out = []
    w = out.append
    w("# Calibration backup check: `%s`\n" % pre)
    w("## Checksums\n")
    w("| Copy | Data | Stored (lo,hi) | Computed | OK |\n|---|---|---|---|---|")
    ok_sum = []
    for k, (b, s) in enumerate(zip(COPIES, SUMS)):
        calc = sum(ram[b:b + N]) & 0xFFFF
        stored = ram[s] | ram[s + 1] << 8
        ok_sum.append(calc == stored)
        w("| %d | %04X–%04X | %04X | %04X | %s |" % (k + 1, b, b + N - 1, stored, calc, "yes" if calc == stored else "**NO**"))
    w("\n## Copy agreement\n")
    diffs = [i for i in range(N) if not (ram[COPIES[0] + i] == ram[COPIES[1] + i] == ram[COPIES[2] + i])]
    w("Bytes where the three copies differ: %d" % len(diffs))
    for i in diffs[:40]:
        w("- offset %03X (slot %d): %02X / %02X / %02X" % (i, i // 4 + 1, ram[COPIES[0] + i], ram[COPIES[1] + i], ram[COPIES[2] + i]))
    w("\n## Settings and service bytes\n")
    for i in range(5):
        v = [ram[s + i] for s in SETTINGS]
        w("- settings byte %d: %s%s" % (i + 1, " / ".join("%02X" % x for x in v),
                                       ("  ('%s')" % chr(v[0]) if 0x20 <= v[0] < 0x7F else "")))
    gp = ram[SETTINGS[0]] & 0x1F
    w("- GPIB address (byte 1 & 0x1F): %d" % gp)
    rms = ram[0x07FD:0x0800]
    w("- RMS byte 0x07FD: %d, check bytes %02X %02X (%s)" % (
        rms[0], rms[1], rms[2], "valid" if (rms[1] - 0x55) & 0xFF == rms[0] and (rms[2] - 0xAA) & 0xFF == rms[0] else "INVALID"))
    w("- error counters 0x076C–0x0771: %s" % ",".join("%d" % x for x in ram[0x076C:0x0772]))
    w("\n## Slots: RAM (copy 1) vs CDP listing\n")
    w("| Slot | XDATA | Raw | RAM value | CDP status | CDP value | match |\n|---|---|---|---|---|---|---|")
    bad = 0
    for n in range(1, 115):
        a = COPIES[0] + 4 * (n - 1)
        raw = ram[a:a + 4]
        v = fdec(raw)
        st, cv = cdp.get(n, ("?", None))
        match = cv is not None and (abs(v - cv) <= max(abs(v), 1e-30) * 1e-6 or (v == 0 and cv == 0))
        bad += not match
        w("| %d | %03X | %s | %.7g | %s | %s | %s |" % (n, a, raw.hex(), v, st if st != " " else "ok",
                                                   "%.7g" % cv if cv is not None else "-", "yes" if match else "**NO**"))
    w("\nCDP lines read: %d, mismatches: %d" % (len(cdp), bad))
    open(pre + "_report.md", "w", encoding="utf-8").write("\n".join(out) + "\n")
    print("checksums:", ok_sum, "copy diffs:", len(diffs), "cdp lines:", len(cdp), "mismatches:", bad)
    print("statuses:", sorted(set(s for s, _ in cdp.values())))


if __name__ == "__main__":
    main()

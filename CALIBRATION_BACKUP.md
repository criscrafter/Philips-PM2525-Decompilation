# Backing up the PM2525 calibration with the Pico interface emulator (S25)

Combines the firmware decompilation (verified by running the meter's own code in `tools/emu8051.py`)
with the real-hardware protocol results in `manuals/06_option_bus_protocol_hardware_notes.md`.
Reading is safe; **writing has not been tried on a meter**.

## Why it matters

The calibration is not in the EPROM. It lives in the battery-backed 6116 RAM (XDATA 0x0000–0x07FF):

| XDATA | Content |
|---|---|
| 0x0200–0x03C7 | calibration copy 1: 114 floats, slot n at 0x0200 + 4·(n−1) |
| 0x03C8–0x03C9 | copy-1 checksum (16-bit additive) |
| 0x03CA–0x03CE | settings copy 1 (byte 1 = GPIB address, byte 4 = cal seal 'N'/'a') |
| 0x03CF–0x0596, 0x0597, 0x0599–0x059D | copy 2 / checksum / settings copy 2 |
| 0x059E–0x0765, 0x0766, 0x0768–0x076C | copy 3 / checksum / settings copy 3 |
| 0x076C–0x0771 | error counters (also what plain `JCV ?` shows) |
| 0x07FD–0x07FF | RMS byte (value, +0x55, +0xAA) |

Test meter 2 (`CDP E001`, `RMS 065`, NC on the display, garbage `JCV ?`) matches this RAM having been
lost: `E` means the three copies of a slot all disagree, and 65 is the RMS fallback value.

## Method 1 (recommended): bit-exact RAM dump with `JCV`

`JCV <address>` (decimal) sets a one-shot read pointer; the next `JCV ?` returns the 6 bytes at that
XDATA address as `JCV ddd,ddd,ddd,ddd,ddd,ddd` (decimal bytes). Without a fresh `JCV <address>` it
reads 0x076C (1900). Verified in the emulator, including test meter 1's exact `JCV ?` answer.
No calibration mode is needed.

Host loop over the Pico (commands framed as in `manuals/06_option_bus_protocol_hardware_notes.md`, one message each):

```
for addr in range(0x0000, 0x0800, 6):      # 342 steps
    send  "JCV <addr in decimal>"
    send  "JCV ?"
    talk  (FE) until a 6x block arrives  ->  "JCV 001,000,..."  -> 6 bytes at addr..addr+5
```

That gives a complete 2 KB image of the meter's RAM. Only 0x0200–0x07FF matters for a backup:
calibration, checksums, settings, counters and RMS. Below 0x0200 is working RAM. Save it as a
2048-byte binary file. Each copy's checksum is easy to check offline (sum of the 456 bytes, 16 bit).

## Method 2: the meter's own calibration listing, `CDP ?`

`CDP ?` answers **114 times, one data block (header 6x, with END) per talk request**. A reader that
stops after the first END sees only `CDP  001,…`.

```
send "CDP ?"
repeat 114 times:  talk (FE) until a 6x block arrives  ->  "CDP  001,+1.200000E-02" … "CDP  114,…"
```

- Letter after `CDP `: blank = OK, `E` = the three copies disagree (value unreliable), `N` on every
  line = calibration seal set to 'a'.
- Values carry 7 significant digits. A round trip through the firmware's own formatter and parser
  is within 0.47 ppm (about 1/100 of a display count).
- Each read takes a 2-of-3 vote and quietly repairs a single bad copy in RAM.

## Restore (only if the RAM is ever lost, untested)

1. Calibration enable: hold CAL, press and release RESET, release CAL (display shows CAL).
2. `CAL ON,0`
3. For each slot: `CDP n,value` (n = 1–114), e.g. `CDP 1,+1.200000E-02`. Each write goes to all
   three copies with new checksums. Values from a JCV dump are converted from the 4 raw bytes
   (format: byte 0 = sign + exponent (bias 62), bytes 1–3 = mantissa with explicit leading 1).
4. Settings separately: `IEE n` (GPIB address), `RMS n` (calibration mode), `CDP R` to set the
   seal to normal 'N'.
5. `CAL OFF` twice.

The seal: `CDP S` sets it to 'a' ("calibration altered": every range shows NC, `CDP ?` lines get
`N`); `CDP R` sets it back to 'N'. A plain `CDP n,value` does not touch it.

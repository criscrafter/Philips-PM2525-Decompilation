# PM2525 main firmware

## Primary target: S25 (dumped from a PM2525/3 meter; not included, put your own dump here)
- File: `PM2525_S25.BIN` (read with an XGecu programmer). Without it the tools rebuild it from `fw/reference/`.
- 32768 bytes (27256 EPROM), MD5 `a2f9121a0083f12b186cc1258656c072`, no mirrored halves, 188 × 0xFF (nearly full)
- CPU: Intel 8031AH (8051 family, external program memory)
- Reset vector: `00 00 00 02 51 FA`, i.e. NOP ×3 then LJMP 0x51FA. Timer-0 vector 0x000B → LJMP 0x534D
- Version string `PM25253 S25`, i.e. **PM2525/3 series, software S25**. Matches the 1993 PM2525/3 service manual
  (`../manuals/01_Service_Manual_1993.*`).
- Remote-command tokens present: `FNC`, `RNG`, `TRG`, `OUT`, `CAL`, `ON,0`/`ON,1`/`OFF`, `T.ONLY`, `AUTO`,
  plus new vs S08: `MTS`, `EP.0`.

## Reference: S08 (older, from KO4BB)
- `reference_S08/PM2525_S08_ko4bb.BIN` (original archive alongside), MD5 `c9ab3a0753d97f1b902fd00d2250253b`
- Version string `PM25250 S08` (original PM2525 series). Reset → LJMP 0x51E4, Timer-0 → LJMP 0x5337
- Same code base: the S25 entry points are shifted by +0x16. A function-level diff can help name routines
  and show what changed.

## Notes
- Interface boards (/51 GPIB, /61 RS232) have their own microcontrollers (probably mask ROM, not in these dumps).
  The meter talks to them over I²C (see `../manuals/03_GPIB_RS232_findings.md`).

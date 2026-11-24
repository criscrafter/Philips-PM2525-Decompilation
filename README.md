# Philips PM2525 multimeter firmware: decompilation and rebuildable source

A complete decompilation of the firmware of the Philips PM2525 digital multimeter: PM2525/3, software
version **S25**, Intel 8031 CPU, 32 KB 27C256 EPROM, battery-backed 6116 RAM. You can read it, change it
and build it back into an EPROM image.

- **Every routine is named and documented.** That is 492 functions, covering measurement and ranging,
  calibration, the remote command parser, the option-board (GPIB/RS232) link, the display and the
  keyboard.
- **Readable C for every subsystem.** [`src/`](src/README.md) has the generated C, and
  [`src/clean/`](src/clean) has hand-cleaned C. The clean C is checked against the original code
  running in an emulator: 4393 cases with no difference, and 721 out of 721 remote command lines.
- **Buildable source.** [`fw/`](fw/README.md) is a relocatable assembler source for SDCC that rebuilds
  the factory image **byte for byte**. You can edit it, and you can link C routines into it.
- **Notes.** [`DECOMPILATION.md`](DECOMPILATION.md) has the findings: hardware map, calibration
  storage and recipes, the remote command set, and the differences from the older S08.
  [`CALIBRATION_BACKUP.md`](CALIBRATION_BACKUP.md) explains how to back up a meter's calibration
  through the option bus.

## Branches

| Branch | Firmware it builds |
|---|---|
| `main` | **Unmodified.** `fw/pm2525.asm` builds an image identical to the factory S25 EPROM. |
| `optimized` | **Smaller, same behaviour.** Long jumps and calls are shortened wherever they reach, which frees 915 bytes of ROM (931 free instead of 40). It also shows how to link a routine written in C. Passes the same test suite. |

Start new modifications from `optimized` if you need ROM space, or from `main` if you want to stay
as close to the factory firmware as possible.

## Build and test

Requirements:
- Python 3.8+;
- [SDCC](https://sdcc.sourceforge.net/) 4.5 (sdas8051, sdld, sdcc). The tools look in
  `C:\Program Files\SDCC\bin`; set `SDCC_BIN` if yours is elsewhere.

```
python tools/test_fw.py
```

This builds `fw/out/pm2525.bin` and checks it against the original image. It then runs the emulator
test suites on that build and on a copy with all code moved to other addresses. `ALL TESTS PASSED`
means the logic behaves like the original. See [`fw/README.md`](fw/README.md) for the memory layout,
the rules for changes and how to call C.

The calibration constants live in the battery RAM, not in the EPROM, so swapping EPROMs does not
touch them. Still, burn modified images into a **spare** EPROM and keep the original.

## Not included

These files are not in the repository:
- **The factory EPROM images.** The tools use your own dump at `firmware/PM2525_S25.BIN` if present.
  Without it, they rebuild the original image from `fw/reference/pm2525_original.asm` (MD5
  `a2f9121a0083f12b186cc1258656c072`). The S08 reference image (`firmware/reference_S08/`) is
  available from the KO4BB manual archive.
- **The Philips manuals** (service and operator manuals, service notes). The notes refer to them as
  `manuals/01_…` to `manuals/05_…`. Only my own research notes (`manuals/03`, `06`, `07`) are included.
- **Meter RAM dumps.** The calibration tests use an empty RAM unless you put a dump in `backup/` or
  point `PM_RAM` at one.
- **Ghidra project and generated listings** (`out/`). `tools/run_all.ps1` regenerates them with
  Ghidra 12.2 headless (it needs the EPROM dump).

## Legal

The firmware is © Philips. This repository contains an analysis of it and source derived from it,
published for repair, preservation and interoperability of an instrument that has long been
discontinued. The original tools, scripts and documentation are under the MIT license
([LICENSE](LICENSE)).

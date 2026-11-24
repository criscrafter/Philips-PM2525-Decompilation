# PM2525 firmware source: modify and rebuild

This folder is the buildable source of the S25 firmware. It assembles and links with SDCC 4.5
(`C:\Program Files\SDCC`). C files are compiled into the firmware too. The source as generated rebuilds
**byte-identical** to `firmware/PM2525_S25.BIN` when built without the changes of this branch (as on `main`).

| Path | What |
|---|---|
| `pm2525.asm` | the firmware in assembly. All routines are named; all addresses are symbolic. **This is the source you edit.** |
| `c/*.c` | C routines linked into the firmware |
| `build.ini` | build options: `shrink = yes` builds through the optimizer |
| `c/pm2525_fw.h` | the firmware's SFRs, RAM variables and bits for C (generated: `python tools/make_c_header.py tools/s25.sym fw/c/pm2525_fw.h`) |
| `reference/pm2525_original.asm` | untouched generated source; builds to the original image |
| `out/pm2525.bin` | your build (optimized): burn this into a 27C256 |
| `out_ref/pm2525.bin` | the original, rebuilt from source (identical to the factory image) |

## Build and test

```powershell
python tools/test_fw.py
```

This builds `out/pm2525.bin` and tells you whether it is still identical to the original. It also builds
a copy with all code moved to other addresses, and runs the emulator test suites on both builds:

- 4393 cases of ranging, calibration data and recipes, query replies, reading output and calibration
  checks;
- 721 remote command lines.

`ALL TESTS PASSED` means the logic behaves like the original and nothing depends on a hard-coded
address. Just building is `python tools/build_fw.py`.

## This branch: optimized (`optimized`)

The build behaves like the original but is smaller. `build.ini` has `shrink = yes`, so
`python tools/test_fw.py` builds through `tools/shrink_fw.py`. That turns long jumps and calls into
short ones wherever they reach: **915 bytes freed, 931 free in all** (745 at the end of `CODE_A`,
185 at the end of `CODE_B`). Your source keeps the long forms.

It also contains one change written in C: `func_to_cmd_index` (current function → mnemonic, used
by `FNC?`, `RSL?` and every reading header) comes from `c/func_to_cmd_index.c` instead of assembly.
It passes all tests, and its register use and stack depth have been checked. Use it as the template
for your own C routines.

The unmodified firmware is on the `main` branch.

## Memory layout and rules

| Area | Address | Notes |
|---|---|---|
| `VECT` | 0x0000–0x002A fixed | reset and interrupt vectors |
| `CODE_A` | from 0x002B, must end before 0x6DAB | code; moves when you edit |
| `PINNED` | 0x6DAB–0x77B5 fixed | strings, float constants, calibration recipes. Many routines address it with separately loaded high/low bytes. **Do not insert, delete or move anything in it.** Changing bytes in place is fine. |
| `CODE_B` | from 0x77B6, must end before 0x8000 | remote parser and interface code |
| C code | placed automatically in the free gap after `CODE_A` or `CODE_B` | |
| C variables | XDATA 0x07A3–0x07FC (90 bytes) | unused by the original firmware |

- **ROM is almost full.** The original has 40 bytes free. A 27C512
  is not an option: on this board EPROM pin 1 is not wired to A15.
  - **Get about 900 bytes with the optimizer:** set `shrink = yes` in `build.ini` (or run
    `python tools/test_fw.py --shrink`). This builds `out/pm2525.bin` through `tools/shrink_fw.py`. It turns `ljmp`/`lcall` into
    `sjmp`/`ajmp`/`acall` wherever the target is close enough, and saves 1 byte for each one (915 now).
    The short forms take the same 2 machine cycles, so timing does not change. Your source keeps the
    long forms; the shrunk copy is written to `out_shrink/src/`.
  - Mark a line `; keep` if its size must not change. Jump tables, the `movc a,@a+pc` tables and
    `label±k` spans are protected automatically.
  - Otherwise, make room by rewriting or removing routines, or by deleting `FREE` lines.
  - The build stops with a clear message when something doesn't fit or areas overlap.
- **Internal RAM is full.** C code may not declare `__data`/`__idata` variables (the build refuses);
  use `__xdata`.
- **No startup code runs for C.** Initialised global variables are not set, and the build refuses
  them. Initialise in code.
- **Stack: 32 bytes** (SP starts at 0x60). The original already reaches about 25 bytes in the deepest
  tested paths. Keep C code shallow and don't call it from interrupt handlers.
- **Calling C from assembly.** SDCC code assumes register bank 0, may change R0–R7, B and DPTR,
  takes its first argument in DPL (DPH, B, A for wider ones) and returns 8-bit results in DPL. Use a few
  lines of glue that keep the original interface. The glue for `func_to_cmd_index` (end of `CODE_B`,
  C in `c/func_to_cmd_index.c`) is the template:
  ```
  func_to_cmd_index::
          push   sfr_PSW
          mov    sfr_PSW, #0x00         ; bank 0 for the C code
          push   0x06                   ; save what the C code changes (see its .lst)
          push   0x07
          push   sfr_DPL
          lcall  _c_func_to_cmd_index
          mov    a, sfr_DPL             ; result back in A, like the original
          pop    sfr_DPL
          pop    0x07
          pop    0x06
          pop    sfr_PSW
          ret
  ```
- **Timing.** Some routines are timing-critical:
  - the bit-banged I²C buses (option bus with your Pico, internal bus with the ADC interface and LCD);
  - the Timer 0/1 and INT1 interrupt handlers (frequency gate: the firmware corrects for about 25 µs
    of switching latency);
  - the P1.2 watchdog pulse.

  The emulator tests don't check timing, so keep changes away from these, or test them on the meter.
- **`movc a,@a+pc` tables** (2 places) read the bytes right after the instruction. Don't insert
  anything between them.

## Typical workflow

1. Edit `pm2525.asm` (or add `c/new.c` plus glue, and delete the assembly routine it replaces).
2. `python tools/test_fw.py`. Add a test to `tools/check_clean.py` if your change has new behaviour.
3. Burn `out/pm2525.bin` into a **spare** 27C256 and keep the original EPROM. The calibration lives
   in the battery RAM, not the EPROM, so swapping EPROMs does not touch it. Meter 1's RAM is also
   backed up in `backup/`.

## How the source was made

`tools/make_asm.py` generated `pm2525.asm` once from the image and `tools/s25.sym`. It refuses to
overwrite an existing file, because that would discard your edits.

How the generator made the source relocatable:
- It traces all code, including 42 small unreferenced fragments, so their addresses are symbolic too.
- It makes every `LJMP`/`LCALL`/branch target and every `MOV DPTR,#` into code symbolic. A table base
  that points just before a table becomes `label-k`.
- It decides `MOV DPTR,#` values below 0x0800 by how they are used: `MOVC` means ROM, otherwise XDATA.
- It writes the 41 recipe pointers in `PINNED` that point into `pow10_table` (which moves with
  `CODE_A`) as `.dw` symbols.

The relocation was proven by the moved test layout passing the full test suite.

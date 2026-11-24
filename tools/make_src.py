#!/usr/bin/env python3
"""Build the src/ tree: Ghidra C output split into one file per subsystem, with a shared header.

Usage: python make_src.py out/PM2525_S25_ghidra.c tools/s25.sym src/

- Functions are assigned to modules by name prefix (MODULES below), unmatched ones by address range.
- Raw Ghidra artefacts are renamed: DAT_INTMEM_xx -> ram_XX, DAT_EXTMEM_xxxx -> xram_XXXX,
  _X_Y (bit Y of byte 0x2X) -> bit_2X_Y, undefinedN -> uintN_t, known bank registers -> names.
- Each function gets its address, size and the comment from s25.sym.
- Hand-cleaned replacements in src/clean/<module>.c are listed in the module header (not overwritten).
"""
import os
import re
import sys
from collections import OrderedDict

MODULE_LIST = [
    ("main.c", "boot, main loop, interrupt handlers, task dispatch",
     ("start", "reset_vector", "main_loop", "system_init", "isr_", "vec_", "task_", "iface_boot", "read_option")),
    ("i2c.c", "bit-banged I2C buses: A = option bus (P1.1/P3.2), B = internal bus (P1.7/P3.5)",
     ("i2cA_", "i2cB_", "i2c_both")),
    ("iface_link.c", "option-board link (Pico/UR488 side): framing, events, status, channels",
     ("iface_",)),
    ("remote_parser.c", "character-level parser for remote commands",
     ("parser_", "rx_")),
    ("remote_commands.c", "command execution shared by keyboard and remote, query replies",
     ("cmd_", "fnsel_", "reply_", "jcv_", "cdp_", "rms_", "emo_", "tol_", "iee_", "rtl_", "dbm_", "zer_",
      "func_to_cmd", "key_range", "key_auto", "cmd_param", "cmd_fnc")),
    ("calibration.c", "calibration storage (3 copies), recipes, coefficients, calibration run",
     ("cal_", "cnt_", "sum16_", "internal_temp", "temp_in_range")),
    ("settings.c", "triple-redundant settings bytes: GPIB address, talk-only, 50/60 Hz, CR, seal, speed",
     ("nv_", "mains_", "cr_", "speed_")),
    ("measure.c", "measurement state machine, ADC interface, timing functions, ranging, result processing",
     ("meas_", "adc_", "acq_", "autorange", "range_", "result_", "count_", "value_", "time_", "cap_",
      "freq_", "pt100", "input_step", "display_stabilize", "filter_", "vpp_", "minmax_", "min_", "max_",
      "hold_", "funcswitch", "shiftreg", "analog_", "timer0_", "timer1_", "diag_", "trigger_", "fast_mode",
      "ac_autozero", "db_", "digits_for")),
    ("display.c", "LCD text formatting, font, annunciators, messages",
     ("lcd_", "display_", "out_format", "resolution_", "nc_display", "func_class")),
    ("keyboard_menu.c", "key matrix, key handlers, SHIFT/CHECK edit menus, data-hold probe",
     ("key_", "kbd_", "menu_", "probe_", "put_2digits", "code_to_iram", "func_change", "func_is")),
    ("lib_math.c", "float (sign+exp bias 62, 24-bit mantissa) and 24-bit integer library",
     ("fp_", "i24_", "mant_", "add16", "shl16", "clc_", "ret_")),
    ("lib_util.c", "memory, DPTR, text and number conversion helpers",
     ("dptr_", "xdata_", "iram_", "put_", "parse_number", "is_digit", "sum16")),
]
MODULES = OrderedDict((f, (d, p)) for f, d, p in MODULE_LIST)

BANKREG = {"BANK1_R3": "reply_len", "BANK3_R5": "iface_chan_hi", "BANK3_R6": "iface_chan_lo",
           "BANK0_R0": "R0", "BANK0_R1": "R1", "BANK0_R2": "R2", "BANK0_R3": "R3",
           "BANK0_R4": "R4", "BANK0_R5": "R5", "BANK0_R6": "R6", "BANK0_R7": "R7"}


def load_sym(path):
    code, var = {}, []
    for line in open(path, encoding="utf-8"):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        body, _, cm = line.partition("#")
        f = body.split()
        if len(f) < 3:
            continue
        kind, addr, name = f[0], int(f[1], 16), f[2]
        if kind == "code":
            code[name] = (addr, cm.strip())
        elif kind in ("data", "bit", "xdata"):
            var.append((kind, addr, name, cm.strip()))
    return code, var


def split_functions(text):
    parts = re.split(r"\n// =+\n", text)
    funcs = []
    for p in parts:
        m = re.search(r"// (\S+) @ CODE:([0-9a-f]+)\s+\((\d+) bytes\)", p)
        if not m:
            continue
        body = p[m.end():].strip("\n")
        funcs.append((m.group(1), int(m.group(2), 16), int(m.group(3)), body))
    return funcs


def clean(body):
    body = re.sub(r"\bDAT_INTMEM_([0-9a-f]{2})\b", lambda m: "ram_%s" % m.group(1).upper(), body)
    body = re.sub(r"\bDAT_EXTMEM_([0-9a-f]{4})\b", lambda m: "xram_%s" % m.group(1).upper(), body)
    body = re.sub(r"\bDAT_CODE_([0-9a-f]{4})\b", lambda m: "rom_%s" % m.group(1).upper(), body)
    body = re.sub(r"(?<![\w])_([0-9a-f])_([0-7])\b", lambda m: "bit_2%s_%s" % (m.group(1).upper(), m.group(2)), body)
    for k, v in BANKREG.items():
        body = re.sub(r"\b%s\b" % k, v, body)
    body = re.sub(r"\bundefined1\b", "uint8_t", body)
    body = re.sub(r"\bundefined2\b", "uint16_t", body)
    body = re.sub(r"\bundefined4\b", "uint32_t", body)
    body = re.sub(r"\bundefined\b", "uint8_t", body)
    body = re.sub(r"\bushort\b", "uint16_t", body)
    body = re.sub(r"\bbyte\b", "uint8_t", body)
    body = re.sub(r"\n{3,}", "\n\n", body)
    return body


OVERRIDE = {"task_display_menu": "keyboard_menu.c", "task_keyboard": "keyboard_menu.c",
            "task_measure": "measure.c", "task_trigger": "measure.c", "task_display_update": "display.c",
            "task_remote_parse": "remote_parser.c", "task_remote_parse_tail": "remote_parser.c",
            "task_remote_reply": "remote_commands.c"}


def module_for(name, addr):
    if name in OVERRIDE:
        return OVERRIDE[name]
    for fname, desc, prefixes in MODULE_LIST:
        if name.startswith(prefixes):
            return fname
    for lo, hi, fname in ADDR_FALLBACK:
        if lo <= addr < hi:
            return fname
    return "misc.c"


ADDR_FALLBACK = [(0x0000, 0x0111, "main.c"), (0x0111, 0x1009, "calibration.c"), (0x1009, 0x2AA9, "measure.c"),
                 (0x2AA9, 0x3D00, "keyboard_menu.c"), (0x3D00, 0x4814, "remote_commands.c"),
                 (0x4814, 0x51FA, "remote_commands.c"), (0x51FA, 0x5549, "main.c"), (0x5549, 0x5934, "display.c"),
                 (0x5934, 0x5D00, "keyboard_menu.c"), (0x5D00, 0x5E1A, "iface_link.c"), (0x5E1A, 0x6E00, "lib_math.c"),
                 (0x77B6, 0x7BDA, "remote_parser.c"), (0x7BDA, 0x8000, "iface_link.c")]


def main():
    src, sym, outdir = sys.argv[1:4]
    os.makedirs(outdir, exist_ok=True)
    code, var = load_sym(sym)
    funcs = split_functions(open(src, encoding="utf-8").read())
    mods = {k: [] for k in list(MODULES) + ["misc.c"]}
    for name, addr, size, body in funcs:
        mods[module_for(name, addr)].append((addr, name, size, body))
    # header
    h = ["/* pm2525.h - shared declarations for the decompiled PM2525 S25 firmware (generated by tools/make_src.py)",
         " *",
         " * Memory: IRAM (ram_XX / named), bit space (bit_2X_Y = bit Y of IRAM 0x2X / named), XDATA (xram_XXXX / named,",
         " * the battery-backed 6116 at 0x0000-0x07FF), ROM tables (rom_XXXX).",
         " * NOTE: IRAM 0x2A-0x37 (and bits 2Ah.0-2Fh.7, 0x50-0x7F) is a per-task context area. Each task swaps its own",
         " * 13-14 bytes in and out (measurement: XDATA 0x00BE, parser: 0x00DB, menu: 0x00A5, ...), so ram_2A..ram_37",
         " * and bit_2A_..bit_2F_ mean different things in different modules.",
         " * Floats: 4 bytes, byte0 = sign | exponent (bias 62), bytes1-3 = mantissa with explicit leading 1;",
         " * in IRAM the exponent byte is at the highest address and routines get a pointer to it (R0/R1).",
         " */",
         "#ifndef PM2525_H", "#define PM2525_H", "#include <stdint.h>", "",
         "#define CONCAT11(hi, lo) ((uint16_t)(((uint16_t)(hi) << 8) | (uint8_t)(lo)))",
         "#define CARRY1(a, b) ((uint8_t)((uint8_t)(a) + (uint8_t)(b)) < (uint8_t)(a))", "",
         "/* ---- IRAM variables ---- */"]
    for kind, addr, name, cm in sorted(var, key=lambda v: (v[0], v[1])):
        if kind == "data":
            h.append("extern uint8_t %-24s /* IRAM 0x%02X %s */" % (name + ";", addr, cm))
    h.append("\n/* ---- bit variables ---- */")
    for kind, addr, name, cm in sorted(var, key=lambda v: v[1]):
        if kind == "bit":
            byte = 0x20 + (addr >> 3) if addr < 0x80 else addr & 0xF8
            h.append("extern uint8_t %-24s /* bit 0x%02X = %02Xh.%d %s */" % (name + ";", addr, byte, addr & 7, cm))
    h.append("\n/* ---- XDATA variables (battery-backed RAM) ---- */")
    for kind, addr, name, cm in sorted(var, key=lambda v: v[1]):
        if kind == "xdata":
            h.append("extern uint8_t %-24s /* XDATA 0x%04X %s */" % (name + ";", addr, cm))
    h.append("\n/* ---- functions ---- */")
    for mod in mods:
        for addr, name, size, body in sorted(mods[mod]):
            m = re.search(r"^([^\n{]*\b%s\s*\([^)]*\))" % re.escape(name), body, re.M)
            if m:
                h.append("%s; /* %04X %s */" % (clean(m.group(1)).strip(), addr, mod))
    h += ["", "#endif"]
    open(os.path.join(outdir, "pm2525.h"), "w", encoding="utf-8").write("\n".join(h) + "\n")
    # modules
    index = []
    for mod, items in mods.items():
        if not items:
            continue
        desc = MODULES[mod][0] if mod in MODULES else "functions not yet assigned to a subsystem"
        total = sum(s for _, _, s, _ in items)
        lines = ["/* %s - %s" % (mod, desc),
                 " * Generated from the Ghidra 12.2 decompilation by tools/make_src.py; names from tools/s25.sym.",
                 " * %d functions, %d bytes of 8051 code. Addresses refer to PM2525_S25.BIN." % (len(items), total)]
        cleaned = os.path.join(outdir, "clean", mod)
        if os.path.exists(cleaned):
            lines.append(" * A hand-cleaned version of this module is in clean/%s." % mod)
        lines += [" */", '#include "pm2525.h"', ""]
        for addr, name, size, body in sorted(items):
            cm = code.get(name, (None, ""))[1]
            lines.append("/* ---- %s  @0x%04X  (%d bytes)%s */" % (name, addr, size, ("\n *      " + cm) if cm else ""))
            lines.append(clean(body))
            lines.append("")
        open(os.path.join(outdir, mod), "w", encoding="utf-8").write("\n".join(lines) + "\n")
        index.append((mod, desc, len(items), total))
    with open(os.path.join(outdir, "README.md"), "w", encoding="utf-8") as w:
        w.write("# PM2525 S25 decompiled source\n\nGenerated by `tools/make_src.py` from the Ghidra output "
                "(`tools/run_all.ps1` rebuilds it). One file per subsystem; `pm2525.h` declares every named variable.\n"
                "Hand-cleaned modules live in `clean/`.\n\n| File | Subsystem | Functions | Bytes |\n|---|---|---|---|\n")
        for mod, desc, n, tot in index:
            w.write("| [`%s`](%s) | %s | %d | %d |\n" % (mod, mod, desc, n, tot))
    for mod, desc, n, tot in index:
        print("%-20s %3d functions %6d bytes" % (mod, n, tot))


if __name__ == "__main__":
    main()

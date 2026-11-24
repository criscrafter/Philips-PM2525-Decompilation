#!/usr/bin/env python3
"""Build fw/ and test the result in the emulator.

Usage: python tools/test_fw.py [--quick] [--shrink | --no-shrink]

1. builds fw/pm2525.asm (+ fw/c/*.c) into fw/out/pm2525.bin and reports whether it is identical
   to the original image;
2. builds the same source in the relocation test layout (CODE_A at 0x8100, CODE_B at 0xF000,
   nothing left at the old places), so a hard-coded address anywhere shows up as a failure;
3. runs tools/check_clean.py (4393 cases) and tools/check_parser.py (721 command lines) against
   both builds. Routines are found by label name, so the tests follow code that moved.
Exit code 0 = everything passed. --quick runs only the normal build's tests. --shrink builds
fw/out/pm2525.bin with tools/shrink_fw.py (short jumps/calls, ~900 bytes smaller) instead.
The default comes from `shrink = yes/no` in fw/build.ini.

The tests cover the logic that can be emulated (ranging, calibration data, recipes, remote
command parsing and replies, reading output, calibration step checks). They do not cover timing
or the peripherals (motor switch, ADC, LCD, I2C devices): test those on the meter.
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fwpaths import original_image, ram_dump  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PY = [sys.executable, "-I"]
T = lambda *p: os.path.join(ROOT, *p)


def run(cmd, env=None, label=None):
    e = dict(os.environ)
    e.update(env or {})
    r = subprocess.run(cmd, capture_output=True, text=True, env=e, cwd=ROOT)
    out = (r.stdout + r.stderr).strip()
    return r.returncode, out


def tests(exec_bin, map_file, name):
    env = {"PM_EXEC": exec_bin}
    if map_file:
        env["PM_MAP"] = map_file
    ok = True
    ram = ram_dump()
    rc, out = run(PY + [T("tools", "check_clean.py"), original_image()] + ([ram] if ram else []), env)
    last = [l for l in out.splitlines() if l.startswith("TOTAL")]
    print("  %-22s check_clean : %s" % (name, last[0] if last else "FAILED\n" + out[-2000:]))
    ok &= rc == 0 and bool(last) and last[0].endswith(" 0 differ")
    rc, out = run(PY + [T("tools", "check_parser.py"), original_image()], env)
    last = out.splitlines()[-1] if out else "FAILED"
    print("  %-22s check_parser: %s" % (name, last))
    ok &= rc == 0 and last.endswith(" 0 differ")
    return ok


def main():
    quick = "--quick" in sys.argv
    shrink = False
    ini = T("fw", "build.ini")
    if os.path.exists(ini):
        import configparser
        cp = configparser.ConfigParser()
        cp.read(ini)
        shrink = cp.getboolean("build", "shrink", fallback=False)
    shrink = (shrink or "--shrink" in sys.argv) and "--no-shrink" not in sys.argv
    orig = original_image()             # also builds fw/out_ref (the label map the tests use)
    if not os.path.exists(T("fw", "out_ref", "pm2525.map")):
        rc, out = run(PY + [T("tools", "build_fw.py"), "--asm", T("fw", "reference", "pm2525_original.asm"),
                            "--out", T("fw", "out_ref"), "--ref", ""])
        if rc:
            sys.exit(out)
    print("original image: %s; RAM for the calibration tests: %s" % (
        os.path.relpath(orig, ROOT), os.path.relpath(ram_dump(), ROOT) if ram_dump() else "empty (no dump)"))
    rc, out = run(PY + [T("tools", "shrink_fw.py" if shrink else "build_fw.py"), "--ref", orig])
    if shrink:
        out = chr(10).join(l for l in out.splitlines() if not l.startswith("pass "))
    print(out)
    if rc:
        sys.exit("build failed")
    ok = tests(T("fw", "out", "pm2525.bin"), T("fw", "out", "pm2525.map"), "normal build")
    if not quick:
        rc, out = run(PY + [T("tools", "build_fw.py"), "--test-layout", "--out", T("fw", "out_tl"), "--ref", ""])
        if rc:
            sys.exit(out)
        ok &= tests(T("fw", "out_tl", "pm2525.bin"), T("fw", "out_tl", "pm2525.map"), "moved (test layout)")
    print("ALL TESTS PASSED" if ok else "SOME TESTS FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()

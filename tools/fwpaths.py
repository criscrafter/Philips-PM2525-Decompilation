"""Where the build and the tests find the original image and a RAM dump.

The factory EPROM image is not part of the repository. If firmware/PM2525_S25.BIN is present
(your own dump) it is used; otherwise the original is rebuilt from fw/reference/pm2525_original.asm,
which is byte-identical to it (MD5 a2f9121a0083f12b186cc1258656c072).
"""
import hashlib
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
S25_MD5 = "a2f9121a0083f12b186cc1258656c072"


def original_image():
    dump = os.path.join(ROOT, "firmware", "PM2525_S25.BIN")
    if os.path.exists(dump):
        return dump
    ref = os.path.join(ROOT, "fw", "out_ref", "pm2525.bin")
    if not os.path.exists(os.path.join(ROOT, "fw", "out_ref", "pm2525.map")):
        r = subprocess.run([sys.executable, "-I", os.path.join(ROOT, "tools", "build_fw.py"), "--asm",
                            os.path.join(ROOT, "fw", "reference", "pm2525_original.asm"),
                            "--out", os.path.join(ROOT, "fw", "out_ref"), "--ref", ""],
                           capture_output=True, text=True)
        if r.returncode:
            sys.exit("could not build the reference image:\n" + r.stdout + r.stderr)
    if hashlib.md5(open(ref, "rb").read()).hexdigest() != S25_MD5:
        sys.exit("fw/out_ref/pm2525.bin is not the original S25 image")
    return ref


def ram_dump():
    """a 2 KB battery-RAM dump for the calibration tests, or None (the tests then use an empty RAM)"""
    p = os.environ.get("PM_RAM") or os.path.join(ROOT, "backup", "meter_COM20_2026-11-24_ram.bin")
    return p if os.path.exists(p) else None

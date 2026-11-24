# Decompiles the firmware: regenerates out\ (disassembly, tables, Ghidra C) and src\*.c from the
# EPROM image and the symbol files (tools\s25.sym, tools\s08.sym).
#
#   powershell -ExecutionPolicy Bypass -File tools\run_all.ps1
#
# Needs: Python 3, Ghidra 12.x and a JDK 21+.
#   - GHIDRA_HOME: Ghidra folder (contains support\analyzeHeadless.bat)
#   - JAVA_HOME:   JDK folder
# If they are not set, the script looks for ghidra_12* and jdk-2* folders in ..\tools (next to this
# repository's folder).
# Input: firmware\PM2525_S25.BIN (your dump; if absent it is rebuilt from fw\reference).
# Optional: firmware\reference_S08\PM2525_S08_ko4bb.BIN for the S08 comparison.
$ErrorActionPreference = "Stop"
$p     = Split-Path -Parent $PSScriptRoot          # repository root
$tools = Join-Path (Split-Path -Parent $p) "tools" # ..\tools
Set-Location $p
New-Item -ItemType Directory -Force "$p\out", "$p\ghidra_project" | Out-Null

$s25 = "$p\firmware\PM2525_S25.BIN"
if (-not (Test-Path $s25)) {
    $s25 = (python -I -c "import sys; sys.path.insert(0, 'tools'); from fwpaths import original_image; print(original_image())").Trim()
    Write-Host "no firmware dump, using the image rebuilt from source: $s25"
}
$s08 = "$p\firmware\reference_S08\PM2525_S08_ko4bb.BIN"

python -I tools/dis8051.py $s25 --sym tools/s25.sym -o out/PM2525_S25.asm --json out/PM2525_S25.json
python -I tools/profile_funcs.py $s25 tools/s25.sym out/s25_profile.txt
if (Test-Path $s08) {
    python -I tools/dis8051.py $s08 --sym tools/s08.sym -o out/PM2525_S08.asm --json out/PM2525_S08.json
    python -I tools/match_versions.py $s25 tools/s25.sym $s08 tools/s08.sym out/match_s25_s08 | Out-Null
    python -I tools/diff_report.py out/match_s25_s08.csv $s25 tools/s25.sym $s08 tools/s08.sym out/S08_vs_S25_diff.md
} else {
    Write-Host "no S08 image: skipping the S08 comparison"
}
python -I tools/range_table.py $s25 out/range_table.md
python -I tools/cal_recipes.py $s25 out/cal_recipes.md
python -I tools/analog_table.py $s25 out/analog_table.md
python -I tools/make_seeds.py out/PM2525_S25.json tools/s25.sym out/s25_seeds.txt

$ghidra = $env:GHIDRA_HOME
if (-not $ghidra) { $ghidra = (Get-ChildItem "$tools" -Directory -Filter "ghidra_12*" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName }
if (-not $env:JAVA_HOME) { $env:JAVA_HOME = (Get-ChildItem "$tools" -Directory -Filter "jdk-2*" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName }
if (-not $ghidra -or -not (Test-Path "$ghidra\support\analyzeHeadless.bat")) { throw "Ghidra not found: set GHIDRA_HOME" }
if (-not $env:JAVA_HOME) { throw "JDK not found: set JAVA_HOME" }
$env:_JAVA_OPTIONS = $null
Write-Host "Ghidra: $ghidra  JDK: $env:JAVA_HOME  (takes a few minutes)"
& "$ghidra\support\analyzeHeadless.bat" "$p\ghidra_project" PM2525 -import $s25 -overwrite `
    -loader BinaryLoader -processor "8051:BE:16:default" -scriptPath "$p\tools\ghidra_scripts" `
    -preScript SeedFunctions.java "$p\out\s25_seeds.txt" `
    -postScript ApplyLabels.java "$p\out\s25_seeds.txt" `
    -postScript DecompileAll.java "$p\out\PM2525_S25_ghidra.c" *> "$p\out\ghidra_headless_s25.log"
Get-Content "$p\out\ghidra_headless_s25.log" | Select-String -Pattern "Seeded|Applied|Decompiled|ERROR"
if (-not (Test-Path "$p\out\PM2525_S25_ghidra.c")) { throw "Ghidra produced no output: see out\ghidra_headless_s25.log" }
python -I tools/make_src.py out/PM2525_S25_ghidra.c tools/s25.sym src
Write-Host "done: Ghidra C in out\PM2525_S25_ghidra.c, per-subsystem C in src\"

# Rebuilds every output in ..\out from the firmware images and symbol files.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File tools\run_all.ps1
$ErrorActionPreference = "Stop"
$p     = Split-Path -Parent $PSScriptRoot          # PM2525_Decompile
$tools = Join-Path (Split-Path -Parent $p) "tools" # ..\tools (Ghidra, JDK)
$s25   = "$p\firmware\PM2525_S25.BIN"
$s08   = "$p\firmware\reference_S08\PM2525_S08_ko4bb.BIN"
Set-Location $p

python -I tools/dis8051.py $s25 --sym tools/s25.sym -o out/PM2525_S25.asm --json out/PM2525_S25.json
python -I tools/dis8051.py $s08 --sym tools/s08.sym -o out/PM2525_S08.asm --json out/PM2525_S08.json
python -I tools/profile_funcs.py $s25 tools/s25.sym out/s25_profile.txt
python -I tools/match_versions.py $s25 tools/s25.sym $s08 tools/s08.sym out/match_s25_s08 | Out-Null
python -I tools/diff_report.py out/match_s25_s08.csv $s25 tools/s25.sym $s08 tools/s08.sym out/S08_vs_S25_diff.md
python -I tools/range_table.py $s25 out/range_table.md
python -I tools/cal_recipes.py $s25 out/cal_recipes.md
python -I tools/analog_table.py $s25 out/analog_table.md
python -I tools/make_seeds.py out/PM2525_S25.json tools/s25.sym out/s25_seeds.txt

$env:JAVA_HOME = (Get-ChildItem "$tools" -Directory -Filter "jdk-25*" | Select-Object -First 1).FullName
$env:_JAVA_OPTIONS = $null
$ghidra = (Get-ChildItem "$tools" -Directory -Filter "ghidra_12*" | Select-Object -First 1).FullName
& "$ghidra\support\analyzeHeadless.bat" "$p\ghidra_project" PM2525 -import $s25 -overwrite `
    -loader BinaryLoader -processor "8051:BE:16:default" -scriptPath "$p\tools\ghidra_scripts" `
    -preScript SeedFunctions.java "$p\out\s25_seeds.txt" `
    -postScript ApplyLabels.java "$p\out\s25_seeds.txt" `
    -postScript DecompileAll.java "$p\out\PM2525_S25_ghidra.c" *> "$p\out\ghidra_headless_s25.log"
Get-Content "$p\out\ghidra_headless_s25.log" | Select-String -Pattern "Seeded|Applied|Decompiled|ERROR"
python -I tools/make_src.py out/PM2525_S25_ghidra.c tools/s25.sym src

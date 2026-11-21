# Build single-file PoloskaLib.lua from modular src/ using darklua.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$darklua = Get-Command darklua -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $darklua) {
    $parentBundled = Join-Path $root "../tools/darklua/darklua.exe"
    if (Test-Path $parentBundled) {
        $darklua = (Resolve-Path $parentBundled).Path
    }
}
if (-not $darklua) {
    throw "darklua not found in PATH or ../tools/darklua/darklua.exe"
}

$config = Join-Path $root ".darklua.json"
$entry = Join-Path $root "src/init.luau"
$out = Join-Path $root "PoloskaLib.lua"

& $darklua process $entry $out --config $config
if ($LASTEXITCODE -ne 0) {
    throw "darklua build failed with exit code $LASTEXITCODE"
}

$size = (Get-Item $out).Length
$lines = (Get-Content $out | Measure-Object -Line).Lines
Write-Host "Built PoloskaLib.lua ($size bytes, $lines lines)"

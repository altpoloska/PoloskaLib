# Pure PowerShell bundler: assembles PoloskaLib.lua directly from src/*.luau
# with zero external dependencies (no darklua, no Node, no Python).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcDir = Join-Path $root "src"
$outFile = Join-Path $root "PoloskaLib.lua"

$modules = Get-ChildItem -Path $srcDir -Filter "*.luau" | Sort-Object {
    if ($_.BaseName -eq "init") { "zzz_init" } else { $_.BaseName }
}
if ($modules.Count -eq 0) {
    throw "No .luau modules found in $srcDir"
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("--!nonstrict")
[void]$sb.AppendLine("-- PoloskaLib v2 (bundled from src/*.luau via build.ps1)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("local __POLOSKALIB = { cache = {}, loaders = {} }")
[void]$sb.AppendLine("local function __poloska_require(path)")
[void]$sb.AppendLine('	local name = tostring(path):gsub("^%./", ""):gsub("%.luau$", ""):gsub("%.lua$", "")')
[void]$sb.AppendLine("	local cached = __POLOSKALIB.cache[name]")
[void]$sb.AppendLine("	if cached ~= nil then")
[void]$sb.AppendLine("		return cached")
[void]$sb.AppendLine("	end")
[void]$sb.AppendLine("	local loader = __POLOSKALIB.loaders[name]")
[void]$sb.AppendLine("	if not loader then")
[void]$sb.AppendLine('		error("PoloskaLib: missing module: " .. name)')
[void]$sb.AppendLine("	end")
[void]$sb.AppendLine("	local result = loader()")
[void]$sb.AppendLine("	__POLOSKALIB.cache[name] = result")
[void]$sb.AppendLine("	return result")
[void]$sb.AppendLine("end")
[void]$sb.AppendLine("")

foreach ($file in $modules) {
    $name = $file.BaseName
    $raw = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $raw = $raw -replace "^\uFEFF", ""
    $raw = $raw -replace "`r`n", "`n"
    $raw = [regex]::Replace($raw, "(?m)^--!(?:strict|nonstrict|nolint)\s*`n?", "")
    $raw = [regex]::Replace($raw, "(?m)^(\s*)export\s+type\b", '$1type')

    [void]$sb.AppendLine("__POLOSKALIB.loaders[`"$name`"] = function()")
    [void]$sb.AppendLine("	local require = __poloska_require")
    [void]$sb.AppendLine($raw.TrimEnd())
    [void]$sb.AppendLine("end")
    [void]$sb.AppendLine("")
}

[void]$sb.AppendLine('return __poloska_require("./init")')

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($outFile, $sb.ToString(), $utf8NoBom)

$size = (Get-Item $outFile).Length
$lines = (Get-Content $outFile | Measure-Object -Line).Lines
Write-Host "Built PoloskaLib.lua from $($modules.Count) modules ($size bytes, $lines lines)"

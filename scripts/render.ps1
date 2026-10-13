<#
  render.ps1 — HTML -> PDF via headless Chrome/Chromium on Windows.

      powershell -ExecutionPolicy Bypass -File scripts\render.ps1 <input.html> <output.pdf>

  Native-Windows alternative to scripts/render.sh, for people who are not using
  WSL. It passes the same Chrome flags as render.sh (including the mandatory
  --no-pdf-header-footer), so the PDF it produces verifies identically:

      python scripts\verify_pdf.py <output.pdf> --pages 2

  If you already have WSL, prefer running scripts/render.sh inside WSL instead —
  that is the environment the rest of the kit, and most AI coding agents, expect.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)][string]$In,
  [Parameter(Mandatory = $true, Position = 1)][string]$Out
)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message, [int]$Code) {
  [Console]::Error.WriteLine($Message)
  exit $Code
}

if (-not (Test-Path -LiteralPath $In -PathType Leaf)) {
  Fail "error: no such file: $In" 66
}

function Find-Chrome {
  if ($env:CHROME_BIN) {
    if (Test-Path -LiteralPath $env:CHROME_BIN) { return $env:CHROME_BIN }
    [Console]::Error.WriteLine("warning: CHROME_BIN=$env:CHROME_BIN does not exist; auto-detecting.")
  }
  $candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    "$env:ProgramFiles\Chromium\Application\chrome.exe"
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
  )
  foreach ($c in $candidates) {
    if ($c -and (Test-Path -LiteralPath $c)) { return $c }
  }
  foreach ($name in @('chrome', 'chromium', 'msedge')) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
  }
  return $null
}

$chrome = Find-Chrome
if (-not $chrome) {
  Fail @'
error: no Chrome, Chromium, or Edge found.

  install Google Chrome:  https://www.google.com/chrome/
  OR point at an existing binary and re-run:

      $env:CHROME_BIN = "C:\path\to\chrome.exe"
      powershell -ExecutionPolicy Bypass -File scripts\render.ps1 <input.html> <output.pdf>

  OR, if you have WSL, run the bash renderer there:  scripts/render.sh <in> <out>
'@ 69
}

# Resolve to absolute paths. Chrome needs a real file:// URL and will silently
# write nothing if the output directory does not exist.
$inFull  = (Resolve-Path -LiteralPath $In).Path
$outFull = [System.IO.Path]::GetFullPath($Out)
$outDir  = Split-Path -Parent $outFull
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
$inUrl = ([System.Uri]$inFull).AbsoluteUri

& $chrome --headless --disable-gpu --no-pdf-header-footer `
  --virtual-time-budget=5000 "--print-to-pdf=$outFull" $inUrl 2>$null | Out-Null

if (-not (Test-Path -LiteralPath $outFull)) {
  Fail "error: Chrome produced no output for $In" 70
}

Write-Host "rendered: $outFull"
Write-Host "next:     python scripts\verify_pdf.py `"$outFull`""
exit 0

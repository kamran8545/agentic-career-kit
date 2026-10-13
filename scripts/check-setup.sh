#!/usr/bin/env bash
# check-setup.sh — tell a user, before they try to build anything, whether this
# machine can run the pipeline and exactly what to do about anything missing.
#
#   scripts/check-setup.sh
#
# Exits 0 if the machine is ready, 1 if something essential is missing. Safe to
# run any time; it changes nothing.

set -uo pipefail

# --------------------------------------------------------------- OS detection
UNAME="$(uname -s 2>/dev/null || echo unknown)"
PLATFORM="$UNAME"
IS_WSL=0
IS_WINDOWS=0
case "$UNAME" in
  Darwin) PLATFORM="macOS" ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      IS_WSL=1; PLATFORM="Linux (WSL)"
    else
      PLATFORM="Linux"
    fi ;;
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1; PLATFORM="Windows (Git Bash/Cygwin)" ;;
esac

ok()   { printf '  ok    %s\n' "$1"; }
bad()  { printf '  MISSING  %s\n' "$1"; }

echo "=== agentic-career-kit setup check ==="
echo "platform   $PLATFORM"
echo

MISSING=0

# --------------------------------------------------------------- 1. Chrome/Chromium
echo "-- browser (renders HTML to PDF)"
CHROME=""
if [ -n "${CHROME_BIN:-}" ]; then
  if [ -x "$CHROME_BIN" ]; then
    CHROME="$CHROME_BIN"
  else
    echo "  note  CHROME_BIN=$CHROME_BIN is not executable; auto-detecting"
  fi
fi
if [ -z "$CHROME" ]; then
  for c in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/c/Program Files/Google/Chrome/Application/chrome.exe" \
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
    "$(command -v google-chrome 2>/dev/null || true)" \
    "$(command -v google-chrome-stable 2>/dev/null || true)" \
    "$(command -v chromium 2>/dev/null || true)" \
    "$(command -v chromium-browser 2>/dev/null || true)" \
    "$(command -v microsoft-edge 2>/dev/null || true)"; do
    [ -n "$c" ] && [ -x "$c" ] && { CHROME="$c"; break; }
  done
fi
if [ -n "$CHROME" ]; then
  ok "found: $CHROME"
else
  bad "no Chrome, Chromium, or Edge found"
  case "$PLATFORM" in
    "macOS") echo "        fix: install Google Chrome — https://www.google.com/chrome/" ;;
    Linux*)  echo "        fix: sudo apt install chromium-browser   (or install Google Chrome)" ;;
    *)       echo "        fix: install Google Chrome — https://www.google.com/chrome/" ;;
  esac
  echo "        or:  set an explicit path:  CHROME_BIN=/path/to/chrome scripts/render.sh in.html out.pdf"
  MISSING=1
fi
echo

# ------------------------------------------------------------------- 2. Python 3
echo "-- python 3"
PY=""
for cand in python3 python; do
  p="$(command -v "$cand" 2>/dev/null || true)"
  if [ -n "$p" ] && "$p" -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)' 2>/dev/null; then
    PY="$p"; break
  fi
done
if [ -z "$PY" ] && command -v py >/dev/null 2>&1 && py -3 -c 'import sys' 2>/dev/null; then
  PY="py -3"
fi
if [ -n "$PY" ]; then
  ok "found: $PY ($($PY --version 2>&1))"
else
  bad "no Python 3 interpreter found"
  echo "        fix: install Python 3 — https://www.python.org/downloads/"
  MISSING=1
fi
echo

# ---------------------------------------------------------------------- 3. pypdf
echo "-- pypdf (verifies the PDF)"
if [ -n "$PY" ]; then
  if VER="$($PY -c 'import pypdf; print(pypdf.__version__)' 2>/dev/null)"; then
    ok "installed: pypdf $VER"
  else
    bad "pypdf is not installed"
    echo "        fix: $PY -m pip install pypdf"
    MISSING=1
  fi
else
  echo "  note  skipped — install Python 3 first, then: python3 -m pip install pypdf"
  MISSING=1
fi
echo

# ---------------------------------------------------------------------- verdict
if [ "$IS_WINDOWS" -eq 1 ]; then
  echo "note: native Windows shell detected. To render a CV use PowerShell:"
  echo "        powershell -ExecutionPolicy Bypass -File scripts\\render.ps1 <in.html> <out.pdf>"
  echo "      The bash renderer (scripts/render.sh) needs WSL. Everything else works here."
  echo
fi

if [ "$MISSING" -eq 0 ]; then
  if [ "$IS_WINDOWS" -eq 1 ]; then
    echo "RESULT: ready — render with 'powershell -ExecutionPolicy Bypass -File scripts\\render.ps1 <in.html> <out.pdf>',"
    echo "        then 'python scripts\\verify_pdf.py <out.pdf> --pages 2'."
  else
    echo "RESULT: ready — run 'scripts/render.sh <in.html> <out.pdf>' then 'scripts/verify_pdf.py <out.pdf> --pages 2'."
  fi
  exit 0
fi
echo "RESULT: not ready — fix the lines marked MISSING above, then re-run this check."
exit 1

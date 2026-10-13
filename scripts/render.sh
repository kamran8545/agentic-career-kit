#!/usr/bin/env bash
# render.sh — HTML -> PDF via headless Chrome/Chromium.
#
#   scripts/render.sh <input.html> <output.pdf>
#
# Works on macOS (Google Chrome) and Linux (google-chrome / chromium / chromium-browser).
# macOS: no extra install beyond Chrome. Linux: apt install chromium-browser.
#
# --no-pdf-header-footer is required: Chrome's default prints the URL and date
# into the page margin, which corrupts ATS text extraction.

set -euo pipefail

# Native Windows shells (Git Bash / MSYS / Cygwin) are not supported: path and
# file:// handling differ enough that Chrome silently writes nothing. Send the
# user somewhere that works instead of failing cryptically.
case "$(uname -s 2>/dev/null || echo unknown)" in
  MINGW*|MSYS*|CYGWIN*)
    cat >&2 <<'MSG'
error: native Windows shell detected (Git Bash / MSYS / Cygwin). render.sh needs a
       POSIX shell and does not support this directly.

  Pick one:
    1) Native Windows — render with PowerShell:
         powershell -ExecutionPolicy Bypass -File scripts\render.ps1 <input.html> <output.pdf>
    2) Recommended — use WSL, then run this same script inside WSL:
         https://learn.microsoft.com/windows/wsl/install

  After rendering (either way), verify with:
         python scripts/verify_pdf.py <output.pdf> --pages 2
MSG
    exit 69 ;;
esac

if [ $# -ne 2 ]; then
  echo "usage: $0 <input.html> <output.pdf>" >&2
  exit 64
fi

IN="$1"
OUT="$2"

[ -f "$IN" ] || { echo "error: no such file: $IN" >&2; exit 66; }

# Resolve to an absolute path — Chrome needs a real file:// URL and will not
# follow the cwd, and it silently writes nothing if the output dir is missing.
IN_ABS="$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"
mkdir -p "$(dirname "$OUT")"
OUT_ABS="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"

find_chrome() {
  if [ -n "${CHROME_BIN:-}" ]; then
    if [ -x "${CHROME_BIN}" ]; then
      echo "${CHROME_BIN}"
      return 0
    fi
    echo "warning: CHROME_BIN=${CHROME_BIN} is not executable; auto-detecting." >&2
  fi
  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    "$(command -v google-chrome    2>/dev/null || true)"
    "$(command -v google-chrome-stable 2>/dev/null || true)"
    "$(command -v chromium        2>/dev/null || true)"
    "$(command -v chromium-browser 2>/dev/null || true)"
    "$(command -v microsoft-edge  2>/dev/null || true)"
  )
  for c in "${candidates[@]}"; do
    [ -n "$c" ] && [ -x "$c" ] && { echo "$c"; return 0; }
  done
  return 1
}

CHROME="$(find_chrome)" || {
  cat >&2 <<'MSG'
error: no Chrome or Chromium found.

  macOS   install Google Chrome, OR
  Linux   sudo apt install chromium-browser
  Windows install Google Chrome, then use PowerShell: scripts\render.ps1 <in> <out>
  other   set CHROME_BIN=/path/to/chrome and re-run

  Diagnose everything at once:  scripts/check-setup.sh
MSG
  exit 69
}

# --virtual-time-budget lets layout/JS settle before the snapshot is taken.
"$CHROME" --headless --disable-gpu --no-sandbox --no-pdf-header-footer \
  --virtual-time-budget=5000 \
  --print-to-pdf="$OUT_ABS" \
  "file://$IN_ABS" >/dev/null 2>&1

[ -s "$OUT_ABS" ] || { echo "error: Chrome produced no output for $IN" >&2; exit 70; }

echo "rendered: $OUT_ABS"
echo "next:     scripts/verify_pdf.py \"$OUT_ABS\""

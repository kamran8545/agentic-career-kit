#!/usr/bin/env bash
# pre-publish-check.sh — refuse to publish anything that leaks a real person.
#
#   scripts/pre-publish-check.sh            → scan working tree + git history
#   scripts/pre-publish-check.sh --staged    → scan only what is about to be committed
#
# Run this before every push. A green run is the only thing standing between a
# forgetful `git add -A` and publishing someone's phone number, a client's name,
# or your own access token.
#
# `inbox/` is skipped by the working-tree scans: it is gitignored and exists to
# hold a user's own resume, so scanning it would flag the very data the folder
# is there to keep local. Ignored files cannot be staged without `git add -f`,
# and the `--staged` scan still sees anything that was forced in.
#
# Exits 0 clean, 1 if anything matched.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STAGED=0
[ "${1:-}" = "--staged" ] && STAGED=1

FAIL=0
NOTE=0

# ------------------------------------------------------------------ list setup
GENERIC=(scripts/denylist.txt)
LOCAL=(scripts/denylist.local.txt)

# Strip comments and blank lines before use. `grep -f` treats a blank line as a
# pattern that matches EVERY line, and a "# comment" as a literal search string,
# so feeding the raw file produces thousands of false positives.
PATTERNS=""
CLEANED=0
prepare() {
  local src="$1" dst="$2"
  [ -f "$src" ] || return 1
  grep -vE '^[[:space:]]*(#|$)' "$src" > "$dst" 2>/dev/null || true
  [ -s "$dst" ] || return 1
  CLEANED=$((CLEANED + 1))
  return 0
}

# Which files do we scan?
if [ "$STAGED" -eq 1 ]; then
  SCAN_LIST=()
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    SCAN_LIST+=("$f")
  done < <(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
  RECURSIVE=0
else
  SCAN_LIST=(".")
  RECURSIVE=1
fi

# These files necessarily contain the pattern strings they exist to detect, so
# scanning them guarantees a self-hit. Excluded by basename anywhere in the path.
#   - the deny files   : they ARE the patterns
#   - this script      : it embeds the detection regex
#   - LICENSE          : naming the repo owner there is intended
#   - README/CONTRIBUTING: they carry the repo's own clone URL, which names the
#                          owner — the same intended self-reference as LICENSE
SELF_PATHS='(\.?/?scripts/)?(denylist(\.local)?\.txt|pre-publish-check\.sh|LICENSE|README\.md|CONTRIBUTING\.md)'
is_excluded() {
  case "$1" in
    scripts/denylist.txt|./*/denylist.txt) return 0 ;;
    scripts/denylist.local.txt|./*/denylist.local.txt) return 0 ;;
    scripts/pre-publish-check.sh|./*/pre-publish-check.sh) return 0 ;;
    LICENSE|./*LICENSE) return 0 ;;
    README.md|./*README.md) return 0 ;;
    CONTRIBUTING.md|./*CONTRIBUTING.md) return 0 ;;
  esac
  return 1
}

scan_stream() {                        # $1 = label
  local label="$1" pat f hits n rflag=()
  [ "$RECURSIVE" -eq 1 ] && rflag=(-r --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=inbox)
  for pat in $PATTERNS; do
    for f in "${SCAN_LIST[@]}"; do
      is_excluded "$f" && continue
      if [ "$RECURSIVE" -eq 1 ]; then
        # In recursive mode the exclusion must be applied to each RESULT path,
        # not to the scan root "." — otherwise the deny files and LICENSE,
        # which necessarily contain the patterns, always self-trigger.
        hits="$(grep -nIiF "${rflag[@]}" -f "$pat" "$f" 2>/dev/null \
                | grep -vE "^\.?/?$SELF_PATHS:")" || true
      else
        [ -f "$f" ] || continue
        is_excluded "$(basename "$f")" && continue
        hits="$(grep -nIiF -f "$pat" "$f" 2>/dev/null | sed "s|^$f:|  |")" || true
      fi
      [ -n "$hits" ] || continue
      n="$(printf '%s\n' "$hits" | grep -c .)"
      echo "FAIL  [$label] $n match(es) in $(basename "$pat"):"
      printf '%s\n' "$hits" | head -10 | sed 's/^/        /'
      [ "$n" -gt 10 ] && echo "        … and $((n - 10)) more"
      FAIL=1
    done
  done
}

TMPDIR_P="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_P"' EXIT
i=0
for src in "${GENERIC[@]}" "${LOCAL[@]}"; do
  i=$((i + 1))
  prepare "$src" "$TMPDIR_P/pat$i" && PATTERNS="$PATTERNS $TMPDIR_P/pat$i"
done

echo "=== agentic-career-kit pre-publish check ==="
echo

# --------------------------------------------------------- 1. credential shapes
echo "-- generic secret patterns"
CRED=$(grep -rInE 'gh[pousr]_[A-Za-z0-9]{16,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----' \
        --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=inbox . 2>/dev/null | grep -v '^./scripts/denylist' || true)
if [ -n "$CRED" ]; then
  echo "FAIL  credential-shaped strings found:"
  printf '%s\n' "$CRED" | head -10 | sed 's/^/        /'
  echo "        treat every match as compromised and revoke it"
  FAIL=1
else
  echo "  ok  no tokens, keys, or credential shapes"
fi
echo

# ------------------------------------------------ 2. absolute local filesystem paths
echo "-- absolute local paths"
PATHS=$(grep -rInE '(/Users/[A-Za-z0-9._-]+|/home/[A-Za-z0-9._-]+|[A-Z]:\\\\Users\\\\)' \
          --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=inbox . 2>/dev/null | grep -v '^./scripts/denylist' || true)
if [ -n "$PATHS" ]; then
  echo "FAIL  absolute machine paths found:"
  printf '%s\n' "$PATHS" | head -10 | sed 's/^/        /'
  echo "        these expose the author's username and local layout"
  FAIL=1
else
  echo "  ok  no /Users, /home, or C:\\ paths"
fi
echo

# ------------------------------------------------------------- 3. denylist terms
echo "-- denylist terms"
if [ "$CLEANED" -eq 0 ]; then
  echo "WARN  no denylist file could be read — nothing is being checked"
  NOTE=1
elif [ "$STAGED" -eq 1 ] && [ ${#SCAN_LIST[@]} -eq 0 ]; then
  echo "  --  nothing staged"
else
  scan_stream "$([ "$STAGED" -eq 1 ] && echo staged || echo "working tree")"
  [ "$FAIL" -eq 0 ] && echo "  ok  no denylisted terms present"
fi
echo

# ------------------------------------------------------- 4. PII-shaped contact data
echo "-- contact data"
PII=$(grep -rInE '\+?[0-9]{2,4}[ -][0-9]{3}[ -][0-9]{4,5}|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
        --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=inbox . 2>/dev/null \
      | grep -v '^./scripts/denylist' \
      | grep -vEi 'example\.(com|org)|yourdomain|your-email|@template|@placeholder' || true)
if [ -n "$PII" ]; then
  echo "WARN  email/phone-shaped strings (confirm each is a public example):"
  printf '%s\n' "$PII" | head -10 | sed 's/^/        /'
  NOTE=1
else
  echo "  ok  no email or phone patterns"
fi
echo

# ------------------------------------------------------------- 5. tracked binaries
echo "-- tracked binary/PDF files"
# Exactly one PDF is sanctioned: the fictional example's rendered output, so
# users can inspect it without installing Chrome. Everything else is a real
# document belonging to a real person.
ALLOW='^examples/fictional-candidate/out/[^/]+\.pdf$'
BINS=$(git ls-files 2>/dev/null \
       | grep -Ei '\.(pdf|docx?|xlsx?|pptx?|keystore|jks|env|p12|pem|sqlite|db|zip)$' \
       | grep -Ev "$ALLOW" || true)
if [ -n "$BINS" ]; then
  echo "FAIL  binary or secret-adjacent files are tracked:"
  printf '%s\n' "$BINS" | head -10 | sed 's/^/        /'
  echo "        only examples/fictional-candidate/out/*.pdf is permitted"
  FAIL=1
else
  echo "  ok  no tracked PDFs, documents, keystores, or env files"
fi
echo

# ------------------------------------------------------------- 6. git history
if [ "$STAGED" -eq 0 ] && [ -d .git ]; then
  echo "-- git history"
  HIST=$(git log --all -p 2>/dev/null \
           | grep -nIiE 'gh[pousr]_[A-Za-z0-9]{16,}|/Users/[A-Za-z0-9._-]+' \
           | head -10 || true)
  if [ -n "$HIST" ]; then
    echo "FAIL  secrets or local paths exist in commit history:"
    printf '%s\n' "$HIST" | sed 's/^/        /'
    echo "        rewriting history is harder than starting clean — prefer that"
    FAIL=1
  else
    echo "  ok  history is clean"
  fi
  echo
fi

# --------------------------------------------------------------------- verdict
if [ -f scripts/denylist.local.txt ]; then
  echo "note: scripts/denylist.local.txt present (gitignored) — good."
else
  echo "note: no scripts/denylist.local.txt yet — personal names/employers are NOT being checked."
  echo "      copy scripts/denylist.example.txt and fill it in before publishing."
  NOTE=1
fi
echo

if [ "$FAIL" -eq 1 ]; then
  echo "RESULT: BLOCKED — fix the above before pushing."
  exit 1
fi
if [ "$NOTE" -eq 1 ]; then
  echo "RESULT: no hard failures, but review the warnings above."
  exit 0
fi
echo "RESULT: CLEAN — safe to push."

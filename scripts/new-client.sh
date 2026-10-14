#!/usr/bin/env bash
# new-client.sh — scaffold a per-candidate workspace.
#
#   scripts/new-client.sh "Ahmad R"          →  clients/ahmad-r-2026-10-15/
#   scripts/new-client.sh "Ahmad R" 2026-09-30
#
# Creates the folder shape the skills expect, seeded from the templates so the
# first job is just filling in facts rather than inventing structure.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: $0 \"Client Name\" [YYYY-MM-DD]" >&2
  exit 64
fi

RAW="$1"
DATE="${2:-$(date +%Y-%m-%d)}"

if ! printf '%s' "$DATE" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  echo "error: date must be YYYY-MM-DD, got: $DATE" >&2
  exit 65
fi

# "Ahmad R" -> "ahmad-r"
# -E (POSIX ERE) rather than \+ : BSD/macOS sed does not support \+ in BRE, and
# using it there silently leaves spaces in the folder name.
SLUG="$(printf '%s' "$RAW" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E -e 's/[^a-z0-9]+/-/g' -e 's/^-+//' -e 's/-+$//')"

# Names written in a non-Latin script (CJK, Cyrillic, Arabic, Devanagari …) slug
# to an empty string. Rather than refusing the work, fall back to a stable short
# hash of the name so the folder is still unique and still recognisable to the
# person who made it.
if [ -z "$SLUG" ]; then
  HASH="$(printf '%s' "$RAW" | cksum | tr -d ' ' | cut -d- -f1)"
  SLUG="client-$HASH"
  echo "note: '$RAW' has no latin characters; using folder name '$SLUG'." >&2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/clients/${SLUG}-${DATE}"

if [ -e "$DEST" ]; then
  echo "error: already exists: $DEST" >&2
  exit 73
fi

mkdir -p "$DEST"/{intake,profile,out/applications,report}

cp "$ROOT/context/candidate-profile.template.md" \
   "$DEST/intake/${SLUG}-intake.md"
cp "$ROOT/context/candidate-profile.template.md" \
   "$DEST/profile/candidate-profile.md"
cp "$ROOT/templates/resume.template.html"  "$DEST/out/Master-CV.html"
cp "$ROOT/templates/cover-letter.template.md" "$DEST/out/Master-CL.md"

cat > "$DEST/README.md" <<EOF
# ${RAW} — workspace

1. Send \`intake/${SLUG}-intake.md\` to the client. They fill it in and return it.
   (Or, if they have an existing resume, have them put the **PDF** in
   \`intake/\` — your AI agent can read it and pre-fill the profile, then ask
   only the remaining questions.)
2. Copy their returned file over \`profile/candidate-profile.md\`.
3. Build the master CV:
   \`scripts/render.sh clients/.../out/Master-CV.html clients/.../out/Master-CV.pdf\`
4. Verify: \`scripts/verify_pdf.py clients/.../out/Master-CV.pdf --pages 2\`
5. Per job: create \`out/applications/<Company>-<role>-<date>-CV.html\` from
   Master-CV.html, tailor it, render, verify, write the matching \`-CL.md\`.
6. Record the verification output in \`report/\` and send it with the PDF.

To import the resume PDF directly:
   \`scripts/extract_resume.py intake/<file>.pdf --out intake/<file>.txt\`
EOF

cat > "$DEST/intake/INSTRUCTIONS-TO-CLIENT.md" <<'EOF'
# Before you start

**Already have a resume?** You can skip most of this. Put a PDF of your current
resume in this folder and tell whoever is building your CV — it can be read and
pre-filled, and you will only be asked what it does not cover. The PDF must
contain real text, not a scan or a photo.

Otherwise, fill in the file next to this one:

1. Open the file next to this one in any **plain text editor**
   (TextEdit, VS Code, Notepad). Do **not** use Microsoft Word or Google Docs —
   they can mangle the formatting and the file will not save correctly.
2. Fill in every section. Delete any section you genuinely have no data for.
3. **Only enter numbers you can prove** — from an analytics dashboard, an app
   store listing, or a figure a colleague confirmed. Never estimate a percentage.
4. Save the file and send it back.

If anything is ambiguous or you would rather talk it through, reply to the email
that sent this and say so.
EOF

echo "created: $DEST"
echo
echo "next: send the client $DEST/intake/${SLUG}-intake.md"
echo "      and $DEST/intake/INSTRUCTIONS-TO-CLIENT.md"

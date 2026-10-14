# AGENTS.md — project memory for agentic-career-kit

Read this before touching anything. It encodes the rules that look like style
preferences and are actually correctness requirements.

## What this project is

A local-first toolkit for producing ATS-safe CVs and cover letters as verified
PDFs. No server, no account, no data leaves the machine. The user fills in one
markdown profile; an AI coding agent reads it; scripts render and verify the PDF.

## The one rule

**A PDF that has not passed `scripts/verify_pdf.py` is not a deliverable.**

Everything below exists to serve that.

## Layout

| Path | Role |
| ---- | ---- |
| `context/candidate-profile.template.md` | The intake form a user fills in. Source of all candidate data. |
| `inbox/` | **Gitignored except its README and placeholder.** Where a user drops an existing resume PDF to be imported. |
| `skills/` | Five skills: `candidate-intake`, `job-posting-analysis`, `cv-update`, `cover-letter-writer`, `ats-resume-audit`. Plain markdown. Canonical copy. |
| `.claude/skills/`, `.agents/skills/` | Symlinks to `skills/` so opencode, Claude Code, Cursor, Antigravity, and Codex auto-load the same files. Never edit these directly. |
| `CLAUDE.md` | Claude Code entry point; imports `AGENTS.md`. |
| `AGENTS.md` | This file. Read natively by most agents (opencode, Cursor, Codex, Copilot, Antigravity, Cline, Roo, Kilo, Amp). |
| `templates/resume.template.html` | ATS-safe CV template. **CSS is load-bearing.** |
| `templates/cover-letter.template.md` | Three-paragraph letter skeleton. |
| `templates/cover-letter.template.html` | One-page A4 wrapper to render the letter to a verified PDF. |
| `scripts/render.sh` | HTML → PDF via headless Chrome, macOS + Linux (incl. WSL). |
| `scripts/render.ps1` | HTML → PDF on native Windows (PowerShell). Same flags as `render.sh`. |
| `scripts/check-setup.sh` | Reports missing browser / Python / `pypdf`, with the fix for each OS. |
| `scripts/verify_pdf.py` | Five extraction checks. pypdf is the only dependency. |
| `scripts/extract_resume.py` | Reads an existing resume PDF into text for intake. pypdf only; repairs ligatures; reports scanned/locked PDFs. |
| `scripts/new-client.sh` | Scaffolds `clients/<Name>-<date>/`. |
| `scripts/pre-publish-check.sh` | Blocks publishing leaked PII, secrets, or tracked binaries. |
| `scripts/denylist.txt` | Committed generic patterns. Never real personal data. |
| `scripts/denylist.example.txt` | Template to copy into `denylist.local.txt`. |
| `scripts/denylist.local.txt` | Gitignored. The repo owner's names, clients, employers. |
| `examples/fictional-candidate/` | Synthetic worked example. Doubles as a smoke test. |
| `clients/` | **Gitignored.** Real people. Never commit anything from here. |

## Non-negotiable technical rules

Each of these was added because removing it breaks a user *silently* — the CV
looks correct and the ATS cannot read it.

1. **Ligature CSS must stay byte-for-byte.**
   ```css
   font-variant-ligatures: none;
   font-feature-settings: "liga" 0, "clig" 0, "dlig" 0, "hlig" 0;
   ```
   Without this, "Config" extracts as `Conﬁg` and the keyword is lost.

2. **Bullets are literal text.** `&bull;` inside each `<li>`. A CSS `::before`
   pseudo-element drops the first bullet's glyph during extraction, which
   scrambles bullet order.

3. **Body font is 10pt minimum.** Never shrink type to force a page count. An
   earlier one-page variant at 6.6pt was rejected as unreadable by the very
   people it was meant to impress.

4. **`--no-pdf-header-footer` is mandatory.** Chrome's default prints the file
   URL and a date into the page margin, which corrupts extracted text.

5. **Two A4 pages by default.** Page 1: header, summary, skills, two most recent
   roles. Page 2: remaining roles, projects, education, languages. Delete a
   section rather than compressing.

6. **Links must be real `<a href>`.** They become clickable PDF annotations.
   Plain text URLs do not survive cleanly and `verify_pdf.py` counts them.

## Content rules

- **Never invent a metric.** Only numbers present in the candidate's profile or
  publicly verifiable. An invented figure is discovered in the interview and
  costs more than the bullet was worth. See `docs/VERIFIED-METRICS.md`.
- **Never ship a placeholder.** `verify_pdf.py` fails on `{{...}}`. Replace it or
  delete the element containing it.
- **One title per CV.** Header, summary, and filename must agree.
- **Dates** are `Nov 2025 – Present`, en dash, abbreviated month. Never `11/2025`.
- **Location only if the candidate wants it.** Many people remove it
  deliberately. Do not add it on your own initiative.
- **Gaps get an honest line.** Never invent a role to cover a gap.

## Workflow for a candidate

The import path — a user who already has a resume:

> The user drops a PDF into `inbox/` and types **"build my resume."** The
> `candidate-intake` skill finds no profile, sees the PDF, and runs
> `scripts/extract_resume.py` to read it. It pre-fills
> `context/candidate-profile.md` with every fact the text supports, shows the
> user what it found for correction, and then asks only the questions the resume
> does not answer. Everything imported is a claim to confirm, never invented. If
> the PDF is a scan with no selectable text, the script says so and the skill
> falls back to the interview below.

The conversational path — a user with nothing filled in yet:

> User opens the repo in their agent and types **"build my resume."** The
> `candidate-intake` skill checks for a profile, finds none, and asks one question
> at a time (name → target title → contact → self-description → each role → gaps →
> skills → certifications → …), writing each answer into
> `context/candidate-profile.md` as it goes. Once the essentials are in,
> it hands off to `cv-update`, which renders and verifies.

The manual path, for a known candidate:

```bash
scripts/new-client.sh "Ahmad R"        # scaffold workspace
# candidate returns the filled intake → copy to profile/candidate-profile.md
scripts/render.sh   out/Master-CV.html out/Master-CV.pdf
scripts/verify_pdf.py out/Master-CV.pdf --pages 2
```

Either way: never invent a profile or a metric to have something to render.

Per job, copy the master to
`out/applications/<Company>-<role>-<YYYY-MM-DD>-CV.html`, tailor the copy only,
render, verify, and write the matching `-CL.md`. The master is never overwritten
for an application.

## Before publishing anything

```bash
scripts/pre-publish-check.sh
```

Must print `RESULT: CLEAN`. It scans the working tree, the staged set, and full
git history for tokens, absolute local paths, denylisted terms, contact-shaped
strings, and tracked binaries. The gitignored `inbox/` is skipped by the
working-tree scans — it holds a user's own resume, which cannot be committed
anyway; anything force-staged is still scanned. `LICENSE`, `README.md`, and
`CONTRIBUTING.md` are exempt from the personal denylist because naming the repo
owner there (its own clone URL) is intended.

## Adding a new check to verify_pdf.py

1. Make it a hard `FAIL` only if the CV is genuinely unusable. False alarms train
   people to ignore the output.
2. Explain the failure mode in the message, not just the symptom. "Ligature
   corruption: 2 glyphs — U+FB01 (fi). Keep font-variant-ligatures:none" tells
   the user how to fix it.
3. Add a row to the table in `examples/fictional-candidate/report/verification-sample.md`.

## Dependencies

`pypdf` only. No package manager, no build step, no lockfile. If a change
requires a new dependency, it almost certainly belongs outside this repo.

## Client data and publishing

This is a free, MIT-licensed, local-only tool. There is no paid tier, no
account, and no server; nothing here is sold or uploaded.

- Real client work lives in `clients/` (gitignored). Never commit it, never use
  it as a gallery sample without written consent, never "borrow" a metric from
  it into the fictional example.
- The repo owner's real identity is the author of this project and is named in
  `LICENSE` and in the clone URL in `README.md`/`CONTRIBUTING.md`; those are the
  only places it is expected. Personal terms specific to the owner and their
  clients live in `scripts/denylist.local.txt` (gitignored) and are enforced by
  `scripts/pre-publish-check.sh` before any push.

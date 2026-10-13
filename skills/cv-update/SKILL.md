---
name: cv-update
description: Build, edit, or regenerate a CV/resume as an ATS-safe PDF from a candidate profile and a job posting. Use when the user says "update my CV", "update my resume", "add a new job to my CV", "regenerate the PDF", "build my resume", "make my CV", "tailor my CV to this job", "fill the placeholders", or wants a new application-ready resume. Copies templates/resume.template.html, fills it from the candidate profile in the posting's language, renders with scripts/render.sh, and verifies with scripts/verify_pdf.py. A filled candidate profile must already exist — if it does not, run the candidate-intake skill first.
---

# CV Update

Turns a candidate profile into a verified, ATS-safe PDF.

## Order of operations

0. **No profile yet?** If `context/candidate-profile.md` (or
   `profile/candidate-profile.md`) is missing or still full of `{{...}}`
   placeholders, run the **`candidate-intake`** skill first — it interviews the
   user one question at a time and writes the profile. Never invent a profile
   just to have something to render.
1. **Read the source of truth first.** The candidate's profile
   (`profile/candidate-profile.md`, or `context/candidate-profile.md`
   at the repo root) and the HTML being edited. Never edit blind.
2. **Establish the target.** What single job title is this CV for? If the answer
   is "several", the CV is not tailored — say so and ask which one.
3. **Copy, never modify the master.** Tailored per-job CVs are copies in their own
   directory. The master CV is never overwritten for an application.
4. **Tailor in the posting's vocabulary.** Reorder skills to match the posting's
   priority order. Rename things the posting renames them. Keep the facts
   identical — only the emphasis and order change.
5. **Render, verify, then report.** Never hand over a PDF that has not been
   verified.

## Files

| Purpose | Path |
| ------- | ---- |
| Blank template | `templates/resume.template.html` |
| Candidate data | `profile/candidate-profile.md` |
| Per-job output | `out/applications/<Company>-<role>-<YYYY-MM-DD>-CV.html` + `.pdf` |
| A fresh client workspace | `scripts/new-client.sh "Client Name"` |

Filenames carry a `-CV` marker so they self-identify in a folder of mixed files.

## Rendering

```bash
scripts/render.sh out/applications/<Company>-<role>-<date>-CV.html \
                  out/applications/<Company>-<role>-<date>-CV.pdf
```

`render.sh` locates Chrome or Chromium on macOS or Linux, creates the output
directory, and refuses `--no-pdf-header-footer` being omitted — Chrome's default
prints the URL and date into the margin and corrupts extraction.

## Verifying

```bash
scripts/verify_pdf.py out/applications/<Company>-<role>-<date>-CV.pdf --pages 2
```

Do not deliver a file that fails. If it fails, fix the HTML and re-render — never
hand-wave a FAIL as acceptable.

## Hard rules

**The CSS block is not yours to edit.** `font-variant-ligatures: none` and
`font-feature-settings: "liga" 0, "clig" 0, "dlig" 0, "hlig" 0` are what prevent
`Conﬁg`-style corruption in extracted text. Keep them byte-for-byte.

**Bullets are literal `&bull;` text inside each `<li>`.** A CSS `::before`
pseudo-element drops the first bullet's glyph during extraction.

**Body font stays at 10pt.** Do not shrink it to hit a page count.

**Links are real `<a href>` elements.** They become clickable annotations; plain
text URLs do not survive cleanly.

**No placeholders ship.** Every `{{PLACEHOLDER}}` is replaced or the containing
element is deleted. `verify_pdf.py` fails on leftovers.

**No invented metrics.** Only numbers present in the candidate's profile, or
publicly verifiable (a store listing, a public dashboard). If a number would
strengthen a bullet and the profile does not have it, leave a clearly-marked
placeholder and tell the candidate which question to answer.

**One title.** The target title is used in the header, the summary, and the
filenames. Do not let it drift.

**Dates** use `Nov 2025 – Present` with an en dash. Never `11/2025`.

**Location** belongs on the CV only if the candidate wants it there. Many people
remove it deliberately; do not add it back on your own initiative.

## Two pages

Page 1: header, summary, skills, the two most recent roles.
Page 2: remaining roles, projects, education, languages.

Delete a whole section rather than shrinking type to fit.

## After editing

Sync the profile: if a fact changed, update `candidate-profile.md`. If something
is still unknown, it belongs in the profile's TODO list, not silently dropped.

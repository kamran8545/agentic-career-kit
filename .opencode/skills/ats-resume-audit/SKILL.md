---
name: ats-resume-audit
description: Audit a CV or resume for ATS (applicant tracking system) parseability and recruiter readability. Use when the user says "review my CV", "review my resume", "ATS check", "is my resume good", "score my resume", "improve my resume", "fix my resume", "why am I not getting interviews", or wants a resume audit before applying. Runs automated PDF extraction checks plus a recruiter rubric and returns a score with prioritised fixes.
---

# ATS Resume Audit

Two failure modes kill an application, and they are independent:

1. **The parser cannot read it.** The PDF exists and looks perfect on screen, but
   the ATS extracts garbage — no contact details, merged bullet lines, `ﬁ` instead
   of `fi`. The application is silently dead and the employer never sees it.
2. **The recruiter rejects it in 6 seconds.** It parses fine and is still weak.

Run both. Check 1 first — it is cheap and mechanical.

## 1. Automated extraction checks

```bash
scripts/render.sh  path/to/resume.html  /tmp/audit.pdf
scripts/verify_pdf.py /tmp/audit.pdf --pages 2
```

`verify_pdf.py` checks ligature corruption, unfilled placeholders, page count,
link annotations, and per-page text volume. **A FAIL here is disqualifying — fix
it before discussing anything else.**

Then read the extracted text yourself and look for what a script cannot judge:

- Do the contact details appear in the first 10 lines of extracted text?
- Do bullets appear in the correct order, one per line?
- Are dates in `Nov 2025 – Present` form (not `11/2025`)?
- Do company names appear unambiguously, once, with dates adjacent?

## 2. Recruiter pass — the top third sells the candidate

A recruiter decides in about six seconds. Read only the header, the summary, and
the first role. Then answer, honestly:

- Is the target title unambiguous and singular, or does it drift?
- Is there contact + at least one working link?
- Does the summary name the specific thing this posting wants?
- Is there a number in the first two roles?

## 3. Keyword coverage

Extract the required terms from the posting (`job-posting-analysis` produces
this list) and check each appears somewhere in the CV. Report exact gaps as
exact gaps: "the posting asks for X five times; your CV never says X."

## 4. Content quality

- **Unquantified bullets.** Every bullet should carry a number where one honestly
  exists: `+X%`, `<X ms`, `X users`, team size, volume. Flag the bullets that
  could carry a number but do not.
- **Employment gaps.** Any unexplained gap between roles is a question the
  candidate will be asked. Flag it; the fix is an honest line, not a fake role.
- **Unsupported claims.** Anything in the candidate's profile that is marked
  unverified must not survive into the CV.
- **Keyword stuffing.** Skills listed that the candidate cannot discuss in an
  interview are a liability. Flag skills with no supporting bullet anywhere.

## 5. Layout

- Two A4 pages is the safe default. Never shrink body text below 10pt to force a
  page count — a 6pt CV reads as a mistake to a human and defeats the point.
- Single column. Multi-column layouts are the most common cause of scrambled
  extraction order.
- Bullets must be literal text (`&bull;` inside `<li>`), never a CSS
  `::before` pseudo-element — pseudo-element glyphs are dropped from extraction,
  usually the first one.
- Links must be real `<a href>` elements so they survive as PDF annotations.

## Output

A score out of 100, split into **parseability** and **content**, then fixes
ordered by severity: `BLOCKER` (fails parsing), `HIGH` (costs interviews),
`MEDIUM` (polish). For each fix give the specific file and the specific change —
not "improve your summary".

Never invent metrics to fill a gap. If a number is missing, say it is missing and
mark it as a question for the candidate.

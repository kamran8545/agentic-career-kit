---
name: cover-letter-writer
description: Write a tailored cover letter or application letter for a specific job posting, using a candidate's real verified achievements. Use when the user says "write a cover letter", "cover letter for this job", "application letter", "draft an application", "apply to this role", or wants a letter to accompany a tailored CV. Picks 2-3 quantified achievements from the candidate profile, writes a ~300-word letter in the posting's language, and saves it next to the tailored CV.
---

# Cover Letter Writer

A cover letter is not a second CV. It is the argument for why *this* candidate
fits *this* job, in prose. Three paragraphs, under ~300 words.

## Inputs

- The job posting (pasted text or URL — fetch the URL if you have web access).
- The candidate's profile: `profile/candidate-profile.md`, or
  `context/candidate-profile.md` at the repo root.
- The tailored CV for the same job, if one exists — the letter must agree with it.

## Method

1. **Find the three things the posting actually cares about.** Not the whole
   requirements list — the three that a hiring manager would repeat in the
   interview. Those become the letter's spine.
2. **Pick 2–3 achievements from the profile that map onto them.** Choose for
   relevance over impressiveness. A smaller number that lands beats a longer
   number that does not.
3. **Write in the posting's vocabulary.** If they say "offline-first", the letter
   says offline-first, not "local data caching". The reader should never feel a
   seam between the posting and the letter.
4. **Name the company once, specifically.** One concrete reason this role
   interests you. Not flattery, not generic enthusiasm.
5. **Close with a clear ask to talk.** One sentence.

## Structure

- **Salutation** — "Dear Hiring Manager," unless the posting names a recruiter.
- **P1** — who I am and why this role. Target title, years, one line of context.
- **P2** — the proof. Two or three concrete accomplishments, reverse
  chronological, with a number where one honestly exists.
- **P3** — what I bring beyond the CV, plus the ask.
- **Sign-off** — "Sincerely," and the full name.

## What not to write

- **Any number that is not in the profile or publicly verifiable.** This is the
  single most damaging thing a letter can do. A fabricated metric is not a
  rounding error — it is a credibility failure discovered in the interview.
- **Restating the CV line by line.** It reads as filler and adds no information.
- **"I am writing to apply for…"** as an opening sentence, unless the P1 does
  something else immediately.
- **A dated formal letter**, unless the target market expects one (Germany/DACH
  commonly does). Most applications want the letter in the email body or as an
  undated attachment.
- **Salary, availability, work authorisation, or relocation** unless the
  candidate has explicitly asked for it to be included.

## Output

```
out/applications/<Company>-<role>-<YYYY-MM-DD>-CL.md     ← the letter itself
out/applications/<Company>-<role>-<YYYY-MM-DD>-CL.pdf    ← optional rendered copy
```

Write the prose in `templates/cover-letter.template.md` first — that is the
letter. For a PDF to attach, fill `templates/cover-letter.template.html` with the
same text (it carries the load-bearing CSS), then:

```bash
scripts/render.sh   out/applications/<Company>-<role>-<date>-CL.html \
                    out/applications/<Company>-<role>-<date>-CL.pdf
scripts/verify_pdf.py out/applications/<Company>-<role>-<date>-CL.pdf --pages 1
```

Most applications want the letter in the email body; the PDF is for markets and
portals that ask for an attachment. Either way, give the candidate the letter in
chat so they can read it before it goes anywhere. If any sentence depends on a
fact that is not in the profile, say so explicitly and list what needs confirming.

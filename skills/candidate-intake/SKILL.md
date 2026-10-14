---
name: candidate-intake
description: Interview a candidate and build their profile from scratch, one question at a time — or import an existing resume PDF dropped in inbox/ and pre-fill the profile, then ask only what is missing. Use when the user wants a CV/resume but no candidate profile exists yet — "build my resume", "make my CV", "start my CV", "create my resume", "I need a CV", "help me write a resume", "import my resume", "here is my old CV" — or when candidate-profile.md is missing or still full of placeholders. Asks a single question, writes the answer into candidate-profile.md, asks the next, then hands off to the cv-update skill to render and verify the PDF.
---

# Candidate Intake

Turns a person with no file into a filled `candidate-profile.md`, by
conversation — or from a resume they already have, if one is sitting in the
inbox. This is the first thing that runs when someone asks for a CV and there is
nothing to build from.

## When this runs

- There is no profile at `context/candidate-profile.md` or
  `profile/candidate-profile.md`, **or**
- the file exists but is still mostly `{{...}}` placeholders.

If a filled profile already exists, do **not** run this — go straight to
`cv-update`.

## An existing resume changes the interview

Before asking anything, look for a resume the candidate has already dropped in.
Check, in order:

- `inbox/*.pdf` (the repo-root drop folder — see `inbox/README.md`)
- `clients/*/intake/*.pdf` (a per-candidate workspace)

If more than one PDF is present, ask which one to use before reading it.

If a PDF is there, **do not run the full interview**. Instead:

1. Extract its text:

   ```bash
   scripts/extract_resume.py inbox/<file>.pdf --out inbox/<file>.txt
   ```

   If it exits non-zero, say so plainly — the PDF is scanned, password-locked,
   or empty, and reading it needs OCR this repo does not take. Then fall back to
   the full interview below, or offer to accept a text export.
2. Read the extracted text.
3. Copy the template and **pre-fill every field the text supports** — name,
   contact, links, each role with company/title/dates, skills, education,
   languages, certifications, projects. Facts only, in the candidate's own
   words; never invent, and never upgrade a claim.
4. Leave anything the text does not clearly state as a blank/placeholder. Those
   become the questions.
5. **Show the candidate what you pre-filled**, then ask them to correct it:

   > "From your resume I read: [short list]. Is any of that wrong or out of
   > date?"

6. Then run the interview below for **the gaps only** — never ask again what the
   resume already answered.

Treat everything from the resume as a **claim to confirm**, not truth. It is
their own resume, so it is a strong starting point, but the target title, the
years-of-experience number, the reason for any gap, and how each number was
measured still come from the candidate, aloud.

## The one rule of the interview

**Ask one question, then stop and wait.** Never hand the user a numbered list of
ten things to fill in — that is the form this tool exists to replace. After each
answer, write it into the profile file *before* asking the next question, so an
interrupted session still holds everything answered so far.

## Set up the file first

Before the first question, create the file so its shape is already correct:

```bash
cp context/candidate-profile.template.md \
   context/candidate-profile.md
```

Then fill it section by section as answers arrive — or pre-fill it from the
resume first, per the section above. In a client workspace, write
to `profile/candidate-profile.md` instead.

## Question order

Go in this order, **skipping anything the resume already answered**, one
question at a time. Keep each question short and plain.

1. **Full name.**
2. **The one job title they are targeting.** If they name several, ask which
   single one this CV is for.
3. **Master or targeted.** Is this a master CV for their whole search, or aimed at
   one specific posting? If they have a posting, ask them to paste it — build the
   master first (this skill), then tailor a copy per job (`cv-update`).
4. **Years of experience** in this field — confirm the number that will lead the
   summary. Do not infer it from dates alone.
5. **Contact:** phone, email, LinkedIn, GitHub or portfolio.
6. **Location** — ask once; many people deliberately leave it off the CV.
   Respect a "no".
7. **A short self-description.** "In a few sentences, what do you do, and what are
   you best at?" This becomes the professional summary. Shape it from their words;
   never invent a claim they did not make.
8. **Work history, newest first, one role at a time.** For each role ask:
   - company, their title, and start–end dates;
   - whether they are still in it, or when and why it ended;
   - what they owned and built, in their own words;
   - any numbers they can prove, and how they measured them;
   - the technologies used.
   Then ask, "Was there an earlier role?" and repeat.
9. **Gaps.** After the roles: "Is there a gap between any of these, or a break we
   should account for? How would you honestly describe it?" Every gap gets an
   honest line — never an invented role.
10. **Technical skills**, grouped however makes sense for their field.
11. **Projects** — optional; skip if they have nothing public to link.
12. **Education.**
13. **Certifications, awards, or publications** — optional; skip if none.
14. **Languages.**
15. **Anything they must NOT claim** — an NDA, a skill they only touched briefly,
    a metric that was really the team's.
16. **Anything else** that should shape the CV — tone, roles to avoid, formatting
    constraints.

## Rules during intake

- **One question at a time.** If you catch yourself writing "and also…", save it
  for the next turn.
- **Write each answer immediately** into the profile. If an answer changes
  something already written, say what you updated.
- **Never invent a number.** If they give one, ask how they measured it and
  record the source. If they cannot, write the achievement without a number. A
  guessed figure is discovered in the interview and costs the job.
- **Dates** as `Mar 2021 – Present` — en dash, abbreviated month. Never
  `03/2021`.
- **Optional fields get a skip.** Location, projects, certifications, and
  languages can be left out; ask once, accept "skip", move on.
- **Do not interrogate.** If an answer is enough, take it and move on. This is a
  conversation, not a form.
- **Record in their words.** You are capturing facts now; tailoring happens later,
  per job. Do not rewrite their experience into marketing prose here.
- **Skip what the resume answered.** If the file already holds a role, a skill,
  or a degree, confirm it once (if anything) and move on. Do not re-ask.

## Finishing

Once the essentials are in — name, target title, at least one role, skills — stop
and confirm:

> "That's enough to build a first CV. Anything to add before I render it?"

Then hand off to the **`cv-update`** skill: it copies
`templates/resume.template.html`, fills it from the profile, renders with
`scripts/render.sh`, and verifies with `scripts/verify_pdf.py` — looping until it
passes. Never deliver a PDF that has not passed.

Anything still unknown belongs in the profile's TODO list: surfaced, never
invented.

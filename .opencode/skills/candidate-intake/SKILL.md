---
name: candidate-intake
description: Interview a candidate and build their profile from scratch, one question at a time. Use when the user wants a CV/resume but no candidate profile exists yet — "build my resume", "make my CV", "start my CV", "create my resume", "I need a CV", "help me write a resume" — or when candidate-profile.md is missing or still full of placeholders. Asks a single question, writes the answer into candidate-profile.md, asks the next, then hands off to the cv-update skill to render and verify the PDF.
---

# Candidate Intake

Turns a person with no file into a filled `candidate-profile.md`, by
conversation. This is the first thing that runs when someone asks for a CV and
there is nothing to build from.

## When this runs

- There is no profile at `.opencode/context/candidate-profile.md` or
  `profile/candidate-profile.md`, **or**
- the file exists but is still mostly `{{...}}` placeholders.

If a filled profile already exists, do **not** run this — go straight to
`cv-update`.

## The one rule of the interview

**Ask one question, then stop and wait.** Never hand the user a numbered list of
ten things to fill in — that is the form this tool exists to replace. After each
answer, write it into the profile file *before* asking the next question, so an
interrupted session still holds everything answered so far.

## Set up the file first

Before the first question, create the file so its shape is already correct:

```bash
cp .opencode/context/candidate-profile.template.md \
   .opencode/context/candidate-profile.md
```

Then fill it section by section as answers arrive. In a client workspace, write
to `profile/candidate-profile.md` instead.

## Question order

Go in this order, one question at a time. Keep each question short and plain.

1. **Full name.**
2. **The one job title they are targeting.** If they name several, ask which
   single one this CV is for.
3. **Contact:** phone, email, LinkedIn, GitHub or portfolio.
4. **Location** — ask once; many people deliberately leave it off the CV.
   Respect a "no".
5. **Work history, newest first, one role at a time.** For each role ask:
   - company, their title, and start–end dates;
   - what they owned and built, in their own words;
   - any numbers they can prove, and how they measured them;
   - the technologies used.
   Then ask, "Was there an earlier role?" and repeat.
6. **Technical skills**, grouped however makes sense for their field.
7. **Projects** — optional; skip if they have nothing public to link.
8. **Education.**
9. **Languages.**
10. **Anything they must NOT claim** — an NDA, a skill they only touched briefly,
    a metric that was really the team's.
11. **Anything else** that should shape the CV — a gap to explain honestly, tone,
    roles to avoid.

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
- **Optional fields get a skip.** Location, projects, and languages can be left
  out; ask once, accept "skip", move on.
- **Do not interrogate.** If an answer is enough, take it and move on. This is a
  conversation, not a form.
- **Record in their words.** You are capturing facts now; tailoring happens later,
  per job. Do not rewrite their experience into marketing prose here.

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

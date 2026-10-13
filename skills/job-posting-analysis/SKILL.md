---
name: job-posting-analysis
description: Analyse a job description against a candidate's profile and score the fit. Use when the user says "analyze this job", "analyze this JD", "is this a good fit", "what are my chances", "check this role", "should I apply to this", or pastes a job posting and asks for an assessment. Extracts seniority, must-have vs nice-to-have requirements, ATS keywords, and red flags, then returns a fit score with the exact CV keyword gaps to close.
---

# Job Posting Analysis

The output of this skill is a decision — apply or don't — plus a short list of
concrete edits if the answer is yes. Not a summary of the posting.

## Method

1. **Get the posting.** Pasted text is best. If given a URL and you have web
   access, fetch it. If the posting is behind a login or a JavaScript wall, say
   so and ask for the text rather than guessing at the requirements.

2. **Separate must-have from nice-to-have.** The posting rarely labels them, so
   infer: must-haves are in the first third, repeated, or phrased as
   non-negotiable. A skill listed once near the bottom is usually a nice-to-have.
   This distinction drives the whole assessment — missing three nice-to-haves is
   not a reason to skip a role.

3. **Extract ATS keywords literally.** The exact tokens the posting uses, which
   are the tokens a keyword-matching ATS is looking for. "REST APIs" in the
   posting means your CV should say "REST APIs", not "API integration".

4. **Compare against the profile** (`profile/candidate-profile.md`, or
   `context/candidate-profile.md` at the repo root).

5. **Score the fit** out of 100:

   | Band | Weight | What it measures |
   | ---- | ------ | ---------------- |
   | Must-have coverage | 40 | Fraction of non-negotiables genuinely evidenced |
   | Core skill depth | 25 | Real experience vs course-level familiarity |
   | Seniority match | 15 | Scope the candidate has actually held |
   | Domain relevance | 10 | Same industry, or genuinely transferable |
   | Logistics | 10 | Location, work mode, language, compensation band |

## Output format

**Verdict** — one line. Apply / apply with caveats / probably not.

**Score** — `NN/100`, with the band breakdown. Be willing to give a low score.
A clear "no" is more useful than an encouraging maybe.

**Exact keyword gaps** — a table of posting keyword → present/absent → where it
should go on the CV. "Present" means evidenced by a bullet, not merely listed in
a skills block.

**Honest gaps** — must-haves the candidate does not have. For each, say whether
it is genuinely blocking or whether adjacent experience substitutes. Then give
the honest framing for an interview if the candidate still applies. Never coach
a way to claim something they have not done.

**What to lead with** — the two or three profile achievements that map most
directly onto the top requirements. These go at the top of the tailored CV and
carry the cover letter.

**Red flags** — signals worth knowing before spending an hour: a stack far from
the candidate's, on-site requirement conflicting with their constraints,
unrealistic seniority, compensation missing or far off band, or a posting so
generic it suggests keyword stuffing rather than a real vacancy.

## Rules

- Judge against the profile, never against what sounds impressive. A candidate
  who lists a tool they used for two weeks is not a match for a five-year
  requirement.
- Absence of evidence in the profile means "not yet established", not "no". Say
  which it is, and ask the candidate.
- Never soften a bad score to be encouraging. A rejection avoided is worth more
  than an application made.
- If the fit is strong, still name the weakest requirement. There is always one.

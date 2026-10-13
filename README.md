# agentic-career-kit

**An ATS-safe CV and cover letter generator that runs entirely on your own
machine. No account, no upload, no subscription.**

Most CV tools are a form on a website. That is the problem: your personal data
leaves your computer, and the PDF you get back is a screenshot-quality export
nobody can verify. This is the opposite — plain text files in a folder, an AI
coding agent you may already have installed, and a script that proves your
finished PDF actually parses.

```bash
git clone https://github.com/kamran8545/agentic-career-kit.git
cd agentic-career-kit
scripts/render.sh examples/fictional-candidate/out/Master-CV.html /tmp/example.pdf
scripts/verify_pdf.py /tmp/example.pdf --pages 2      # must print PASS
```

If that last command prints `PASS`, your machine can run the whole pipeline.
If it does not, jump to [Troubleshooting](#troubleshooting).

---

## Why this exists

A CV that looks perfect in a browser can be **completely unreadable to the
applicant tracking system** that decides whether a human ever sees it. The
application is rejected silently, and you never find out why.

The three most common causes are all invisible on screen:

| Problem | What it looks like | How it is fixed here |
| --- | --- | --- |
| **Ligature substitution** | `Conﬁg` instead of `Config` | CSS disables ligatures so text extracts cleanly |
| **Missing bullet glyphs** | Bullets fine on screen, first one vanishes in extraction | Bullets are literal text, never a CSS `::before` |
| **Dead links** | URLs render but are not clickable or scannable | Real `<a href>` elements become PDF annotations |

`scripts/verify_pdf.py` catches all three automatically, and prints proof. That
proof is the deliverable.

> **The one rule: a PDF that has not passed `scripts/verify_pdf.py` is not a
> deliverable.** Everything below exists to serve that.

---

## How it works

```
candidate-profile.md  ──►  resume.template.html  ──►  Master-CV.html
  (you fill it in —           (the agent fills it)          │
   or the agent interviews                                  ▼
   you and fills it)  scripts/render.sh ──► PDF ──► scripts/verify_pdf.py ──► PASS
```

1. You fill in one markdown file: your profile — by hand, or by answering the
   agent's questions.
2. An AI agent reads it and fills `templates/resume.template.html`.
3. `scripts/render.sh` turns the HTML into a PDF via headless Chrome.
4. `scripts/verify_pdf.py` extracts the text back out and proves it survived.

Step 4 is the point. Steps 1–3 are how you get there.

---

## Quick start

The fastest way to see the whole thing work is the fictional worked example.
It is a complete candidate — invented, so nothing personal is exposed.

```bash
scripts/render.sh   examples/fictional-candidate/out/Master-CV.html /tmp/example.pdf
scripts/verify_pdf.py /tmp/example.pdf --pages 2
```

Expected output:

```
file    /tmp/example.pdf
pages   2
chars   3205
links   7

PASS  all checks clean — safe to send.
```

If you get anything else, your Chrome or `pypdf` install is the problem, not the
template. See [Troubleshooting](#troubleshooting).

---

## Step by step: your own CV

There are two ways in. Pick one.

**Option A — let the agent interview you (easiest).** Open this folder in your
agent and just say:

> **Build my resume.**

No profile exists yet, so the `candidate-intake` skill takes over: it asks **one
question at a time** — your name, your target title, your contact details, how
you'd describe yourself, each role, any gaps, your skills, your certifications —
and writes every answer into `context/candidate-profile.md` as it goes,
so an interrupted session never loses what you already answered. Once the
essentials are in, it hands off to build and verify the CV. You edit nothing by
hand.

**Option B — fill the profile yourself.**

### 1. Fill in the profile

```bash
cp context/candidate-profile.template.md \
   context/candidate-profile.md
```

Open `candidate-profile.md` in any plain-text editor (TextEdit, VS Code,
Notepad — **not** Word or Google Docs) and replace every `{{LIKE THIS}}`.
Delete any section you have no data for. Do not leave blanks.

> **The one rule that matters:** only write numbers you can prove.
> A number from a store listing, an analytics dashboard, or a colleague who
> told you is fine. A number you are guessing at is not — it will be asked
> about in the interview. See [docs/VERIFIED-METRICS.md](docs/VERIFIED-METRICS.md).

> **Privacy:** `candidate-profile.md` contains real personal data. The paths used
> here — `context/candidate-profile.md`, `profile/`, and generated
> `out/` files — are already gitignored, so a filled-in profile is not committed
> by accident. Still never commit it deliberately.
>
> If you would rather keep everything in one self-contained gitignored folder,
> use the client workspace in [Building for other people](#building-for-other-people) —
> it puts the profile at `clients/<name>-<date>/profile/candidate-profile.md`.

The skills also recognise a profile at `profile/candidate-profile.md`.

### 2. Ask your agent to build the master CV

If you used Option A, this is already happening. Otherwise, open this folder in
[opencode](https://opencode.ai), Claude Code, or Codex, and say:

> **Build my master CV from `context/candidate-profile.md`.**

The `cv-update` skill copies `templates/resume.template.html` to
`out/Master-CV.html`, fills it from your profile, renders it with
`scripts/render.sh`, and runs `scripts/verify_pdf.py`. If it reports a `FAIL`,
it fixes the HTML and re-renders — it will not hand you an unverified file.

You can also drive the tools yourself without an agent:

```bash
cp templates/resume.template.html out/Master-CV.html
# edit out/Master-CV.html by hand
scripts/render.sh    out/Master-CV.html out/Master-CV.pdf
scripts/verify_pdf.py out/Master-CV.pdf --pages 2
```

### 3. Verify before you send

```bash
scripts/verify_pdf.py out/Master-CV.pdf --pages 2
```

If it prints `PASS`, your CV is safe to send. If it prints `FAIL`, the file is
broken and no amount of polishing will help. What each check means is in
[The commands](#the-commands).

The master CV is a reference you return to. **Never overwrite it for an
application** — copy it, per the next section.

---

## The five skills

Nothing here is locked inside a server. The skills are plain markdown in
`skills/` — read them, edit them, delete the ones you do not want.

| Skill | Ask it when you want to… | Typical prompt |
| --- | --- | --- |
| `candidate-intake` | Build a profile from scratch by answering questions | *"Build my resume."* |
| `job-posting-analysis` | Decide whether to apply, and see the exact keyword gaps | *"Analyse this job posting against my profile."* |
| `cv-update` | Build or tailor a CV | *"Tailor my CV to this job posting."* |
| `cover-letter-writer` | Write the matching letter | *"Write a cover letter for this role."* |
| `ats-resume-audit` | Audit a CV for parseability and content quality | *"Audit my CV for ATS problems."* |

What each one actually does:

- **`candidate-intake`** — when there is no profile yet, asks one question at a
  time (name → target title → contact → each role → skills → …), writes each
  answer into `candidate-profile.md` immediately, and never invents a number.
  Hands off to `cv-update` once the essentials are in.
- **`job-posting-analysis`** — separates must-haves from nice-to-haves, extracts
  the posting's exact keywords, compares them against your profile, and returns a
  fit score out of 100 with the specific keyword gaps and honest gaps. A clear
  "no" is a valid answer.
- **`cv-update`** — reads the profile, establishes the one target title, copies
  the template, tailors the wording to the posting's vocabulary (facts stay
  identical; only emphasis and order change), then renders and verifies.
- **`cover-letter-writer`** — three paragraphs, under ~300 words, in the
  posting's language, built from two or three quantified achievements that
  already exist in the profile. It does not restate the CV.
- **`ats-resume-audit`** — runs the automated extraction checks, then a
  six-second recruiter pass and a content review, and returns a score split into
  parseability and content with fixes ordered `BLOCKER` / `HIGH` / `MEDIUM`.

---

## Works with any AI coding agent

The tool is just scripts — any agent that can run a shell command can build a
CV. The instructions are written once in [`AGENTS.md`](AGENTS.md), which most
agents read natively, and the five skills are plain `SKILL.md` files. They are
linked into the paths each tool expects, so there is one source of truth and
nothing to keep in sync.

| Tool | How it picks up the workflow |
| --- | --- |
| **opencode** | Reads `AGENTS.md`; skills auto-load from `.agents/skills/` |
| **Claude Code** | Reads `CLAUDE.md`, which imports `AGENTS.md`; skills at `.claude/skills/` |
| **Cursor** | Reads `AGENTS.md` natively; skills from `.agents/skills/` or `.claude/skills/` |
| **Google Antigravity** | Reads `AGENTS.md` natively; skills from `.agents/skills/` |
| **Codex CLI** | Reads `AGENTS.md`; skills from `.agents/skills/` |
| **GitHub Copilot** | Reads `AGENTS.md` natively |
| **Cline / Roo Code / Kilo Code** | Read `AGENTS.md` natively |
| **Gemini CLI** | Add `"contextFileName": ["AGENTS.md"]` to `.gemini/settings.json` |
| **Aider** | Add `read: [AGENTS.md]` to `.aider.conf.yml` |

If a tool does not auto-load the skills, point it at
`skills/<name>/SKILL.md` — the files are plain markdown and work
anywhere.

---

## Tailoring for a single job

Never edit the master. Copy it, tailor the copy, and keep both files labelled
with the company, role, and date.

```
out/
  Master-CV.html                 ← the reference, never overwritten
  Master-CV.pdf
  applications/
    Acme-Senior-Engineer-2026-10-13-CV.html     ← tailored copy
    Acme-Senior-Engineer-2026-10-13-CV.pdf      ← rendered and verified
    Acme-Senior-Engineer-2026-10-13-CL.md       ← matching cover letter
```

1. Ask the agent to *"tailor my CV to this job posting"* — it will create the
   copy under `out/applications/` and render it.
2. Verify the copy:
   ```bash
   scripts/verify_pdf.py out/applications/Acme-Senior-Engineer-2026-10-13-CV.pdf --pages 2
   ```
3. Ask it to *"write a cover letter for this role"*. It starts from
   `templates/cover-letter.template.md`, saves the letter next to the CV, and
   shows it to you in chat before it goes anywhere.

Filename markers (`-CV`, `-CL`) exist so the files self-identify in a folder of
mixed documents.

---

## Building for other people

If you are building for other people, scaffold one gitignored workspace per
person so nothing gets mixed up. This is also the privacy-safe way to build your
*own* CV — everything stays isolated and out of version control.

```bash
scripts/new-client.sh "Ahmad R"
# → clients/ahmad-r-<date>/
```

The scaffold creates the folder shape the skills expect and seeds it from the
templates:

```
clients/ahmad-r-2026-10-13/
  intake/
    ahmad-r-2026-10-13-intake.md      ← send this to the candidate
    INSTRUCTIONS-TO-CLIENT.md         ← and this, with the "provable numbers" rule
  profile/candidate-profile.md        ← copy their returned file here
  out/Master-CV.html
  out/Master-CL.md
  report/                             ← the verification report goes here
```

Then follow the same loop at the workspace root: build the master, verify it,
tailor per job, and record the `verify_pdf.py` output in `report/`.

`clients/` is gitignored. Real people's CVs, phone numbers, and employers never
leave it.

---

## The commands

| Command | What it does |
| --- | --- |
| `scripts/render.sh in.html out.pdf` | HTML → PDF via headless Chrome. macOS and Linux. |
| `scripts/verify_pdf.py out.pdf --pages 2` | Proves the PDF survives text extraction. **Run this every time.** |
| `scripts/new-client.sh "Name" [YYYY-MM-DD]` | Scaffolds a per-person workspace so nothing gets mixed up |
| `scripts/pre-publish-check.sh` | Blocks publishing leaked PII, secrets, or tracked binaries *(if you are hacking on this repo)* |

### What `verify_pdf.py` checks

It reads the rendered PDF back and reports in order of how badly each failure
breaks an application:

| # | Check | A failure means |
| --- | --- | --- |
| 1 | **Ligatures** — U+FB00–FB06 glyphs | `fi`/`fl`/`ff` were fused into one character. Fix the CSS block, don't touch the text. |
| 2 | **Placeholders** — `{{...}}` or `[Title Case]` | Something was never filled in. Replace it or delete the element containing it. |
| 3 | **Page count** | Wrong length for the layout — content is truncated or overflowing. |
| 4 | **Link annotations** | Your `<a href>` links did not survive; you used plain-text URLs. A warning by default, a hard failure with `--expect-links N`. |
| 5 | **Text per page** | A page extracts to almost nothing — the layout collapsed. |

Useful flags:

```bash
scripts/verify_pdf.py out.pdf --pages 2 --expect-links 7 --min-chars-per-page 200
```

Exit code `0` is clean, `1` is one or more failures, so it drops straight into CI.
The repo's own CI (`.github/workflows/smoke-test.yml`) re-renders the fictional
example and verifies it on every change to the scripts or templates.

### The verification report

Every real deliverable ships with the `verify_pdf.py` output. See
`examples/fictional-candidate/report/verification-sample.md` for the format. It
turns "trust me, it parses" into a check anyone can run — which is the reason
this project exists.

---

## Requirements

- **Chrome or Chromium** — macOS: install Google Chrome. Linux: `apt install chromium-browser`.
- **Python 3.9+** with `pypdf` — `pip install pypdf`
- **An AI coding agent** — [opencode](https://opencode.ai) (free), Claude Code,
  Cursor, Google Antigravity, Codex, or any other. See
  [Works with any AI coding agent](#works-with-any-ai-coding-agent).

No package manager, no build step, no lockfile. `pypdf` is the only dependency.

---

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| `error: no Chrome or Chromium found` | Install Google Chrome, or point at your binary: `CHROME_BIN=/path/to/chrome scripts/render.sh …` |
| `error: pypdf is required` | `pip install pypdf` |
| `FAIL ligature corruption` | The CSS `font-variant-ligatures: none` / `font-feature-settings` block was edited or removed. Restore it byte-for-byte. |
| `FAIL unfilled placeholders` | A `{{...}}` shipped. Replace it or delete the element containing it. |
| `FAIL page count` | Content runs long or short. Cut a whole section — never shrink the font below 10pt. |
| `WARN`/`FAIL link annotations` | Links are plain text (reported as a warning by default). Make them real `<a href>` elements, and pass `--expect-links N` to make a wrong count a hard failure. |
| `FAIL page N extracts only … chars` | The layout collapsed — most often a multi-column layout. Use a single column. |
| Nothing renders, Chrome writes no output | Check the input path and that the output directory is writable. `render.sh` prints the resolved absolute path on success. |
| On Windows | `render.sh` supports macOS and Linux only. Use WSL, or call Chrome yourself with `--headless --no-pdf-header-footer --print-to-pdf=…`. |

---

## Layout

```
skills/                                   five skills: intake, analyse, update, write, audit
context/
  candidate-profile.template.md           the form you fill in
.claude/skills                            → linked to skills/ for Claude Code
.agents/skills                            → linked to skills/ for opencode/Cursor/Antigravity/Codex
CLAUDE.md                                 Claude Code entry point (imports AGENTS.md)
AGENTS.md                                 cross-tool instructions (read by most agents)
templates/
  resume.template.html                    ATS-safe CV template (CSS is load-bearing)
  cover-letter.template.md                cover letter skeleton
  cover-letter.template.html              one-page A4 wrapper to render the letter to PDF
scripts/
  render.sh                               HTML → PDF via headless Chrome
  verify_pdf.py                           the five extraction checks. pypdf only dependency
  new-client.sh                           scaffold a per-person workspace
  pre-publish-check.sh                    leak/PII gate before pushing
  denylist.txt                            committed generic patterns
  denylist.example.txt                    template to copy into denylist.local.txt
  denylist.local.txt                      your real names/clients (gitignored)
docs/
  ATS-EXTRACTION.md                       why the CSS looks the way it does
  VERIFIED-METRICS.md                     the only numbers you may use
examples/fictional-candidate/             a complete, runnable worked example
clients/                                  created per person (gitignored)
```

---

## Design rules that are not negotiable

Each of these was added because removing it breaks a user **silently** — the CV
looks correct and the ATS cannot read it.

1. **The CSS block is not yours to edit.** `font-variant-ligatures: none` and
   `font-feature-settings: "liga" 0, ...` are what prevent `ﬁ` appearing in
   extracted text. Keep them byte-for-byte.
2. **Bullets are literal `&bull;` inside each `<li>`.** A CSS `::before`
   pseudo-element drops the first bullet's glyph on extraction, which scrambles
   the bullet order.
3. **Body font stays at 10pt.** Do not shrink type to hit a page count. A 6pt CV
   is unreadable and reads as careless.
4. **`--no-pdf-header-footer` is mandatory.** Chrome's default prints the file
   URL and a date into the page margin and corrupts extracted text.
5. **One title per CV.** Header, summary, and filename must agree. If you are
   sending to three different roles, that is three CVs.
6. **Never invent a metric.** A number you cannot defend in an interview is worse
   than no number. See [docs/VERIFIED-METRICS.md](docs/VERIFIED-METRICS.md).
7. **Never ship a placeholder.** `verify_pdf.py` fails on `{{...}}` for a reason.

The deeper reasoning — including single-column and two-page rules — is in
[docs/ATS-EXTRACTION.md](docs/ATS-EXTRACTION.md).

---

## Contributing

Issues and pull requests welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
A new ATS extraction failure mode with a reproduction is the most useful thing
you can send.

If you are hacking on this repo itself, run `scripts/pre-publish-check.sh` before
every push; it must not print `RESULT: BLOCKED`. (On a fresh clone it prints a
note about the missing `scripts/denylist.local.txt` until you create it — see
[CONTRIBUTING.md](CONTRIBUTING.md).)

## License

MIT. See [LICENSE](LICENSE).

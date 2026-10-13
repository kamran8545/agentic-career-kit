# Contributing

Thanks for looking. This is a small project and the contributions that help most
are usually not code.

## The most useful thing you can send

**A way a CV silently failed to parse, with the file that caused it.**

If you ever produced a CV that looked fine and still got no responses, and you
can share the HTML that produced it, that is gold. The failure modes in
`docs/ATS-EXTRACTION.md` were all found this way. A reproduction lets me add a
check to `scripts/verify_pdf.py`, which turns one person's silent rejection into
a warning for everyone.

## What is useful

- **A new extraction failure mode** with a minimal reproducing HTML file.
- **A better `verify_pdf.py` check** — especially one that catches something the
  current five checks miss.
- **Platform support.** `render.sh` handles macOS and Linux (including WSL);
  `render.ps1` handles native Windows. A container image, or a tested BSD path,
  would still be welcome.
- **A worked example in a different field.** The fictional example is a data
  engineer. A CV in, say, nursing or teaching would prove the template is not
  secretly software-shaped.
- **Docs fixes.** If something in the README confused you, that is a bug.

## What is not useful

- **Adding a dependency.** A handful of scripts, no package manager, `pypdf`
  only. This stays a `git clone` and it works.
- **A hosted version.** If you want a web app, build it — but do not turn this
  repo into one. The whole point is that it runs locally with no account.
- **Inventing metrics guidance.** If a section suggests estimating a number you
  do not have, that is a bug; open an issue rather than softening the rule.
- **Submitting someone's real CV or cover letter as an example.** Use
  `examples/fictional-candidate/`. Real ones belong in your own
  `clients/` directory, which is gitignored.

## Setup

```bash
git clone https://github.com/kamran8545/agentic-career-kit.git
cd agentic-career-kit
pip install pypdf          # the only dependency
scripts/render.sh examples/fictional-candidate/out/Master-CV.html /tmp/test.pdf
scripts/verify_pdf.py /tmp/test.pdf --pages 2   # must print PASS
```

If that last command does not print `PASS` on a clean checkout, something is
broken — open an issue before changing anything else.

## Before you commit

```bash
scripts/pre-publish-check.sh
```

It must not print `RESULT: BLOCKED`. On a fresh clone you will instead get a
note that `scripts/denylist.local.txt` is missing, so the personal-terms scan is
idle — that is expected and not a failure. Copy `scripts/denylist.example.txt` to
`scripts/denylist.local.txt` and fill it in to enable the scan. If you add a rule
to `scripts/denylist.txt`, keep it pattern-shaped — never put a real person's data
in a committed file. Personal terms belong in `scripts/denylist.local.txt`, which
is gitignored.

## Style

- Match the surrounding file. The five skills are instructional prose, not code.
- Comments explain *why* something is unusual, because most of it is. A reader
  will otherwise "clean up" the ligature rules and break extraction.
- No framework, no build step, no bundler.

## Rules that are not negotiable

These look like style preferences and are not. Changing them breaks users
silently:

1. `font-variant-ligatures: none` and `font-feature-settings: "liga" 0, ...`
2. Bullets as literal `&bull;` inside `<li>`, never `::before`
3. Body font `10pt` minimum
4. `--no-pdf-header-footer` in the Chrome invocation

If a PR removes any of these, it will be declined with an explanation.

## Code of conduct

Be decent. Assume good faith. Critique the work, not the person.

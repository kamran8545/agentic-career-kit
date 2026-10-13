# Security

## What this project does and does not do

This toolkit renders CVs and cover letters **locally** on the machine it is run
on. It has no server, no database, no cloud component, and no account. Nothing a
candidate types is uploaded anywhere, and no data leaves the machine except the
files the candidate themselves chooses to send to an employer.

The only piece of candidate data that can persist anywhere is on the machine
that ran it — and by default that is inside `clients/`, which is excluded from
version control by `.gitignore` and additionally blocked from ever being
committed by `scripts/pre-publish-check.sh`.

That boundary is a design property, not a feature flag. A change that moves
candidate data to a server, an analytics endpoint, or any third-party service is
a security regression and will not be merged.

## Reporting a vulnerability

There is no hosted attack surface, which limits what a report can even target,
but issues still exist:

- **Injection of crafted input.** A malicious HTML file or a crafted template
  being rendered or executed (template injection).
- **The Chrome invocation in `scripts/render.sh` and `scripts/render.ps1`.** They
  run headless Chrome, Chromium, or Edge on attacker-influenced local files.
- **The support scripts.** A path or pattern that escapes its intended scope.

Please report anything you find by opening an issue. Prefer to keep it private,
contact the repository owner through their GitHub profile — there is no secret
consumer here to protect, but discretion about people's career data is
respected.

## Threat model notes for maintainers

- **The `.gitignore` is not the boundary.** `clients/` is protected twice: it is
  ignored, and `scripts/pre-publish-check.sh` refuses to let a tracked file
  whose path matches a real workspace slip through. A future PR that removes the
  gitignore entry is a security change; treat it as such in review.
- **`scripts/denylist.local.txt` contains real personal terms and is
  gitignored.** Committing it is the single worst thing a PR can do. The check
  itself is written so the deny files self-exclude, but reviewers should watch
  for a PR that accidentally `git add` it.
- **Generated PDFs of real people are never committed.** Exactly one PDF is
  sanctioned: the fictional example's `Master-CV.pdf`.
- The only runtime dependency is `pypdf` (pure Python, no compiled component).

## Scope

Vulnerabilities in headless Chrome, the AI coding agent a user chooses to pair
this with, or any operating-system component are out of scope for this
repository.
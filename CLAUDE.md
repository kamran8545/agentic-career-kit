# Claude Code

@AGENTS.md

## Skills

The five skills live in `.opencode/skills/` and are linked at `.claude/skills/`
so Claude Code loads them automatically:

- `candidate-intake` — interview a new user and build their profile, one question at a time
- `job-posting-analysis` — decide whether to apply; surface the keyword gaps
- `cv-update` — build or tailor a CV, then render and verify it
- `cover-letter-writer` — write the matching cover letter
- `ats-resume-audit` — audit a CV for ATS parseability and content

If a skill does not appear under `/`, open the matching
`.opencode/skills/<name>/SKILL.md` and follow it directly. The full project
rules are in `AGENTS.md`, imported at the top of this file.

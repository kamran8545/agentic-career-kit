# Worked example — a fictional candidate

A complete, runnable example. **Alex Rivera is invented.** Every company, figure,
and link is made up to demonstrate the format without exposing a real person.

It serves two purposes:

1. **A worked reference.** See what "filled in properly" looks like before
   writing your own profile.
2. **A smoke test.** If this renders and verifies on your machine, the toolchain
   works. If it does not, something is broken in your setup rather than in your
   CV.

## Run it

```bash
scripts/render.sh   examples/fictional-candidate/out/Master-CV.html \
                    /tmp/example.pdf
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
template.

## Why the expected numbers are what they are

**2 pages** — the default layout. Page 1 carries the header, summary, skills and
the two most recent roles; page 2 the rest.

**7 links** — two contact links (phone, email), two profile links (LinkedIn,
GitHub), two project links, and one publication link. All are real `<a href>`
elements, which is why they survive as clickable PDF annotations. A CV with a
projects section and zero link annotations means the anchors were lost.

**0 ligatures, 0 placeholders** — the two silent failures. Both are invisible on
screen and fatal to an application. See `docs/ATS-EXTRACTION.md`.

## Files

| Path | What it is |
| --- | --- |
| `profile/candidate-profile.md` | The filled-in profile — the source of all data |
| `out/Master-CV.html` | The CV built from it, carrying the load-bearing CSS |
| `out/Master-CV.pdf` | Rendered output, committed so users can inspect it |
| `out/Master-CL.md` | The matching cover letter, written against a made-up posting |
| `report/verification-sample.md` | The verification report — the artifact you would send with a real deliverable |

`out/Master-CV.pdf` is the only PDF committed to this repository. Every other
generated file is gitignored, because every other generated file belongs to a
real person.

## Using it as a starting point

**Read it, then write your own.** Do not edit Alex Rivera into yourself — you
will inherit fictional numbers, and the whole point is that every number in a CV
must be provable.

```bash
cp .opencode/context/candidate-profile.template.md \
   .opencode/context/candidate-profile.md
```

The example deliberately sits in a different field from most software CVs, which
is the point: the template is not secretly software-shaped. If you contribute an
example in another field, a healthcare or teaching CV would be especially useful.

## The verification report

`report/verification-sample.md` is the format used for real deliverables. It
goes to the client next to the PDF, and it is the reason this project exists —
it turns "trust me, it parses" into a check anyone can run.

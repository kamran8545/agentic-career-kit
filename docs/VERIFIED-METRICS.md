# Verified metrics

The rule this project will not bend:

> **Only use a number the candidate can prove.**

A metric on a CV is a promise. It is an invitation to an interviewer to ask
"how did you measure that?" and "what was the baseline?" A fabricated number is
not a small inaccuracy — it is the moment the interviewer stops believing
everything else on the page. It costs the candidate the role, and it is
unrecoverable.

## The three acceptable sources

**1. Publicly verifiable, right now.**
App store download counts, star ratings, review counts, public repository stats,
published company figures. Anyone can check these in ten seconds, which is
exactly why they are safe.

**2. From a system the candidate controlled.**
An analytics dashboard, a server log, a build pipeline report, a database query,
a ticket queue count. They measured it themselves and can walk through the method.

**3. Attributable to a named source.**
A press release, a published case study, a status page. Note the source in the
profile so it can be re-checked later.

## The three unacceptable sources

- **Estimates.** "Roughly doubled" without a measurement. Either go measure it or
  write the achievement without a number.
- **Team numbers presented as personal.** A 40% revenue lift that the whole
  department produced is not that candidate's 40% lift.
- **Anything from a CV the candidate has not personally checked.** If the
  previous version of a CV contained a number they cannot source, it is
  unverified regardless of how long it has been there.

## The awkward cases

**"Improved performance" with no number.**
Write it without one. `Rebuilt the reporting query, cutting dashboard load time`
is honest and still strong. A weak true claim beats a strong invented one.

**They genuinely do not know.**
Put it in the profile's TODO list and ask. Do not fill the gap during
tailoring. The interview will surface it, and the CV should not be the place
where it is discovered.

**Confidential figures.**
An NDA may forbid publishing a number the candidate legitimately earned. Write
the achievement qualitatively and keep the figure in the profile as internal
context.

**Percentages without a baseline.**
"Reduced costs 30%" needs "of what". "Cut infrastructure spend 30% year over
year" is defensible. "Reduced costs 30%" is a guess with a decimal point.

## Recording it in the profile

Put the number in the candidate profile **with its source**, so it survives:

```markdown
### Acme Corp — Engineer — Jan 2021 – Dec 2023
- **Numbers:** nightly job 6h → 25min (own Grafana dashboard, 3-month median);
  40+ dashboards (counted in the internal catalogue)
```

The parenthetical is doing real work. Six months from now, when someone asks
"where did 25 minutes come from?", the answer is in the file instead of in a
half-remembered Slack thread.

## Flag, do not fix

If a CV contains an unverifiable number, the correct action is to **flag it**, not
to quietly delete or quietly keep it:

```
BLOCKER  "reduced costs 30%" (Master-CV.html:142) — no baseline, no source in
         the profile. Ask the candidate for the measurement or remove the figure.
```

Deleting it silently teaches the candidate nothing and leaves the same number in
the next draft. Flagging it gets fixed once.

## What the recruiter rubric does with this

`ats-resume-audit` scores content quality partly on whether every bullet carries
a number **where one honestly exists**. It does not reward invented numbers, and
it explicitly reports bullets that *could* carry a number but do not — those are
the ones worth asking the candidate about.

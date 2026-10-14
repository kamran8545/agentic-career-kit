# Drop your existing resume here

Put a **PDF** of your current resume (or CV) in this folder, then open the repo
in your AI agent and say:

> **Build my resume.**

The agent reads the PDF, pre-fills as much of `candidate-profile.md` as it can,
shows you what it found, and then asks only for what is missing — one question
at a time.

**Requirements**

- **PDF only, and it must contain real text.** A PDF that is a photo or a scan of
  a printed page has no selectable text. Reading that would need OCR, which this
  repo deliberately does not depend on. If the agent reports it cannot read your
  file, export a text-based PDF from the app that made it, or answer the
  questions instead.
- **What you drop here is yours.** This folder is gitignored. Nothing in it is
  committed, uploaded, or sent anywhere.
- **Nothing here is treated as proven.** The agent copies facts out of your
  resume into the profile, but you confirm them, and it will ask how any number
  was measured — a figure you cannot defend in an interview is worse than none.

Done with a file? Delete it, or leave it — the folder is local and ignored.

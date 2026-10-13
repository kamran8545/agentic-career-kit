# Why the CSS looks the way it does

A CV that renders perfectly in a browser can be **unreadable** to the applicant
tracking system that decides whether a human ever sees it. The application dies
silently and you find out weeks later, when nothing comes back.

Almost all of that damage comes from three CSS decisions. They look like
innocuous styling. They are load-bearing, and this file explains why so nobody
"cleans them up" later.

---

## 1. Ligatures corrupt keywords

```css
body {
  font-variant-ligatures: none;
  font-feature-settings: "liga" 0, "clig" 0, "dlig" 0, "hlig" 0;
}
```

Many system fonts substitute a single glyph for two letters. In Helvetica and
Arial, `fi` renders as **one character** (U+FB01, `ﬁ`).

On screen, this is invisible — or rather, it is the *correct* typography. It is
a ligature, it looks better, and no human reader notices.

But PDF text extraction is not a human reader. When the PDF's internal text layer
is built, that single `ﬁ` character is what gets stored. A keyword-matching ATS
searching for `Config` never finds `Conﬁg`. The candidate's most important
keyword — the framework they are famous for — silently disappears from their CV.

The same applies to `fl`, `ff`, `ffi`, `ffl`, `st`.

`verify_pdf.py` checks for U+FB00–U+FB06 and reports the exact codepoints.

> **Do not remove these two declarations to "fix" the typography.** If you need a
> different font, pick one without ligatures or keep the declarations.

---

## 2. `::before` bullets eat the first one

This is the one that scrambles your CV.

The natural way to add bullets to a list is CSS:

```css
ul { list-style: none; }
li::before { content: "• "; }        /* looks perfect */
```

Extracted from the rendered PDF, this produces:

```
Applications Engineer
• Improved reporting
• Rebuilt the pipeline
• Cut page load
```

The first bullet is no longer a list item — it reads as part of the preceding
line, because the glyph was painted by a pseudo-element rather than being real
text content. Depending on the extractor it may vanish, or it may be attributed
to the wrong line. Either way the **order and attribution of your bullets is now
wrong**, which is worse than a missing bullet, because a recruiter reading the
extracted text sees a job title attached to your first accomplishment.

**The fix is to make the glyph real text:**

```html
<ul>
  <li>&bull; Improved reporting</li>
  <li>&bull; Rebuilt the pipeline</li>
</ul>
```

The `&bull;` entity is part of the `<li>`'s text content, so it survives
extraction, stays attached to the right line, and keeps the order intact.

`ul { list-style: none; }` stays in the CSS so the browser does not *add* a
second bullet. You want exactly one glyph, supplied by the markup.

---

## 3. Chrome's print header corrupts everything

Chrome's headless PDF export stamps the file path and a generation date into the
page margins **by default**:

```
…/Downloads/My-CV.pdf                                            28/09/2026
```

This is the single most common cause of a broken CV in automated pipelines,
because it appears at the top and bottom of *every* page, injecting the
author's local username into the document.

```bash
--no-pdf-header-footer      # render.sh already does this
```

If you ever invoke Chrome yourself, do not omit it.

---

## 4. Two columns scramble reading order

Multi-column layouts are visually attractive and a parsing nightmare. PDF text
extraction is a linear stream. A two-column CV produces text in a reading order
the recruiter never asked for — the entire left column, then the entire right
column, regardless of which section came first visually.

Single column. Always. If a layout needs visual interest, get it from the
header and section rules.

---

## 5. Body text below 10pt is self-defeating

The tempting move when a CV runs to three pages is to shrink the font. Do not.

At 6–7pt the CV is technically complete and practically unreadable for the
human who finally opens it. It also signals carelessness, which is the first
thing a recruiter infers about the candidate's work.

**Two pages at 10pt beats one page at 6pt, every time.** To fit:

- Cut the weakest role. Do not compress it.
- Cut a project that has no link and no number.
- Delete a skills row you cannot discuss in an interview.

Removing real content is better than shrinking real content.

---

## Verify, do not assume

```bash
scripts/render.sh   out/My-CV.html out/My-CV.pdf
scripts/verify_pdf.py out/My-CV.pdf --pages 2
```

`verify_pdf.py` checks: ligature codepoints, unfilled placeholders, page count,
link annotation count, and per-page text volume. It cannot tell you whether your
CV is *good*. It can tell you whether your CV is *readable*, which is the part
people get wrong.

Ship the output. It is the only part of this you cannot check by looking.

#!/usr/bin/env python3
"""verify_pdf.py — prove a rendered CV actually survives ATS text extraction.

    scripts/verify_pdf.py <file.pdf> [--pages 2] [--expect-links 0]

Checks, in order of how badly they break an application:

  1. LIGATURES   extracted text contains U+FB00-FB06 glyphs. These are the single
                 most common ATS corruption ("Conﬁg" instead of "Config") and
                 are caused by fonts, not by the CV author.
  2. PLACEHOLDERS  leftover {{...}} or [...]-style markers shipped by mistake.
  3. PAGES       wrong page count (wrong for your layout = truncated content).
  4. LINKS       real <a href> links became clickable PDF annotations. Zero
                 links on a CV with projects usually means the anchors were lost.
  5. TEXT        a page that extracts to almost nothing means a layout collapse.

Exit code 0 = clean, 1 = one or more failures. Designed to be run on every
deliverable before it is sent to a client or an employer.
"""

import argparse
import re
import sys

try:
    from pypdf import PdfReader
except ImportError:
    sys.exit(
        "error: pypdf is required to verify a PDF, but it is not installed.\n"
        "  macOS/Linux/WSL:  python3 -m pip install pypdf\n"
        "  Windows:          py -m pip install pypdf\n"
        "  diagnose setup:   scripts/check-setup.sh"
    )

LIGATURES = {
    "\ufb00": "ff", "\ufb01": "fi", "\ufb02": "fl", "\ufb03": "ffi",
    "\ufb04": "ffl", "\ufb05": "st", "\ufb06": "st",
}
# {{...}} is the canonical marker, always caught. The [Bracket] form is a
# heuristic for agent-written placeholders like [Target Title] or [COMPANY];
# it deliberately does not match a single Title-Case word, so real CV tags such
# as [Remote] or [Hybrid] do not trigger a false failure.
PLACEHOLDER = re.compile(
    r"\{\{[^}]{1,60}\}\}"
    r"|\[(?:[A-Z]{2,}|[A-Z][a-z]+(?: [A-Z][a-z]+)+)\]"
)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("--pages", type=int, default=None,
                    help="exact expected page count")
    ap.add_argument("--expect-links", type=int, default=None,
                    help="exact expected link-annotation count")
    ap.add_argument("--min-chars-per-page", type=int, default=200)
    args = ap.parse_args()

    try:
        reader = PdfReader(args.pdf)
    except Exception as exc:                                   # noqa: BLE001
        print(f"FAIL  cannot read PDF: {exc}")
        return 1

    pages = reader.pages
    text = "\n".join(p.extract_text() or "" for p in pages)
    links = sum(len(p.get("/Annots", []) or []) for p in pages)

    failures, warnings = [], []

    # 1. ligatures
    found = sorted({c for c in text if c in LIGATURES})
    if found:
        names = ", ".join(f"U+{ord(c):04X} ({LIGATURES[c]})" for c in found)
        failures.append(
            f"ligature corruption: {len(found)} distinct glyph(s) — {names}\n"
            "       fix: keep font-variant-ligatures:none and "
            "font-feature-settings:\"liga\" 0 in the CSS"
        )

    # 2. placeholders
    hits = sorted(set(PLACEHOLDER.findall(text)))
    if hits:
        failures.append(
            f"unfilled placeholders: {len(hits)} — "
            + ", ".join(repr(h) for h in hits[:8])
        )

    # 3. page count
    if args.pages is not None and len(pages) != args.pages:
        failures.append(
            f"page count: expected {args.pages}, got {len(pages)}"
        )

    # 4. link annotations
    if args.expect_links is not None and links != args.expect_links:
        failures.append(
            f"link annotations: expected {args.expect_links}, got {links}"
        )
    elif links == 0 and len(text) > 500:
        warnings.append(
            "no link annotations found — if this CV lists projects with URLs, "
            "the <a href> tags did not survive rendering"
        )

    # 5. per-page text volume
    for i, page in enumerate(pages, 1):
        n = len((page.extract_text() or "").strip())
        if n < args.min_chars_per_page:
            failures.append(
                f"page {i} extracts only {n} chars "
                f"(expected >= {args.min_chars_per_page}) — layout collapsed?"
            )

    print(f"file    {args.pdf}")
    print(f"pages   {len(pages)}")
    print(f"chars   {len(text.strip())}")
    print(f"links   {links}")
    print()

    for w in warnings:
        print(f"WARN  {w}")
    for f in failures:
        print(f"FAIL  {f}")

    if failures:
        print(f"\n{len(failures)} check(s) failed — do not send this file.")
        return 1

    print("PASS  all checks clean — safe to send.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

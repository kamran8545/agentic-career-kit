#!/usr/bin/env python3
"""extract_resume.py — read an existing resume PDF so an agent can pre-fill the profile.

    scripts/extract_resume.py <file.pdf> [--out <file.txt>]

Writes the PDF's text so the candidate-intake skill can map it into
candidate-profile.md and ask only the questions the file does not already
answer. Kept to the same single dependency as everything else: pypdf.

What it handles on purpose:

  1. LIGATURES   a resume exported from a tool that fuses "fi"/"fl" leaves
                 U+FB00-FB06 glyphs in the text. They are folded back to plain
                 ASCII here so a keyword like "Config" is not read as "Conﬁg".
  2. PAGES       text is extracted page by page and joined with a marker, so
                 roles can be read in reading order across a two-page CV.
  3. SCANNED     a PDF with no extractable text is almost always a scan of a
                 printed page (an image). OCR is deliberately out of scope — it
                 needs a new dependency this repo does not take. The tool says
                 so plainly and points at the two ways forward.

Exit code 0 = text extracted, 2 = no usable text (scanned/encrypted/empty),
1 = the file could not be read at all.

This tool reads and reports. It never writes the profile — the agent does that,
from the text, fact by fact.
"""

import argparse
import sys

try:
    from pypdf import PasswordType, PdfReader
except ImportError:
    sys.exit(
        "error: pypdf is required to read a resume PDF, but it is not installed.\n"
        "  macOS/Linux/WSL:  python3 -m pip install pypdf\n"
        "  Windows:          py -m pip install pypdf\n"
        "  diagnose setup:   scripts/check-setup.sh"
    )

# Same offsets verify_pdf.py reports as corruption. Here we repair them in
# place: a font that emitted a ligature is not a reason to lose the keyword.
LIGATURES = {
    "\ufb00": "ff", "\ufb01": "fi", "\ufb02": "fl", "\ufb03": "ffi",
    "\ufb04": "ffl", "\ufb05": "st", "\ufb06": "st",
}

# Below this many stripped characters, the "text" is almost certainly an image
# scan or a handful of stray glyphs rather than a resume.
MIN_USABLE_CHARS = 200


def normalise(text: str) -> str:
    for glyph, plain in LIGATURES.items():
        text = text.replace(glyph, plain)
    return text


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("pdf", help="the resume PDF to read")
    ap.add_argument(
        "--out", default=None,
        help="write text here instead of printing it ('-' also means stdout)",
    )
    ap.add_argument(
        "--min-chars", type=int, default=MIN_USABLE_CHARS,
        help="below this many extracted characters, treat the PDF as scanned",
    )
    args = ap.parse_args()

    try:
        reader = PdfReader(args.pdf)
    except Exception as exc:                                   # noqa: BLE001
        print(f"FAIL  cannot read PDF: {exc}")
        return 1

    if reader.is_encrypted:
        # An empty password covers PDFs that are encrypted but not meant to be
        # locked (common from some exporters). A real password leaves us here.
        if reader.decrypt("") == PasswordType.NOT_DECRYPTED:
            print(
                "FAIL  this PDF is password-protected and cannot be read.\n"
                "       fix: export an unprotected copy from the app that made it,\n"
                "            or answer the intake questions instead."
            )
            return 2

    try:
        pages = reader.pages
        page_count = len(pages)
    except Exception as exc:                                   # noqa: BLE001
        print(f"FAIL  cannot read the PDF's pages: {exc}")
        return 1

    if page_count == 0:
        print("FAIL  the PDF has no pages.")
        return 2

    chunks = []
    content_chars = 0
    for i, page in enumerate(pages, 1):
        text = normalise(page.extract_text() or "").strip()
        if text:
            content_chars += len(text)
            chunks.append(f"----- page {i} -----\n{text}")
    stripped = "\n\n".join(chunks).strip()

    # Count only the page text, never the page markers we added — otherwise a
    # near-empty scan could cross the threshold on marker characters alone.
    if content_chars < args.min_chars:
        print(
            f"FAIL  only {content_chars} characters extracted from {len(pages)} "
            "page(s).\n"
            "       This is almost always a scanned image of a printed page, not\n"
            "       selectable text. Reading it would need OCR, a dependency this\n"
            "       repo does not take.\n"
            "       fix: export a text-based PDF (or a .txt) from the app that\n"
            "            made it, or answer the intake questions instead."
        )
        return 2

    if args.out and args.out != "-":
        try:
            with open(args.out, "w", encoding="utf-8") as fh:
                fh.write(stripped + "\n")
        except OSError as exc:
            print(f"FAIL  cannot write {args.out}: {exc}")
            return 1
        print(f"wrote   {args.out}")
        print(f"pages   {len(pages)}")
        print(f"chars   {content_chars}")
        print()
        print("next: read this file into candidate-profile.md, then ask the")
        print("      candidate only the questions it does not answer.")
    else:
        print(stripped)

    return 0


if __name__ == "__main__":
    sys.exit(main())

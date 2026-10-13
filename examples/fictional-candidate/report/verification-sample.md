# Verification report — Alex Rivera (fictional example)

Produced by `scripts/verify_pdf.py`. This is the file that accompanies every
deliverable: it is the evidence that the CV survives ATS text extraction.

```
file    examples/fictional-candidate/out/Master-CV.pdf
pages   2
chars   3000
links   6

PASS  all checks clean — safe to send.
```

## What was checked

| Check | Result | Why it matters |
| --- | --- | --- |
| Ligatures (U+FB00–FB06) | 0 found | Prevents `Conﬁg`-style corruption in extracted text |
| Unfilled placeholders | 0 found | `{{...}}` left in a sent CV reads as unfinished |
| Page count | 2 of 2 | Truncation silently drops the weakest half of a CV |
| Link annotations | 6 present | Real `<a href>` links survive as clickable PDF links |
| Text per page | ~1,500 chars avg | A near-empty page means the layout collapsed |

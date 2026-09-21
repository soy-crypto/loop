#!/usr/bin/env python3
"""Collect every tracked source file into one printable HTML page."""

import html
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "print.html"

# Order the sections so the page reads like the study plan, not like `ls`.
ORDER = ["README.md", "LOOP.md", "toy-ir/", "llvm-pass/", "mlir-pass/", "cpp/", "kernels/"]
SKIP = {".gitignore", "make_print.py", OUT.name}

CSS = """
body { font-family: Georgia, serif; font-size: 12pt; line-height: 1.45;
       max-width: 7.2in; margin: 0 auto; padding: 0.4in 0; color: #111; }
h1 { font-size: 20pt; margin: 0 0 4pt; }
h2 { font-size: 14pt; margin: 22pt 0 6pt; padding-bottom: 3pt;
     border-bottom: 1.5pt solid #111; page-break-after: avoid; }
pre { font-family: "DejaVu Sans Mono", Consolas, monospace; font-size: 8.5pt;
      line-height: 1.3; background: #f6f6f6; border: 0.5pt solid #ccc;
      padding: 7pt 9pt; white-space: pre-wrap; word-wrap: break-word; }
.meta { color: #555; font-size: 10pt; margin-bottom: 14pt; }
nav { font-size: 10pt; margin-bottom: 18pt; }
nav a { color: #111; text-decoration: none; }
nav li { margin: 2pt 0; }
@media print {
  nav { display: none; }
  h2 { page-break-after: avoid; }
  pre { page-break-inside: avoid; }
}
"""


def tracked_files():
    out = subprocess.run(
        ["git", "ls-files"], cwd=ROOT, capture_output=True, text=True, check=True
    )
    files = [f for f in out.stdout.split() if f not in SKIP]

    def key(path):
        for i, prefix in enumerate(ORDER):
            if path == prefix or path.startswith(prefix):
                return (i, path)
        return (len(ORDER), path)

    return sorted(files, key=key)


def main():
    files = tracked_files()
    parts = [
        "<!doctype html><html><head><meta charset='utf-8'>",
        "<title>loop — all files</title>",
        f"<style>{CSS}</style></head><body>",
        "<h1>loop</h1>",
        f"<p class='meta'>{len(files)} files from "
        "<a href='https://github.com/soy-crypto/loop'>github.com/soy-crypto/loop</a>. "
        "Print with Ctrl+P.</p>",
        "<nav><ol>",
    ]
    for f in files:
        anchor = f.replace("/", "-").replace(".", "-")
        parts.append(f"<li><a href='#{anchor}'>{html.escape(f)}</a></li>")
    parts.append("</ol></nav>")

    for f in files:
        anchor = f.replace("/", "-").replace(".", "-")
        text = (ROOT / f).read_text(encoding="utf-8", errors="replace")
        parts.append(f"<h2 id='{anchor}'>{html.escape(f)}</h2>")
        parts.append(f"<pre>{html.escape(text)}</pre>")

    parts.append("</body></html>")
    OUT.write_text("\n".join(parts), encoding="utf-8")
    print(f"wrote {OUT} ({len(files)} files)")


if __name__ == "__main__":
    main()

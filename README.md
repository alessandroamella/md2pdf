# md2pdf

A simple bash script to convert Markdown files to professional PDF documents using Pandoc and the Eisvogel template.

## What it does

Converts Markdown to nicely formatted PDFs. It's perfect for quickly generating documents (e.g. quotes, invoices, reports, notes) without the hassle of setting up LaTeX from scratch. The result is still professional and clean.

The script even supports embedded LaTeX for math equations!

## Requirements

- `pandoc`
- `xelatex` (usually from TeX Live)
- [Eisvogel template](https://github.com/Wandmalfarbe/pandoc-latex-template)
- Fira Sans font

## Usage

```bash
./md2pdf.sh [options] <input_file>
```

The options can be shown using the `-h` or `--help` flag. I won't write them here, as I may change them and forget to update this README.

### Examples

```bash
# Basic conversion - the footer will contain personal info
./md2pdf.sh document.md

# Anonymous PDF with table of contents
./md2pdf.sh --anonymous --toc proposal.md

# With Italian TOC
./md2pdf.sh -t -l italian preventivo.md
```

## Features

- Auto-formats filename as document title in Start Case (e.g., `my-document.md` -> "My Document")
- Professional formatting with Eisvogel template
- Clickable links in blue
- Optional customizable footer
- Chapter-level organization
- LaTeX math support for equations

## Output

Creates a PDF with the same name as your input file (e.g., `document.md` -> `document.pdf`)

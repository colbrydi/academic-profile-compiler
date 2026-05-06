# academic-profile-compiler

A data-first system for compiling academic profiles from structured sources into CVs, PDFs, and websites.

***NOTE:*** This project is a work in progress. I am developing it with AI so use at your own risk.

---

## Motivation

Academic CVs do not scale well when maintained as monolithic documents (for example, Word files). Over time they tend to become:

- Large and fragile
- Difficult to reorganize for different audiences
- Redundant, with the same information listed multiple times
- Hard to version, audit, or refactor

This repository implements a data-first approach to academic CVs and profiles:

- Store canonical academic information in structured, plain-text formats
- Generate multiple profile views from the same data
- Render high-quality PDFs using LaTeX
- Support additional outputs such as static websites
- Keep everything version-controlled in Git

Rather than treating a CV as a static document, this project treats it as a compiled artifact.

---

## Core Concept

Separate content from presentation.

Canonical data → Renderers → Outputs

- Canonical data describes what you have done
- Renderers decide how to organize and format it
- Outputs include PDFs, web pages, or other representations

This makes it possible to reorganize, filter, regroup, and restyle your academic record without rewriting content.

---

## Design Principles

1. Data first, documents second
2. No duplicated content
3. Support overlapping categories
   - Ex. A publication may belong to AI, HPC, and Teaching
4. Use established scholarly tools where they fit
   - BibTeX / Zotero for publications
5. Plain text, inspectable, and version-controlled
6. Designed for long academic careers
7. Extensible to external scholarly systems (e.g., ORCID)

---

## Content Types and Canonical Formats

This project intentionally uses multiple plain-text formats, each for what it does best.

Rule of thumb:

- If it needs citation semantics → use BibTeX
- If it needs slicing, filtering, or regrouping → use JSON
- If it needs narrative prose → use Markdown

| Content type                     | Canonical format | Rationale |
|----------------------------------|------------------|-----------|
| Publications                     | BibTeX           | Scholarly citation standard |
| Student posters / student work   | BibTeX           | Publication-like outputs |
| Projects                         | JSON             | Multi-category entities |
| Talks & presentations            | JSON             | Group by talk type |
| Teaching                         | JSON             | Avoid repeated course listings |
| Service & awards                 | JSON             | Flexible grouping |
| Narrative sections               | Markdown         | Human-authored prose |

---

## Repository Layout

```
academic-profile-compiler/
├── data/                # Canonical structured data
│   ├── publications.bib
│   ├── student_work.bib
│   ├── projects.json
│   ├── talks.json
│   ├── teaching.json
│   └── service.json
│
├── content/             # Narrative sections (Markdown)
│   ├── overview.md
│   ├── research_summary.md
│   ├── teaching_statement.md
│   └── mentoring.md
│
├── renderers/           # Output templates
│   ├── latex/
│   │   ├── templates/
│   │   │   ├── main.tex
│   │   │   └── sections/
│   │   └── style/
│   │       └── cv.sty
│   └── web/
│       ├── templates/
│       └── assets/
│
├── scripts/             # Rendering glue (Python)
│   ├── render_latex.py
│   ├── render_web.py
│   └── render_all.py
│
├── build/               # GENERATED outputs (safe to delete)
│   ├── latex/
│   │   ├── generated/
│   │   └── cv.pdf
│   └── web/
│       └── index.html
│
├── README.md
└── LICENSE
```

---

## Markdown Narrative Sections

Markdown files provide a home for narrative content that does not benefit from rigid schema structure.

Examples include:

- Overview / profile summary
- Research summary
- Teaching philosophy (short form)
- Mentoring philosophy
- Program descriptions
- Contextual introductions to CV sections

Markdown files are:

- Single-purpose
- Human-authored
- Rendered as a whole (not filtered or sliced)

They are consumed by renderers but never modified by them.

---

## LaTeX Rendering Strategies

This project supports two LaTeX workflows using the same canonical data.

### Option A — Python Preprocessing (Default)

JSON / BibTeX / Markdown → Python → LaTeX fragments → PDF

- Python scripts read JSON, BibTeX, and Markdown
- Markdown is converted to LaTeX
- Section-level .tex files are generated
- main.tex includes them via \\input{}

Advantages:
- Explicit and debuggable
- Easy to document and extend
- Natural support for websites and other outputs
- Clean integration with Overleaf

This is the recommended starting point.

---

### Option B — LuaLaTeX (Experimental)

JSON / Markdown → LuaLaTeX → PDF

- LaTeX reads JSON and Markdown using embedded Lua
- No preprocessing step

Advantages:
- Single-step compilation
- Everything runs inside LaTeX / Overleaf

Tradeoffs:
- More complex TeX/Lua logic
- Harder to debug
- Less reusable outside LaTeX

LuaLaTeX support is optional and experimental.

---

## Publications and Student Work

Publications and student posters are managed in Zotero and exported as BibTeX.

- Student work is treated as publication-like
- Tags and custom fields distinguish:
  - Peer-reviewed vs non-peer-reviewed
  - Student work vs faculty publications
  - Research domains

LaTeX and renderers control grouping and presentation.

---

## Multiple Profile Outputs

From the same canonical data, this system can generate:

- Full academic CV
- Research-focused CV
- Teaching-focused CV
- Grant or annual review variants
- Static websites

No content duplication is required.

---

## External Scholarly Systems (Future Work)

This architecture is designed to support optional ingestion from systems such as:

- ORCID
- Institutional systems
- Other scholarly APIs

External systems are treated as inputs, not sources of truth.
Canonical data remains local, reviewable, and version-controlled.

---

## Status

This repository is a working template and evolving framework.

Planned milestones:
- Finalize JSON schemas
- Core Python renderers
- BibTeX filtering patterns
- LuaLaTeX prototype
- Static website output
- Example academic profiles

---

## Who This Is For

- Faculty and research staff
- Long or evolving academic careers
- Anyone tired of Word-based CVs
- People who want a single source of truth

---

## Contributing

This project is designed to be forked and adapted.

Contributions are welcome, especially for:
- Discipline-specific conventions
- Additional schemas
- New output formats
- Documentation improvements

---

## License

[MIT License](LICENSE.md)



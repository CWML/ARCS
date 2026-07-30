# ARCS — Advancing Reproducibility with Computational Skills

A four-part workshop series that teaches R programming and reproducible research
practice together, from a first `<-` assignment to a containerized RNA-seq
pipeline. Part of the ARCS initiative at the Yale Medical Library.

The repository is a [Quarto](https://quarto.org) website. Sources live in
`workshops/`; the rendered site is committed to `docs/` for GitHub Pages.

## The series

Every session is two hours, split into two one-hour lessons. All four parts use
the same dataset (GSE113754 — Shank3 vs. wild-type mouse RNA-seq), so the
project a learner builds in Part 1 is the project they containerize in Part 4.

| Part | Lessons | What you leave with |
|---|---|---|
| **1** | [Fundamentals of R](workshops/arcs_01/01-fundamentals.qmd) · [Project Management](workshops/arcs_01/02-projects.qmd) | Objects, vectors, data frames; an `renv`-backed R Project with a documented folder structure |
| **2** | [Data Structures](workshops/arcs_02/03-structures.qmd) · [Reports](workshops/arcs_02/04-reports.qmd) | Importing, inspecting, cleaning and harmonizing data; literate reports rendered with Quarto |
| **3** | [Tidyverse](workshops/arcs_03/05-tidyverse.qmd) · [Git & Version Control](workshops/arcs_03/06-git.qmd) | `rio`/`here`/`dplyr` cleaning pipelines; a local repo published to GitHub |
| **4** | [DESeq2](workshops/arcs_04/07-deseq2_pipeline.qmd) · [Apptainer](workshops/arcs_04/08-apptainer.qmd) | A scripted differential-expression pipeline, then the same pipeline run from inside a container |

Parts 1–3 embed runnable R directly in the page via
[webR](https://docs.r-wasm.org/webr/latest/) — no install needed to follow
along. Part 4 is the capstone and is documented in detail in
[`workshops/arcs_04/README.md`](workshops/arcs_04/README.md).

### Catching up

Learners who join late can reach the same state as the rest of the room:

- [`workshops/arcs_02/part-2-catch-up.R`](workshops/arcs_02/part-2-catch-up.R) — Part 1 content, as a runnable annotated script
- [`workshops/arcs_03/part-3-catch-up.R`](workshops/arcs_03/part-3-catch-up.R) — Parts 1–2
- [`workshops/arcs_03/part-3-setup-guide.md`](workshops/arcs_03/part-3-setup-guide.md) — software install + project setup checklist

## Software

R, [Positron](https://positron.posit.co/), Quarto, a GitHub account and
[GitHub Desktop](https://desktop.github.com/) (Windows users also need Git
Bash). Part 4's Apptainer hour additionally needs Codespaces access —
**Apptainer is Linux-only**, so that hour runs in a browser-based Linux
environment rather than on the learner's laptop.

## Repository layout

```
├── _quarto.yml            # site config: navbar, per-part sidebars, render list
├── index.qmd              # home page + session schedule
├── data/                  # raw GSE113754 counts and metadata
├── images/, video/        # slide and lesson assets
├── workshops/
│   ├── arcs_01 … arcs_03/ # lesson .qmd files, reveal.js slides, catch-up scripts
│   └── arcs_04/           # capstone; see its README
│       └── _materials/    # pipeline, container def, instructor guide (not rendered)
├── .devcontainer/         # Codespace for Part 4: installs Apptainer, pulls the image
├── .github/workflows/     # rebuilds & publishes the DESeq2 container image
└── docs/                  # rendered site (GitHub Pages)
```

The leading underscore on `_materials/` is deliberate — Quarto skips it, so the
pipeline and container files ship with the repo without publishing as pages.
Part 4's student-facing pages also exist as `*_codespaces.md` twins in plain
Markdown, which preview in VS Code without Quarto; the `.qmd` is canonical.

## Building the site

```bash
quarto preview        # live preview
quarto render         # writes to docs/
```

Package versions are pinned with `renv` — run `renv::restore()` after cloning.

## Credits

Developed for the Advancing Reproducibility with Computational Skills initiative
at the Yale Medical Library. Lesson and slide authorship is credited in the
individual `.qmd` files.

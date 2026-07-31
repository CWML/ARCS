# https://github.com/CWML/ARCS
# ARCS — Advancing Reproducibility with Computational Skills

A four-part workshop series that teaches R programming and reproducible research
practice together, from a first `<-` assignment to a containerized RNA-seq
pipeline. Part of the ARCS initiative at the Yale Medical Library.

The repository is a [Quarto](https://quarto.org) website, published at
**<https://cwml.github.io/ARCS/>**. Sources live in `workshops/`; the rendered
site is committed to `docs/` for GitHub Pages.

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

## The website

Every lesson linked above is also a page on <https://cwml.github.io/ARCS/>,
served by GitHub Pages from `docs/` on `main`. There is no build workflow — the
only GitHub Action here rebuilds the Part 4 container image. The site is
rendered locally and its output committed, so `docs/` has to be regenerated and
staged alongside any lesson edit:

```bash
quarto render     # builds the whole site into docs/
git add -A        # -A matters: a render also deletes stale hashed assets
```

Two things let that render succeed on any machine:

- **`_freeze/`** stores Part 4 Hour 1's executed output. That lesson runs a real
  DESeq2 analysis at render time, so without the cache a rebuild would need the
  full Bioconductor stack installed; with it, Quarto reuses the stored results
  and figures.
- **`engine: knitr`** is pinned on the webR lessons. They hold only `webr-r`
  cells and no knitr chunks, so Quarto would otherwise fall back to a Jupyter
  kernel and fail wherever one isn't installed.

To actually re-run Part 4 Hour 1 instead of reusing the cache, restore the R
environment first with `renv::restore()` — `freeze: auto` re-executes a document
only when its own source changes.



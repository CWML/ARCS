# ARCS Part 4 — Apptainer materials

Everything the Apptainer hour needs to run inside a Codespace. This folder
is named with a leading underscore so **Quarto ignores it** — nothing here
is rendered into the website.

> Building/running Apptainer requires **Linux**. In class that's a GitHub
> Codespace (the repo's `.devcontainer/` sets it up automatically). On a Mac
> or Windows laptop you cannot run these steps locally.

## Contents

```
_materials/
├── README.md              # this file
├── INSTRUCTOR_GUIDE.md    # run-of-show + prep/day-of checklists
├── TEACHING_NOTES.md      # slide-by-slide delivery notes for 08-slides.qmd
├── pipeline.R             # the DESeq2 pipeline (scaffold — see contract below)
├── container/
│   └── deseq2.def         # Apptainer definition for the analysis environment
├── data/
│   ├── counts.csv         # gene x sample count matrix (subset)
│   └── metadata.csv       # sample sheet
└── outputs/               # results land here when the pipeline runs
```

## What every Part 4 file is for

Part 4 spans three groups of files: the pages students read, the materials
they run, and the infrastructure that makes the Codespace work.

### Student-facing pages (`workshops/arcs_04/`)

Every page a student reads during class lives one level up, in two formats:
`.qmd` renders to the website and previews in **Positron**; `*_codespaces.md`
is plain Markdown that previews in **VS Code / Codespaces** without Quarto.
The `.qmd` is canonical — edit it first, then mirror the change.

| File | Role |
|---|---|
| `../07-deseq2.qmd` | **Hour 1** — DESeq2 on the host, in Positron. |
| `../08-apptainer.qmd` | **Hour 2** — the Apptainer walkthrough. Website + Positron. |
| `../08-apptainer_codespaces.md` | Hour 2, VS Code / Codespaces version. **This is what students follow in class.** |
| `../08-slides.qmd` | Reveal.js slides for Hour 2. Student-facing only — delivery notes live in [`TEACHING_NOTES.md`](TEACHING_NOTES.md). |
| `../09-build-your-own.qmd` | Appendix: self-paced guide to *authoring* a container. Website + Positron. |
| `../09-build-your-own_codespaces.md` | Same appendix, VS Code / Codespaces version. |

Only the `.qmd` files render — `_quarto.yml` has a `render:` list that skips
the `*_codespaces.md` twins so they don't publish as duplicate pages.

### Teaching materials (this folder)

Nothing here renders into the website — the leading underscore makes Quarto
skip the folder. Students run these files; they don't read them start to finish.

| File | Role |
|---|---|
| `INSTRUCTOR_GUIDE.md` | The runbook: one-time prep (build → smoke test → push to GHCR → make the package public) and day-of checks. Read before delivery, not during. |
| `TEACHING_NOTES.md` | Slide-by-slide delivery notes for `../08-slides.qmd`: what to emphasize, where to pause, what to cut if short on time. Keep open while presenting. |
| `README.md` | This file — orientation and the pipeline I/O contract. |
| `pipeline.R` | The analysis. Parameters block at the top (`PADJ`, `CONTRAST`) is what the live demo edits. |
| `container/deseq2.def` | The environment definition. Students *read* it in Step 4; nobody builds it in class. |
| `data/` | Prefiltered Shank3 subset, sized so a run finishes in under a minute. |
| `outputs/` | Empty except `.gitkeep`; the pipeline fills it. |

### Infrastructure

Set up once, then untouched during class.

| File | Role |
|---|---|
| `../../../.devcontainer/devcontainer.json` | Codespace spec. `"runArgs": ["--privileged"]` is load-bearing — without it `apptainer exec` fails with "Failed to create user namespace". |
| `../../../.devcontainer/setup.sh` | Runs on Codespace create: installs Apptainer, pulls the image to `~/deseq2.sif`. Contains a commented one-line swap to a GitHub Release if GHCR is unavailable. |
| `../../../.github/workflows/build-image.yml` | Rebuilds and republishes the image in CI. |

## How to use them

**Before class** — needs a Linux box; a Codespace works. Follow the one-time
prep in [`INSTRUCTOR_GUIDE.md`](INSTRUCTOR_GUIDE.md). The step that's easiest
to forget and most damaging to miss: make the GHCR package **public**.
Students pull with no login, so if it's private every Codespace fails during
setup. Then open a fresh Codespace and verify end to end.

**In class** — present `../08-slides.qmd` with
[`TEACHING_NOTES.md`](TEACHING_NOTES.md) open alongside it. Students open a Codespace from the
repo and follow
[`../08-apptainer_codespaces.md`](../08-apptainer_codespaces.md) in preview
mode while you drive the same steps on the projector. The one live edit is
`PADJ 0.05 → 0.01` in `pipeline.R`; re-run and watch the significant-gene
count drop.

**After class** — point people at
[`../09-build-your-own_codespaces.md`](../09-build-your-own_codespaces.md) in
the repo, or `../09-build-your-own.qmd` on the website. Same guide, two formats.

## Run it (inside a Codespace / on Linux)

```bash
cd workshops/arcs_04/_materials
apptainer exec ~/deseq2.sif Rscript pipeline.R
```

## Pipeline I/O contract

`pipeline.R` is currently a **runnable stand-in** so the Apptainer half works
end to end today. The DESeq2 instructor can drop their own pipeline in,
provided it keeps the same inputs and outputs. The container environment
(`deseq2.def`) ships R + DESeq2 + ggplot2; add packages there if the real
pipeline needs more.

**Inputs** (read from `data/`, paths relative to this folder):

| File | Shape |
|---|---|
| `data/counts.csv` | First column = gene id (`ENSMUSG…\|Symbol`), then one column per sample (`GSM…`). Raw integer counts. |
| `data/metadata.csv` | Columns: `sample_id` (matches count column names), `genotype` (`WT`/`Shank3`), `condition` (`normal`/`sleep_deprived`), `geno_cond`. A leading unnamed row-number column is fine. |

**Outputs** (written to `outputs/`):

| File | Contents |
|---|---|
| `outputs/deseq2_results.csv` | Full results table, one row per gene tested |
| `outputs/significant_genes.csv` | Genes passing the `PADJ` / `LFC` cutoffs |
| `outputs/pca_plot.png` | PCA of variance-stabilized counts |
| `outputs/volcano_plot.png` | Volcano plot of the contrast |

A console summary prints the **number of significant genes** — that's the
value the live "change a parameter and re-run" demo watches.

## Data provenance

`data/` is a low-count-prefiltered subset (genes with total count ≥ 10
across samples) of the cleaned Shank3 / GSE113754 mouse RNA-seq dataset from
ARCS Part 3 (`workshops/arcs_03/processed_data/`). Subsetting keeps the
in-class run under a minute; the full data is one folder away for anyone
scaling up afterward.

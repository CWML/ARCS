# ARCS Part 4 — Reproducible Pipelines and Containerization

**Part of the [Advancing Reproducible Computational Skills (ARCS)](../../index.qmd) workshop series.**

A single 2-hour capstone session in two halves. Learners build a real DESeq2
differential expression pipeline in R, then package it in an Apptainer container
so the *exact same pipeline* runs identically on any operating system. The two
halves share the same project, the same data, and the same results — the
container in hour 2 wraps the pipeline written in hour 1.

## Summary

If you want to make your entire analysis reproducible from raw data to final
report — on any machine — this workshop is for you. Building on the dataset and
skills from Parts 1–3, you will assemble your R code into a scripted,
end-to-end pipeline and package its computational environment using Apptainer
so the analysis runs identically for collaborators regardless of operating
system. Using a DESeq2 differential expression workflow as a working example,
this session connects reproducible coding practices to containerized, portable
research infrastructure.

## Format

| | |
|---|---|
| **Duration** | 2 hours, single session |
| **Hour 1 (07 — DESeq2)** | Local R Project in [Positron](https://positron.posit.co/) |
| **Hour 2 (08 — Apptainer)** | [GitHub Codespaces](https://github.com/features/codespaces) (browser-based Linux) |
| **Prerequisites** | ARCS Parts 1–3 (or equivalent comfort with R Projects, the tidyverse, and Git); GitHub account with Codespaces access |
| **Async follow-along** | The rendered Quarto pages ([07](07-deseq2_pipeline.qmd), [08](08-apptainer.qmd)) mirror the live session |

Hour 2 uses Codespaces because **Apptainer is Linux-only** — it doesn't run
natively on macOS or Windows. A browser-based Linux environment removes the
install burden and gives every learner an identical starting point.

## Learning objectives

By the end of the session, learners will be able to:

**Hour 1 — DESeq2 pipeline**

- **Execute** a DESeq2 differential expression pipeline on a shared RNA-seq dataset, producing a results table and diagnostic plot *(Apply)*
- **Organize** the analysis as a scripted, re-runnable pipeline inside an R Project *(Apply)*
- **Interpret** DESeq2 output (log2 fold change, adjusted p-values) in the context of the experimental design *(Analyze)*

**Hour 2 — Apptainer containerization**

- **Explain** how containerization addresses reproducibility problems caused by software and OS differences *(Understand)*
- **Differentiate** a host environment from a containerized environment, and identify when each is appropriate *(Analyze)*
- **Execute** the Hour 1 pipeline from *inside* a container on a Linux environment launched in the browser *(Apply)*
- **Modify** a pipeline parameter and re-run from the container to see the analysis produce a new, reproducible result *(Create)*

## Session structure

| Time | Segment | Environment |
|---|---|---|
| 0:00–0:10 | Framing: your code, someone else's machine | — |
| 0:10–0:55 | **Hour 1 — DESeq2.** Build the pipeline in an R Project; commit to GitHub | Positron (local) |
| 0:55–1:05 | Break / transition: *"Now let's prove it works on a machine that isn't yours"* | — |
| 1:05–1:20 | Launch Codespace; confirm Apptainer + pre-built `.sif` are present | Codespaces |
| 1:20–1:50 | **Hour 2 — Apptainer.** Re-run the same pipeline via `apptainer exec`; read the `.def`; change a parameter and re-run | Codespaces |
| 1:50–2:00 | Wrap-up: the repo is the reproducible artifact | — |

## Contents of this directory

```
arcs_04/
├── README.md                        # this file
├── 07-deseq2_pipeline.qmd           # Hour 1 lesson (Positron + R Project)
├── 07-setup_script.r                # Hour 1 package setup
├── 08-apptainer.qmd                 # Hour 2 lesson — website + Positron
├── 08-apptainer_codespaces.md       # Hour 2 lesson — VS Code / Codespaces twin
├── 09-build-your-own.qmd            # Self-paced appendix: authoring a container
├── 09-build-your-own_codespaces.md  # Same appendix, Codespaces twin
└── _materials/                      # not rendered — see its own README
    ├── processed_data/              # pipeline inputs
    ├── scripts/pipeline.R           # the Hour 1 analysis, as a script
    ├── container/deseq2.def         # Apptainer definition
    └── outputs/                     # results land here
```

Every student-facing page exists twice: a `.qmd` that renders to the website
and previews in Positron, and a `*_codespaces.md` twin in plain Markdown that
previews in VS Code without Quarto. The `.qmd` is canonical — edit it first,
then mirror. The Codespace config lives at the **repository root** in
`.devcontainer/`, not in this folder.

The pre-built DESeq2 image is published to a container registry and pulled
automatically when a learner opens the repo in Codespaces — they do not build
the image during class. The `.def` file is *read* in Hour 2, not edited;
authoring one is the self-paced `09` appendix.

## Design notes for instructors

- **Pre-built `.sif`, not live build.** Building DESeq2 + Bioconductor from scratch in class would consume 20–40 minutes and frequently fail. The Codespace `postCreateCommand` pulls the pre-built image so the first action of Hour 2 is `apptainer exec`.
- **"Modify," not "construct."** The Bloom's-level "Create" objective is hit by *editing a working pipeline parameter* — `PADJ`, or the condition being compared — and watching the result change, not by authoring a `.def` from scratch. Editing the definition would mean rebuilding, which is far too slow for a live session; that path is the self-paced `09` guide instead.
- **Codespaces only for Hour 2.** Hour 1 is pure R and runs identically on every OS in Positron. Codespaces shows up once, for the one thing that genuinely requires Linux, and the lesson is over.
- **Budget 5 minutes** at the top of Hour 2 for the slowest Codespace launches.

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
├── pipeline.R             # the DESeq2 pipeline (scaffold — see contract below)
├── container/
│   └── deseq2.def         # Apptainer definition for the analysis environment
├── data/
│   ├── counts.csv         # gene x sample count matrix (subset)
│   └── metadata.csv       # sample sheet
└── outputs/               # results land here when the pipeline runs
```

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

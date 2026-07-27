# Apptainer — in-Codespace walkthrough

> This is the Markdown twin of the website page
> (`workshops/arcs_04/08-apptainer.qmd`). Same content, readable from inside
> the Codespace so you don't have to switch back to Positron or the browser.
> **Right-click this file → _Open Preview_** for rendered text.

### By the end of this section, you should be able to...

- **Describe** how containerization solves reproducibility problems that
  come from software and operating-system differences
- **Differentiate** a *host* environment from a *containerized* environment,
  and say when each is appropriate
- **Execute** a multi-step DESeq2 pipeline *from inside* a container, on a
  Linux environment you launch in the browser
- **Modify** a parameter in the pipeline and re-run it to see the
  containerized analysis produce a new, reproducible result
- Connect the container to the Git workflow from Part 3: code, environment
  definition, and pipeline travel together as one reproducible artifact

---

## Why containers?

In Parts 1–3 you may have hit a familiar wall: code that runs on one
computer fails on another. A package version differs, an operating system
handles something differently, a dependency is missing. "It works on my
machine" is the opposite of reproducible research.

A **container** packages your *entire computing environment* — the R
installation, every package at a pinned version, the system libraries
underneath — into a single file. Anyone who runs that file gets exactly the
environment you built, regardless of what their own computer looks like.

We use **[Apptainer](https://apptainer.org/)**, a container system designed
for research and high-performance computing (HPC).

> **❗ The OS limitation *is* the lesson**
>
> Apptainer only runs on **Linux**. There is no Mac or Windows version.
>
> That sounds like a problem — but it's actually the whole point. The reason
> containers exist is that **the host operating system should not constrain
> what runs inside**. To use a container you still need a Linux kernel
> *somewhere*:
>
> - On a Mac or Windows laptop, that "somewhere" is the **GitHub Codespace**
>   you're reading this in.
> - On a research cluster, it's the **HPC login node**.
> - On a Linux laptop, it's just there.
>
> Once you cross into that Linux environment, the container behaves
> identically everywhere. That's reproducibility you can hand to a colleague.

---

## Host vs. container

| | **Host** environment | **Container** environment |
|---|---|---|
| What it is | Whatever R/packages are installed on the machine you're using | A fixed, pinned environment baked into an image file (`.sif`) |
| Who controls it | Each user, differently | Whoever wrote the definition file — *once*, for everyone |
| Reproducible? | Only if everyone matches versions by hand | Yes — same image = same environment, every time |
| When to use it | Quick interactive work, exploration | Sharing an analysis, publishing, running on HPC |

In Hour 1 you ran the DESeq2 analysis on your **host** (Positron on your own
laptop). Now you'll run the *same* analysis from a **container** — and get
the same answer, on a different operating system.

---

## Step 1 — Launch the Codespace

A **Codespace** is a Linux computer that runs in your browser. Opening one
from our workshop repository gives everyone — Mac, Windows, or Linux — the
*identical* environment.

1. Go to the workshop repository: **[github.com/CWML/ARCS](https://github.com/CWML/ARCS)**
2. Click the green **`< > Code`** button → **Codespaces** tab →
   **Create codespace on main**.
3. Wait for it to build. The first time, it automatically installs Apptainer
   and downloads our pre-built DESeq2 image — you'll see progress in the
   terminal.

> **💡 Tip**
> When the terminal shows `Setup complete.`, you're ready. This takes a
> couple of minutes the first time; that's the environment being assembled
> *for* you so you don't have to.

<details>
<summary><strong>What just happened? (the <code>.devcontainer</code>)</strong></summary>

The repository contains a `.devcontainer/` folder that tells Codespaces how
to set itself up. Its `setup.sh` script installed Apptainer and ran
`apptainer pull` to download our pre-built image to `~/deseq2.sif`. You
didn't install anything — the recipe is in the repo, so it's the same for
everyone.

</details>

---

## Step 2 — Verify the environment

Open the terminal in your Codespace (`` Ctrl + ` ``) and confirm the pieces
are in place:

```bash
# Apptainer is installed
apptainer --version

# The pre-built image is present
ls -lh ~/deseq2.sif

# R lives INSIDE the container — ask the container for its R version
apptainer exec ~/deseq2.sif R --version
```

That last command is the key idea: **you don't have R installed on this
Codespace.** R lives inside `deseq2.sif`. `apptainer exec <image> <command>`
runs a command *inside* the container's environment.

---

## Step 3 — Run the DESeq2 pipeline from the container

The pipeline code and a subset of the Shank3 dataset live in the repo under
`workshops/arcs_04/_materials/` — the folder this file is in. Move there and
run the pipeline inside the container:

```bash
cd workshops/arcs_04/_materials
apptainer exec ~/deseq2.sif Rscript pipeline.R
```

Apptainer automatically makes your current folder available inside the
container, so the pipeline can read `data/` and write `outputs/`.

When it finishes you'll see a summary like:

```
========================================================
Contrast : genotype  Shank3 vs WT
Design   : ~ condition + genotype
Cutoffs  : padj < 0.05   |log2FC| >= 0
Significant genes: <N>  (of <M> tested)
Outputs written to: outputs/
========================================================
```

Look at what it produced:

```bash
ls outputs/
```

- `deseq2_results.csv` — every gene tested
- `significant_genes.csv` — the differentially expressed genes
- `pca_plot.png`, `volcano_plot.png` — open these from the file explorer

> **📝 Note**
> This is the same analysis you ran in Hour 1 — but it just ran on **Linux**,
> inside a pinned environment, on a machine that isn't yours, and gave the
> same result. That's the payoff.

---

## Step 4 — Look inside the definition file

The image didn't appear from nowhere. It was built from a **definition
file**, [`container/deseq2.def`](container/deseq2.def). Open it. Each
section has a job:

```
Bootstrap: docker
From: bioconductor/bioconductor_docker:RELEASE_3_19   # the starting point

%post          # commands run ONCE at build time — installs DESeq2, ggplot2
%environment   # variables set every time the container runs
%runscript     # the default action of `apptainer run`
%test          # a sanity check run at the end of the build
```

The whole reproducible environment is described by this one readable text
file. Because it lives in the repo next to your code, anyone can see —
and rebuild — exactly what your analysis ran inside.

<details>
<summary><strong>Why don't we rebuild it live?</strong></summary>

Building the image compiles DESeq2 and its dependencies, which takes many
minutes. So we build it **once**, ahead of time, and everyone *uses* the
result. Building your own image from scratch is covered in the follow-up
self-paced guide.

</details>

---

## Step 5 — Make a change and re-run

Reproducible doesn't mean frozen — it means *controlled*. Let's change the
analysis and watch the result change, with the same image.

Open [`pipeline.R`](pipeline.R) and find the parameters block at the top:

```r
PADJ     <- 0.05      # adjusted p-value cutoff
```

Make the cutoff stricter:

```r
PADJ     <- 0.01
```

Save, and re-run exactly as before:

```bash
apptainer exec ~/deseq2.sif Rscript pipeline.R
```

The **Significant genes** count changes — a stricter cutoff keeps fewer
genes. Same environment, same data, a deliberate change to the question.
That's a controlled, reproducible experiment.

> **💡 Try another**
> Change `CONTRAST <- c("genotype", "Shank3", "WT")` to compare conditions
> instead — `c("condition", "sleep_deprived", "normal")` — and re-run.

---

## Step 6 — It all travels together (back to Git)

Look at what's in the repository now:

- `pipeline.R` — the **analysis code**
- `container/deseq2.def` — the **environment definition**
- `data/` — the **data** (or a pointer to it)
- the pre-built image, published to a **registry** (`ghcr.io/cwml/deseq2`)

This is the Part 3 Git story completed. Your code was already version
controlled. Now the *environment it runs in* is captured too — as a text
file you can diff, and as a published image anyone can pull. Clone the repo,
open a Codespace (or use HPC), `apptainer pull`, and run. The analysis
reproduces. That is the goal of the whole ARCS series, made concrete.

---

## Where to go next

You **used and modified** a container today. The self-paced
**Build Your Own Container** guide (`workshops/arcs_04/09-build-your-own.qmd`)
covers **authoring** one from scratch: installing a Linux substrate locally,
reading `deseq2.def` line by line, building the image, publishing it to a
registry, automating rebuilds with CI, and adapting the whole pattern to your
own analysis.

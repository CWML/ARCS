# Apptainer — in-Codespace walkthrough

> **Read this version in VS Code / Codespaces.** It's the same content as
> `08-apptainer.qmd` (the Positron and website version), in plain Markdown so
> it previews without Quarto.
> **Right-click this file → _Open Preview_**, or press `Cmd/Ctrl + Shift + V`.

### By the end of this section, you should be able to...

- **Describe** how containerization solves reproducibility problems that
  come from software and operating-system differences
- **Define** the core vocabulary — container, image (`.sif`), Apptainer, and
  definition file (`.def`) — and explain how the four relate
- **Differentiate** a *host* environment from a *containerized* environment,
  and say when each is appropriate
- **Execute** a multi-step DESeq2 pipeline *from inside* a container, on a
  Linux environment you launch in the browser
- **Modify** a parameter in the pipeline and re-run it to see the
  containerized analysis produce a new, reproducible result
- Connect the container to the Git workflow from Part 3: code, environment
  definition, and pipeline travel together as one reproducible artifact

---

## Where we are in the series

- **Parts 1–2** — writing R, managing projects, structuring data
- **Part 3** — the tidyverse and Git: your *code* is now reproducible
- **Part 4, Hour 1** — a real DESeq2 differential-expression pipeline
- **Part 4, Hour 2 (this section)** — make the *environment* reproducible too

You already have working analysis code under version control. The piece
that's still missing is the environment that code runs *in*. That's what
containers give you, and it's the last part of the reproducibility story
this series has been building toward.

---

## Today's workflow

Six steps, in order:

1. **Launch** a Codespace — everyone gets an identical Linux machine
2. **Verify** that Apptainer and the pre-built image are in place
3. **Run** the DESeq2 pipeline *from* the container
4. **Read** the definition file that built the image
5. **Modify** a parameter, re-run, and watch the result change
6. **Connect** it all back to Git

We *use* a pre-built image rather than building one from scratch — building
compiles Bioconductor and takes far longer than a session allows. Authoring
your own image is the self-paced follow-up guide.

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

The key word is *entire*. You may already pin your R packages with something
like `renv` — that's the same instinct, one layer up. But a package lockfile
still assumes R itself is installed, at a compatible version, on an operating
system that has the right system libraries for those packages to compile
against. A container removes those assumptions by shipping all of it. Think of
`renv` as a shopping list and a container as the delivered groceries.

<details>
<summary><strong>Is a container a virtual machine?</strong></summary>

No — and the difference is why containers are practical.

A **virtual machine** simulates an entire computer, including its own
operating-system kernel. That's heavy: gigabytes of overhead, slow to start.

A **container** shares the host's Linux kernel and packages only the layers
above it — the software, libraries, and files. That's why an image starts in
seconds and why `apptainer exec` feels like running a normal command rather
than booting a machine.

It's also why Apptainer needs Linux specifically: it isn't simulating a Linux
kernel, it's *borrowing* the one already running.

</details>

---

## The words you'll hear today

Four terms get used constantly and they're easy to blur together:

| Term | What it is |
|---|---|
| **Container** | The general idea: software packaged with everything it needs to run |
| **Image** (`.sif`) | The actual file on disk — one self-contained artifact you can copy, share, or archive. `.sif` stands for *Singularity Image Format* |
| **Apptainer** | The program that *runs* images (and builds them). It's what you type at the command line |
| **Definition file** (`.def`) | The plain-text recipe describing what goes into an image. Human-readable, lives in your repo, gets version controlled |

The relationship, end to end: you write a **definition file**, Apptainer
**builds** it into an **image**, and then Apptainer **runs** that image to
execute your analysis. Today you'll do only the last part — the image is
already built for you.

---

## So what is Apptainer?

**[Apptainer](https://apptainer.org/)** is free, open-source software that
builds and runs containers, purpose-built for research computing. You install
it on a Linux machine; from then on it's a command-line program, and the
handful of subcommands you'll meet today (`exec`, `run`, `pull`, `build`) are
most of what anyone uses day to day.

It was created at Lawrence Berkeley National Laboratory to solve a problem
research computing had and web infrastructure didn't: how do you let hundreds
of untrusted users run custom software environments on a shared cluster without
handing any of them administrator rights? Apptainer's answer is that a
container runs **as you** — with your permissions, your files, your identity —
rather than as a privileged system user. That single design decision is why
essentially every academic HPC centre supports it.

<details>
<summary><strong>You'll also see the name "Singularity"</strong></summary>

Apptainer was called **Singularity** until 2021, when the project joined the
Linux Foundation and was renamed. They are the same tool.

This matters practically: papers, tutorials, and Stack Overflow answers from
before ~2022 all say "Singularity," and many HPC clusters still provide the
command as `singularity` rather than `apptainer`. If your cluster's docs
mention Singularity, everything you learn here applies — try `singularity exec`
in place of `apptainer exec`.

</details>

<details>
<summary><strong>Why Apptainer and not Docker?</strong></summary>

You may have heard of Docker. Same core idea, different conventions:

- Apptainer is built for **research computing and HPC**
- It runs as *you*, not as root — which is why shared clusters allow it
- An image is **one portable file** (`analysis.sif`) you can copy, archive,
  or publish alongside a paper, rather than a set of layers in a daemon's
  storage

Docker is excellent for web services; Apptainer is the norm in research
computing because of that security model on shared systems. Apptainer can also
*read* Docker images, which is why our definition file starts from one.

</details>

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
`workshops/arcs_04/_materials/` — the folder next to this one. Move there and
run the pipeline inside the container:

```bash
cd workshops/arcs_04/_materials
apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R
```

Apptainer automatically makes your current folder available inside the
container, so the pipeline can read `processed_data/` and write `outputs/`.

> **📝 What's inside the image, and what isn't**
>
> This is worth being precise about, because it's the piece most people get
> backwards at first.
>
> **Inside the image:** R, DESeq2, ggplot2, and the system libraries they need —
> the *software*. Fixed at build time and identical for everyone.
>
> **Outside the image:** your code (`scripts/pipeline.R`), your data (`processed_data/`), and your
> results (`outputs/`) — all ordinary files in your own folder, which Apptainer
> makes visible to the container while it runs.
>
> That's the division of labour. The environment is frozen and shared; your
> files stay yours, editable with normal tools. It's why you can edit
> `scripts/pipeline.R` in Step 5 with the plain editor and immediately re-run it — you
> never have to open up or rebuild the image to change your analysis.

When it finishes you'll see a summary like:

```
========================================================
Contrast : genotype  Shank3 vs WT
Design   : ~ genotype   (condition == 'normal' only)
Cutoffs  : padj < 0.05   |log2FC| > 1
Significant genes: <N>  (of <M> tested)
Outputs written to: outputs/
========================================================
```

Look at what it produced:

```bash
ls outputs/
```

**Tables**

- `deseq2_results.csv` — every gene tested, sorted by adjusted p-value
- `significant_genes.csv` — the differentially expressed genes
- `normalized_counts.csv` — size-factor-normalized counts

**Plots** — open these from the file explorer

- `pca_plot.png` — samples in PC space, coloured by genotype
- `sample_distances.png` — sample-to-sample distance heatmap
- `ma_plot.png`, `volcano_plot.png` — the differential-expression results
- `top_gene_counts.png` — normalized counts for the single strongest hit

> **📝 Note**
> This is the same analysis you ran in Hour 1 — but it just ran on **Linux**,
> inside a pinned environment, on a machine that isn't yours, and gave the
> same result. That's the payoff.

---

## Step 4 — Look inside the definition file

The image didn't appear from nowhere. It was built from a **definition
file**, [`_materials/container/deseq2.def`](_materials/container/deseq2.def). Open it. Each
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

Open [`_materials/scripts/pipeline.R`](_materials/scripts/pipeline.R) and find the parameters
block at the top:

```r
PADJ      <- 0.05      # adjusted p-value (FDR) cutoff
LFC       <- 1         # |log2 fold change| cutoff
CONDITION <- "normal"  # which condition to keep
```

Make the cutoff stricter:

```r
PADJ      <- 0.01
```

Save, and re-run exactly as before:

```bash
apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R
```

The **Significant genes** count changes — a stricter cutoff keeps fewer
genes. Same environment, same data, a deliberate change to the question.
That's a controlled, reproducible experiment.

> **💡 Try another**
> Set `CONDITION <- "sleep_deprived"` to run the identical Shank3-vs-WT
> comparison in the other condition, and re-run. Every plot and table
> regenerates for the new subset.

---

## Step 6 — It all travels together (back to Git)

Look at what's in the repository now:

- `scripts/pipeline.R` — the **analysis code**
- `container/deseq2.def` — the **environment definition**
- `processed_data/` — the **data**
- the pre-built image, published to a **registry** (`ghcr.io/cwml/deseq2`)

This is the Part 3 Git story completed. Your code was already version
controlled. Now the *environment it runs in* is captured too — as a text
file you can diff, and as a published image anyone can pull. Clone the repo,
open a Codespace (or use HPC), `apptainer pull`, and run. The analysis
reproduces. That is the goal of the whole ARCS series, made concrete.

---

## Recap

- Containers fix "it works on my machine" by shipping the whole environment
- Apptainer runs only on Linux — so a Codespace or HPC supplies the kernel
- You **ran** and **modified** a real analysis pipeline from a container
- Code, environment, and data now travel together as one artifact

---

## Where to go next

You **used and modified** a container today. The self-paced
[**Build Your Own Container**](09-build-your-own_codespaces.md) guide — the
same content as `09-build-your-own.qmd` — covers **authoring** one from scratch:
installing a Linux substrate locally, reading `deseq2.def` line by line,
building the image, and adapting the whole pattern to your own analysis — plus
a conceptual tour of how images get shared and versioned.

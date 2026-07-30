# Build Your Own Container

**Self-paced follow-up to the Apptainer workshop**

> **Read this version in VS Code / Codespaces.** It's the same content as
> `09-build-your-own.qmd` (the Positron and website version), in plain Markdown
> so it previews without Quarto.
> **Right-click this file → _Open Preview_**, or press `Cmd/Ctrl + Shift + V`.

### By the end of this guide, you should be able to...

- Set up a **Linux environment** to build containers on a Mac, Windows, or
  Linux machine, and choose the right one for your situation
- **Read** an Apptainer definition file (`.def`) section by section and explain
  what each part does
- **Build** a container image from a definition file with `apptainer build`
- **Explain** what a container registry is, why images are versioned, and what
  your options are for sharing one — well enough to research the specifics
- **Recognize** the risk of a published image drifting from its definition, and
  the manual and automated ways to prevent it
- **Adapt** the whole pattern to your *own* analysis

In the workshop you *used and modified* a pre-built container. This guide is
about *authoring* one. It's self-paced — work through it at your own speed, and
come back to it when you're ready to containerize your own research.

> **❗ You need Linux to build a container**
>
> Apptainer is Linux-only, so building an image requires a Linux environment.
> Step 0 below sets one up. Everything after Step 0 is run *inside* that Linux
> environment.

---

## Step 0 — Get a Linux environment

You have four honest options, from least to most commitment. Pick based on how
often you'll do this and how much you want a persistent local setup.

| Option | Best for | Install cost | Persists? |
|---|---|---|---|
| **GitHub Codespaces** | Trying this out; occasional builds | None (browser) | No — ephemeral |
| **Lima** (macOS) | Mac users who build regularly | Moderate | Yes |
| **WSL2** (Windows) | Windows users who build regularly | Moderate | Yes |
| **Native Linux** | You already run Linux | None | Yes |

### Option A — GitHub Codespaces (easiest start)

This is the same environment you used in the workshop, and it can build images
too, not just run them. Open a Codespace on a repo whose `.devcontainer` is
privileged (the workshop repo already is — see the note below), then jump to
Step 1.

<details>
<summary><strong>Why the Codespace must be "privileged"</strong></summary>

Apptainer creates **Linux user namespaces** to run and build containers. A
Codespace is itself a container, and nested user namespaces are blocked unless
the container runs privileged. The workshop repo's
`.devcontainer/devcontainer.json` sets `"runArgs": ["--privileged"]` for exactly
this reason. If you build your own Codespace config, you need that line or
`apptainer` will fail with *"Failed to create user namespace."*

</details>

**Tradeoff:** zero install, but the environment is ephemeral — anything not
committed or pushed disappears when the Codespace is deleted.

### Option B — Lima (macOS)

[Lima](https://lima-vm.io/) runs a real Linux VM on your Mac. Because it's a
genuine VM (not a nested container), user namespaces work natively — no
privileged tricks needed.

```bash
brew install lima
limactl start                 # launches an Ubuntu VM (accept the defaults)
limactl shell default         # drop into the Linux VM
# ...now you're on Linux. Install Apptainer (Step 1) inside here.
```

**Tradeoff:** a few GB of disk and a VM to maintain, but a fast, persistent
local Linux you fully control.

### Option C — WSL2 (Windows)

[WSL2](https://learn.microsoft.com/windows/wsl/install) gives Windows a real
Linux kernel. User namespaces work, so Apptainer runs normally.

```powershell
wsl --install -d Ubuntu       # in PowerShell; reboot if prompted
```

Then open the **Ubuntu** terminal and continue with Step 1 inside it.

**Tradeoff:** moderate one-time setup, then a persistent Ubuntu integrated with
Windows.

### Option D — Native Linux

Nothing to set up — go straight to Step 1.

### Install Apptainer (all options except Codespaces, which has it already)

```bash
# Debian/Ubuntu (Lima, WSL2, or native Ubuntu)
APPTAINER_VERSION=1.3.6
cd /tmp
wget https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_VERSION}/apptainer_${APPTAINER_VERSION}_amd64.deb
sudo apt-get update && sudo apt-get install -y ./apptainer_${APPTAINER_VERSION}_amd64.deb
apptainer --version
```

> **📝 Note**
> We pin a specific version (`1.3.6`) on purpose — pinning is the same
> reproducibility habit you'll apply to the image itself below. The non-`suid`
> package shown here runs rootless via user namespaces, which is what you want on
> a personal machine.

---

## Step 1 — Read the definition file, line by line

A definition file is the **recipe** for your environment. Here is the workshop's
[`_materials/container/deseq2.def`](_materials/container/deseq2.def), with every
section explained.

```
Bootstrap: docker
From: bioconductor/bioconductor_docker:RELEASE_3_23-R-4.6.1
```

**`Bootstrap` / `From`** — where the build *starts*. `Bootstrap: docker` means
"pull a starting image from a Docker/OCI registry." `From:` names that image.

Why `bioconductor/bioconductor_docker:RELEASE_3_23-R-4.6.1`? Because it already contains
R, `BiocManager`, and — crucially — the system libraries needed to compile
Bioconductor packages. Starting from a bare Ubuntu would mean installing all of
that by hand. **Why the `RELEASE_3_23-R-4.6.1` tag?** A Bioconductor release pins a
specific R version *and* a specific set of package versions. Pinning the tag is
what makes the build reproducible: `:latest` would silently change underneath
you.

Note the tag names the R patch version too. A bare `RELEASE_3_23` would fix
the Bioconductor release but let R move if the image were rebuilt — the same
silent drift, one level down. Pin as much as the registry lets you.

```
%labels
    Author       ARCS Workshop ...
    Description  DESeq2 ...
    Version      1.0
```

**`%labels`** — metadata baked into the image. Readable later with
`apptainer inspect deseq2.sif`. Good place to record a version.

```
%help
    Reproducible R environment for the ARCS Part 4 DESeq2 pipeline...
```

**`%help`** — free text shown by `apptainer run-help deseq2.sif`. Document how
to run the image so the next person (often future-you) doesn't have to guess.

```
%post
    R -e 'BiocManager::install(c("DESeq2"), update = FALSE, ask = FALSE)'
    R -e 'install.packages(c("ggplot2"), repos = "https://cloud.r-project.org")'
    R -e 'library(DESeq2); library(ggplot2)'
```

**`%post`** — commands run **once, at build time**, inside the image. This is
where you install everything your analysis needs. It's the **slow** step
(Bioconductor compiles), which is exactly why you build *once* and reuse the
result. Note the two package worlds: Bioconductor packages go through
`BiocManager::install()`; CRAN packages through `install.packages()`. The final
`library(...)` line makes the build **fail loudly** if anything didn't install,
rather than shipping a broken image.

```
%environment
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
```

**`%environment`** — variables set every time the container *runs* (not at build
time). Locale settings here keep R's text handling consistent across hosts.

```
%runscript
    exec Rscript scripts/pipeline.R "$@"
```

**`%runscript`** — the default action of `apptainer run deseq2.sif`. Here it runs
the pipeline in the current directory. (`apptainer exec ... Rscript scripts/pipeline.R`
does the same thing explicitly; `run` just bakes in the default.)

```
%test
    R -e 'stopifnot(requireNamespace("DESeq2", quietly = TRUE)); cat("DESeq2 OK\n")'
```

**`%test`** — runs automatically at the **end of the build** to sanity-check the
image. If DESeq2 didn't install, the build fails here instead of in front of your
collaborators.

---

## Step 2 — Build the image

From the folder containing the `.def` file:

```bash
cd workshops/arcs_04/_materials/container
apptainer build deseq2.sif deseq2.def
```

> **⚠️ This is slow — that's normal**
>
> Building this image compiles DESeq2 and its dependencies. Expect **several
> minutes to ~20+ minutes** depending on your machine and network. You'll see
> pages of compiler output scroll by. That long compile is precisely why we never
> build live in class and instead distribute the finished `.sif`.

When it finishes you'll see your `%test` print `DESeq2 OK` and a `deseq2.sif`
file appear. Common hiccups:

- **Out of disk space** — the build cache plus the base image can need several
  GB. Free space, or run `apptainer cache clean`.
- **Network flake during package install** — re-run the build; it's the
  `%post` downloads failing, not your `.def`.
- **"Failed to create user namespace"** — you're in a nested container that
  isn't privileged (see Step 0).

---

## Step 3 — Test it locally

Before publishing, confirm the image actually runs your analysis:

```bash
cd ..                                   # back to _materials/
apptainer exec container/deseq2.sif R --version
apptainer exec container/deseq2.sif Rscript scripts/pipeline.R
ls outputs/tables/ outputs/figures/
```

If `outputs/` fills with results, your image is good to ship.

---

## Step 4 — Sharing your image: the concept

Steps 0–3 are the part you can do today. What follows is a **concept
orientation**, not a walkthrough — enough vocabulary to know what exists and
what to search for when you need it.

Once you have a working `.sif`, the question becomes: how does anyone *else*
get it? Image files are large — often several gigabytes — so they don't belong
in a Git repository. They live somewhere else, and your repo points at them.

**A registry** is a server that stores and serves container images, the way
CRAN serves R packages. You upload ("push") an image once; collaborators, an
HPC cluster, or an automated job download ("pull") it by name. The common
choices are the **GitHub Container Registry (GHCR)**, which sits next to your
code, **Docker Hub**, **Quay.io**, and the Apptainer-native **Sylabs Cloud
Library**. Pushing requires an account and an access token with permission to
write packages; images are private by default, so there's a visibility setting
to flip if you want people to pull without logging in.

> **❗ You'd publish to *your* namespace, not ours**
>
> The workshop image lives at `ghcr.io/cwml/cwml_arcs_4_deseq2` — you can pull from it, but
> you can't push to it. Publishing means creating your own registry namespace
> under your GitHub account or your lab's organization. That's an account setup
> task, not a container task, which is why it isn't a step you can follow along
> with here.

**Version tags** are the idea worth carrying away even if you never push
anything. A registry name ends in a tag — `:1.0`, `:latest`. Give an image a
real version and bump it whenever the `.def` changes, rather than
overwriting `:latest` forever. The payoff: a methods section can cite the exact
environment a result came from, and a colleague asking for that version gets
precisely what you ran. Treat the image tag as a Git tag for your environment.

**Two lighter-weight alternatives** are worth knowing about. You can attach a
`.sif` to a **GitHub Release** — no registry account, works well for a single
occasional artifact. Or deposit the image in **Zenodo**, which mints a **DOI**
you can cite in a paper and guarantees long-term archival. For published
research, the Zenodo route is often the more appropriate one.

<details>
<summary><strong>What to search for</strong></summary>

- `apptainer push`, `apptainer pull`, `apptainer registry login` — the three
  commands involved
- **ORAS** — the protocol Apptainer uses to store `.sif` files in OCI
  registries; you'll see `oras://` prefixes in registry addresses
- **GHCR authentication**, **personal access token**, `write:packages` scope,
  **package visibility** — the GitHub account-side setup
- **Sylabs Cloud Library** — the registry built specifically for Apptainer/Singularity
- **Zenodo DOI software archiving** — for citable, permanent deposits

</details>

---

## Step 5 — Keeping the image in sync: the concept

Here's the failure mode that eventually bites everyone: you edit the `.def`,
commit it, and forget to rebuild. Now the recipe in your repo and the published
image describe different environments — and there's nothing to warn you. The
image people are actually using no longer matches the definition people are
actually reading. That's a reproducibility bug that looks like nothing at all.

**The low-tech answer is discipline**, and it's genuinely sufficient for most
projects: whenever you change the `.def`, rebuild, bump the version tag, and
note the current image version in your README. Because the change is a Git
commit, you have a record of when the environment changed and why.

**The automated answer is continuous integration (CI)** — a service that
watches your repository and runs jobs when something changes. Configured for
this purpose, it rebuilds and republishes the image automatically whenever the
`.def` file is modified, so the published image cannot drift from the
definition. On GitHub this is **GitHub Actions**: a YAML file in
`.github/workflows/` describing what to run and what should trigger it. Notably,
CI runners are full virtual machines rather than nested containers, so the
privileged-mode problem from Step 0 doesn't arise there.

> **📝 This one is genuinely a later topic**
>
> CI is a substantial subject of its own — worth learning, but not a prerequisite
> for containerizing your research. Manual rebuilds with honest version tags get
> you the reproducibility benefit. Come back to automation when rebuilding by hand
> starts to feel like the thing you keep forgetting.
>
> This repository does have such a workflow, at
> `.github/workflows/build-image.yml`, if you want to see a real one.

<details>
<summary><strong>What to search for</strong></summary>

- **GitHub Actions workflow syntax** — the structure of the YAML file
- **workflow triggers**, **path filters** — running a job only when specific
  files change
- `setup-apptainer` **GitHub Action** — installs Apptainer on a runner
- `GITHUB_TOKEN`, **workflow permissions** — how a job authenticates to push a
  package without a personal token
- **continuous integration** generally — the concept is not container-specific

</details>

---

## Step 6 — Adapt the pattern to your own analysis

This is the real goal. To containerize *your* work, repeat the same moves:

1. **List your dependencies.** What language/version, and which packages? For R,
   skim your `library()` / `pacman::p_load()` calls. Split them into
   CRAN vs. Bioconductor (or pip vs. conda for Python).
2. **Pick a base image.** Match the heavy lifting to your stack: a Bioconductor
   image for Bioc work, `rocker/r-ver:4.4.1` for plain R, `python:3.12-slim` for
   Python. Pin the tag.
3. **Write the `.def`.** Copy `deseq2.def` and edit the `%post` installs. Keep
   the `%runscript` pointing at your entry script and the `%test` checking your
   key package loads.
4. **Build and test** (Steps 2–3) until your pipeline runs inside the image.
5. **Share it when you need to** (Steps 4–5). A local `.sif` plus a committed
   `.def` is already reproducible for you and anyone who can rebuild. Reach for
   a registry when collaborators, a cluster, or a publication need the exact
   image.

> **💡 Tip**
> Keep the `.def`, your pipeline script, and a small example dataset together in
> the repo — exactly like `_materials/`. That folder *is* your reproducible
> project: someone can clone it, pull the image, and reproduce your results on any
> Linux host, including HPC.

---

## Recap

- Building needs Linux — **Codespaces** to start, **Lima**/**WSL2** for a
  persistent local setup.
- The `.def` file is a readable recipe; each section has one job.
- `apptainer build` turns the recipe into a single `.sif` image (slow, once).
- Images are too large for Git — a **registry**, a **GitHub Release**, or a
  **Zenodo deposit** is how one gets shared. A real **version tag** is what
  makes it citable.
- A published image can silently **drift** from its definition. Rebuild and
  bump the version whenever the `.def` changes; automate it with **CI** later.
- The same pattern containerizes *any* analysis — which is the whole point of
  the ARCS series.

# ARCS Part 4 — Apptainer hour: instructor guide

The Apptainer hour (Hour 2) of Part 4. Goal: every learner, on any OS, runs
the *same* DESeq2 analysis from Hour 1 inside a container on a Codespace, and
leaves understanding why that makes research reproducible.

This guide is the operational runbook: what to build ahead of time, what to
verify on the day, and what to do when something breaks. For slide-by-slide
delivery notes, see [`TEACHING_NOTES.md`](TEACHING_NOTES.md). For the file map
and how the pieces fit together, see [`README.md`](README.md).

---

## One-time prep (before the first delivery)

Done on **any Linux box** (a Codespace works). Mac/Windows cannot build the
image.

### 1. Build the image

```bash
cd workshops/arcs_04/_materials
apptainer build deseq2.sif container/deseq2.def
```

This compiles DESeq2 — expect several minutes. The `%test` section runs at
the end and prints `DESeq2 OK` on success.

### 2. Smoke-test the pipeline against the image

```bash
apptainer exec deseq2.sif Rscript scripts/pipeline.R
ls outputs/tables/ outputs/figures/   # expect 3 CSVs + 4 PNGs, non-zero gene count
```

### 3. Publish the image to GHCR (CWML namespace)

```bash
# Personal access token (classic) with write:packages scope:
echo "$GHCR_PAT" | apptainer registry login -u <your-username> --password-stdin oras://ghcr.io

apptainer push deseq2.sif oras://ghcr.io/cwml/deseq2:latest
```

Then on github.com → **CWML** org → **Packages** → `deseq2` → **Package
settings** → **Change visibility → Public**. (Students pull a *public*
package with no login.) This requires the CWML org to allow public packages;
if you're not an org admin, get one to approve it once.

> **Delivery swap:** if GHCR is blocked, attach the `.sif` to a GitHub
> Release instead (`gh release create part4-v1 deseq2.sif`) and follow the
> one-line swap note in `.devcontainer/setup.sh`.

### 4. Verify a fresh Codespace end to end

Open a **new** Codespace on `CWML/ARCS`, wait for `Setup complete.`, then:

```bash
apptainer exec ~/deseq2.sif R --version          # works → image pulled OK
cd workshops/arcs_04/_materials
apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R   # works → end to end OK
```

If `apptainer pull` fails: the package isn't public, or `DESEQ2_IMAGE` in
`.devcontainer/devcontainer.json` points at the wrong tag.

If `apptainer exec` fails with **"Failed to create user namespace"**: the dev
container isn't privileged. Apptainer needs user namespaces, which are blocked
inside a Codespace unless the container runs privileged. Confirm
`"runArgs": ["--privileged"]` is present in `.devcontainer/devcontainer.json`
(it is by default), then rebuild: Command Palette → *Codespaces: Rebuild
Container*. This is the single most important thing to confirm in this dry run.

### 5. Keep the image in sync with the definition (optional but recommended)

Consider a GitHub Action that rebuilds and pushes `deseq2.sif` whenever
`container/deseq2.def` changes, so the published image never drifts from the
definition. (Covered in the async build-your-own guide.)

---

## Day-of checklist

- [ ] **At the top of Hour 1**, drop the Codespace link in chat so anyone
      with a GitHub/account issue surfaces *early*, not at the Hour 2 switch.
- [ ] Open the same Codespace yourself for live demos.
- [ ] Have a **backup shared Codespace** ready in case a learner's
      environment breaks mid-session.
- [ ] Confirm your own fresh Codespace finished `postCreateCommand` cleanly.

---

## Run-of-show (~60 minutes)

| Time | Segment | What you do |
|---|---|---|
| 0:00–0:12 | **Why containers + what Apptainer is** | Slides 1–11. Land the "works on my machine" pain, establish the vocabulary (container / image / Apptainer / `.def`), then the Linux-only reframe (the OS limit *is* the lesson). |
| 0:12–0:20 | **Everyone launches a Codespace** | Walk them through Code → Codespaces → Create. Budget buffer — first launches always hit snags. Wait for `Setup complete.` |
| 0:20–0:28 | **Verify** | `apptainer --version`, `ls ~/deseq2.sif`, `apptainer exec ~/deseq2.sif R --version`. Hammer the point: *no R on this Codespace — R is in the image.* |
| 0:28–0:42 | **Run the pipeline** | `cd workshops/arcs_04/_materials` → `apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R` → inspect `outputs/`. Open a plot. Same result as Hour 1, now on Linux. |
| 0:42–0:50 | **Read the `.def`** | Open `container/deseq2.def`, walk the sections. Note: editing it means rebuilding (slow) → that's the async path. |
| 0:50–0:57 | **Change & re-run** | Edit `PADJ` in `scripts/pipeline.R` (0.05 → 0.01), re-exec, watch the significant-gene count drop. Controlled, reproducible change. Backup lever if that lands flat: `CONDITION <- "sleep_deprived"`. |
| 0:57–1:00 | **Tie to Git + wrap** | Code + `.def` + published image travel together; this completes the Part 3 story. Point to the async build-your-own guide. |

---

## Commands cheat-sheet (what learners type)

```bash
# verify
apptainer --version
ls -lh ~/deseq2.sif
apptainer exec ~/deseq2.sif R --version

# run
cd workshops/arcs_04/_materials
apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R
ls outputs/tables/ outputs/figures/

# change a parameter (edit pipeline.R: PADJ <- 0.01) then re-run
apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R
```

Expected summary block:

```
========================================================
Contrast : genotype  Shank3 vs WT
Design   : ~ genotype   (condition == 'normal' only)
Cutoffs  : padj < 0.05   |log2FC| > 1
Significant genes: <N>  (of <M> tested)
Tables  -> outputs/tables/
Figures -> outputs/figures/
========================================================
```

---

## Recovery plans

| Symptom | Fix |
|---|---|
| `apptainer exec` → "Failed to create user namespace" | Dev container isn't privileged. Ensure `"runArgs": ["--privileged"]` in `devcontainer.json`, then *Codespaces: Rebuild Container*. (Caught in prep step 4.) |
| Learner's Codespace won't build | Hand them the **backup shared Codespace** link; move on, debug theirs after. |
| `apptainer: command not found` | `postCreateCommand` didn't finish — re-run `bash .devcontainer/setup.sh`. |
| `~/deseq2.sif` missing | Pull failed (package not public / wrong tag). Re-run `apptainer pull --force ~/deseq2.sif oras://ghcr.io/cwml/deseq2:latest`. |
| Pipeline can't find `processed_data/` | They're not in `_materials/` — `cd workshops/arcs_04/_materials` first. Paths in the script are relative to that folder. |
| Pull is slow / rate-limited | Use the backup Codespace, or fall back to the Release-asset delivery. |

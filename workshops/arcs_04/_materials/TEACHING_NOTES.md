# ARCS Part 4 — Apptainer hour: teaching notes

Slide-by-slide delivery notes for [`08-slides.qmd`](../08-slides.qmd). These
are the *pedagogy* notes — what to emphasize, where to pause, what to say if
asked. They were previously embedded as `::: notes` blocks in the slide deck.

Related files:

- [`INSTRUCTOR_GUIDE.md`](INSTRUCTOR_GUIDE.md) — operational runbook: one-time
  prep, day-of checklist, run-of-show timings, recovery plans
- [`README.md`](README.md) — file map and how the pieces fit together
- [`../08-apptainer.qmd`](../08-apptainer.qmd) /
  [`../08-apptainer_codespaces.md`](../08-apptainer_codespaces.md) — the
  student-facing walkthrough the demos follow

---

## The arc of the hour

This hour is the **capstone** of the whole series. Learners arrive with
working code under version control. The one missing piece for true
reproducibility is the environment that code runs in — that's what containers
give them. Every slide should be pulling toward that one landing.

The emotional beat you're managing: containers *sound* like infrastructure
work, not research work. The job is to keep it tied to their analysis at every
step.

---

## Slide-by-slide

### Where we are

This hour is the capstone. They have working code under version control. The
missing piece for true reproducibility is the environment that code runs in.
That's what containers give us.

### The problem: "it works on my machine"

**Ask the room:** who has hit this? Almost everyone has. Tie it back to any
install friction they felt in Parts 1–3 — you want a specific, recent memory,
not an abstraction.

### What is a container?

Emphasis on **"entire"** and **"pinned."** Contrast with just sharing a script.

### More than pinning packages

The `renv` comparison is the bridge from what they already know. If nobody in
the room has used `renv`, substitute "writing down your package versions in a
README" — the point survives. Don't belabour the groceries analogy; say it once
and move on.

### Not a virtual machine

This is the **most common first question**, so answer it before it's asked.
Two things to land: containers are cheap because they don't simulate a kernel,
and *that's precisely why Apptainer is Linux-only* — which sets up the reframe
two slides later. If you're short on time this is the slide to compress, but
don't cut the kernel-borrowing line; the next section depends on it.

### Four words to keep straight

Slow down here. Everything downstream uses these terms interchangeably in
casual speech, and learners who blur image/container/Apptainer get lost during
the demos rather than at this slide. Point at the bottom line — `.def` → build
→ image → run — and say explicitly that today is only the last arrow.

Worth saying aloud: `.sif` is a file, like a `.csv` is a file. Some people
expect a container to be a running *thing* they have to start and stop, and
find it clarifying that it's just a file sitting on disk.

### So what is Apptainer?

Name it plainly as **software you install**, not a concept. The Berkeley Lab
origin story is short and does real work: it explains the "runs as you" design
that the next slide's HPC point depends on.

The **Singularity** note is practical, not trivia — much of the documentation
they'll find is under the old name, and many clusters still ship the
`singularity` command. If your institution's cluster uses it, say so by name.

### Why Apptainer (not Docker)?

Don't teach Docker by accident. If asked: Docker is great for web services;
Apptainer is the norm in research computing because of the security model on
shared HPC. Same core idea, different conventions.

### The catch — Apptainer only runs on Linux

**Pause here.** Let it land as a "problem" before you flip it on the next
slide. The reframe only works if the obstacle registers first.

### ...which is exactly the point

This single reframe converts the biggest perceived obstacle into the core
mental model. Once you're past the kernel boundary, the container behaves
identically everywhere.

**Do NOT apologize for the OS switch** — name it and use it.

### Host vs. container

Hour 1 was the host (Positron on their laptop). Hour 2 is the container. Same
analysis, both ways — the comparison *is* the teaching moment.

### Today's workflow

We pull a pre-built image rather than building live — building compiles
Bioconductor and takes far too long for a live session. Building from scratch
is the self-paced follow-up.

### Demo: launch + verify

Live demo cue. Key talking point: **there is NO R on this Codespace** — R
lives inside the `.sif`. `apptainer exec` runs a command inside that
environment.

Push the Codespace link in chat *now* so account issues surface early.

### Demo: run the pipeline

Same analysis as Hour 1, now on Linux inside a pinned environment, on a
machine that isn't theirs — and the result matches. **Open a plot** from the
file explorer so the payoff is visual.

The match is the whole argument, so make it explicit: `scripts/pipeline.R` is
Hour 1's analysis verbatim — normal-condition samples only, `~ genotype` with
WT as reference, padj < 0.05 and |LFC| > 1. If anyone wrote down their
significant-gene count in Hour 1, ask them to compare. That's the moment the
abstract claim becomes evidence.

### What's in the image — and what isn't

Most people get this backwards at first: they assume their data and code went
*into* the image. Correct it explicitly. The payoff is immediate — it's the
reason the Step 5 edit works with a normal editor and no rebuild, so it makes
the next demo make sense rather than look like a trick.

### Demo: read the definition

The whole environment is one readable text file living next to the code. Walk
each section briefly. Note: changing this file means rebuilding, which is slow
— that's why it's read-only for us today.

### Demo: change and re-run

Reproducible ≠ frozen. It means *controlled*. This is the "modify and observe"
moment that earns the Analyze/Create objective without a live build.

`PADJ 0.05 → 0.01` is the primary lever. If it lands flat — a small drop is
less dramatic than you'd like — the stronger backup is
`CONDITION <- "sleep_deprived"`, which re-runs the identical comparison on the
other half of the data and regenerates every plot. Same image, same code, a
genuinely different question.

### It all travels together

This completes the Part 3 Git story. Code was already versioned; now the
environment is captured too — as a diffable text file and a pullable image.
This is the goal of the whole series, made concrete.

### Where to go next

The live session is for the concept landing. The async guide is for
completeness — **authoring** containers, not just using them.

---

## If you're running short on time

Cut in this order:

1. The `%environment` / `%test` detail on the definition-file slide — the
   section headings alone carry the point
2. The second "try another" change (`CONDITION`) — the `PADJ` change alone
   delivers the modify-and-observe objective
3. The Berkeley Lab origin story — keep "runs as you," drop the history
4. The virtual-machine table as a one-line spoken contrast ("it doesn't
   simulate a computer, it borrows the kernel") rather than a walked table
5. The host-vs-container table as a *spoken* comparison rather than a walked
   one — it's in the student guide either way

Never cut: the four-words vocabulary slide, the Linux-only reframe, and the
run-the-pipeline demo. The vocabulary slide looks skippable and isn't —
learners who blur *image* and *container* get lost during the demos, not here.

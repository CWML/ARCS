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

Emphasis on **"entire"** and **"pinned."** This is more than `renv` — it's the
whole stack down to system libraries. Contrast with just sharing a script.

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

### Demo: read the definition

The whole environment is one readable text file living next to the code. Walk
each section briefly. Note: changing this file means rebuilding, which is slow
— that's why it's read-only for us today.

### Demo: change and re-run

Reproducible ≠ frozen. It means *controlled*. This is the "modify and observe"
moment that earns the Analyze/Create objective without a live build.

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
2. The second "try another" change (`CONTRAST`) — the `PADJ` change alone
   delivers the modify-and-observe objective
3. The host-vs-container table as a *spoken* comparison rather than a walked
   one — it's in the student guide either way

Never cut: the Linux-only reframe, and the run-the-pipeline demo. Those are
the two moments the hour exists for.

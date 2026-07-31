# ARCS Part 4 — Apptainer hour: teaching notes

Section-by-section delivery notes for the Hour 2 walkthrough. These are the
*pedagogy* notes — what to emphasize, where to pause, what to say if asked.

Hour 2 is presented from the lesson page itself; there is no separate slide
deck. Drive [`../08-apptainer.qmd`](../08-apptainer.qmd) on the projector while
students follow
[`../08-apptainer_codespaces.md`](../08-apptainer_codespaces.md) in their
Codespace. The headings below match that page in order, so you can scroll and
read down this file in parallel.

Related files:

- [`INSTRUCTOR_GUIDE.md`](INSTRUCTOR_GUIDE.md) — operational runbook: one-time
  prep, day-of checklist, run-of-show timings, recovery plans
- [`README.md`](README.md) — file map and how the pieces fit together

---

## The arc of the hour

This hour is the **capstone** of the whole series. Learners arrive with
working code under version control. The one missing piece for true
reproducibility is the environment that code runs in — that's what containers
give them. Every section should be pulling toward that one landing.

The emotional beat you're managing: containers *sound* like infrastructure
work, not research work. The job is to keep it tied to their analysis at every
step.

---

## Section-by-section

### Where we are in the series

This hour is the capstone. They have working code under version control. The
missing piece for true reproducibility is the environment that code runs in.
That's what containers give us.

### Today's workflow

Six steps, previewed up front so they know where the hour is going. We pull a
pre-built image rather than building live — building compiles Bioconductor and
takes far too long for a live session. Building from scratch is the self-paced
follow-up.

### Why containers?

Three beats live in this one section; don't rush them together.

**"It works on my machine."** *Ask the room:* who has hit this? Almost everyone
has. Tie it back to any install friction they felt in Parts 1–3 — you want a
specific, recent memory, not an abstraction.

**What a container is.** Emphasis on **"entire"** and **"pinned."** Contrast
with just sharing a script.

**More than pinning packages.** The `renv` comparison is the bridge from what
they already know. If nobody in the room has used `renv`, substitute "writing
down your package versions in a README" — the point survives. Don't belabour
the groceries analogy; say it once and move on.

### Is a container a virtual machine?

This is the **most common first question**, so answer it before it's asked.
Two things to land: containers are cheap because they don't simulate a kernel,
and *that's precisely why Apptainer is Linux-only* — which sets up the reframe
further down. If you're short on time this is the part to compress, but don't
cut the kernel-borrowing line; the next section depends on it.

### The words you'll hear today

Slow down here. Everything downstream uses these terms interchangeably in
casual speech, and learners who blur image/container/Apptainer get lost during
the demos rather than at this table. Point at the bottom line — `.def` → build
→ image → run — and say explicitly that today is only the last arrow.

Worth saying aloud: `.sif` is a file, like a `.csv` is a file. Some people
expect a container to be a running *thing* they have to start and stop, and
find it clarifying that it's just a file sitting on disk.

### So what is Apptainer?

Name it plainly as **software you install**, not a concept. The Berkeley Lab
origin story is short and does real work: it explains the "runs as you" design
that the HPC point depends on.

The **Singularity** note is practical, not trivia — much of the documentation
they'll find is under the old name, and many clusters still ship the
`singularity` command. If your institution's cluster uses it, say so by name.

### Why Apptainer and not Docker?

Don't teach Docker by accident. If asked: Docker is great for web services;
Apptainer is the norm in research computing because of the security model on
shared HPC. Same core idea, different conventions.

### The OS limitation *is* the lesson

Two moves in one callout, and the order matters.

**Pause on the catch first.** Apptainer only runs on Linux. Let it land as a
"problem" — the reframe only works if the obstacle registers first.

**Then flip it.** This single reframe converts the biggest perceived obstacle
into the core mental model. Once you're past the kernel boundary, the container
behaves identically everywhere.

**Do NOT apologize for the OS switch** — name it and use it.

### Host vs. container

Hour 1 was the host (Positron on their laptop). Hour 2 is the container. Same
analysis, both ways — the comparison *is* the teaching moment.

### Steps 1–2 — launch and verify

Live demo cue. Key talking point: **there is NO R on this Codespace** — R
lives inside the `.sif`. `apptainer exec` runs a command inside that
environment.

Push the Codespace link in chat *now* so account issues surface early.

### Step 3 — run the pipeline

Same analysis as Hour 1, now on Linux inside a pinned environment, on a
machine that isn't theirs — and the result matches. **Open a plot** from the
file explorer so the payoff is visual.

The match is the whole argument, so make it explicit: `scripts/pipeline.R` is
Hour 1's analysis verbatim — normal-condition samples only, `~ genotype` with
WT as reference, padj < 0.05 and |LFC| > 1. If anyone wrote down their
significant-gene count in Hour 1, ask them to compare. That's the moment the
abstract claim becomes evidence.

**What's in the image — and what isn't.** Most people get this backwards at
first: they assume their data and code went *into* the image. Correct it
explicitly. The payoff is immediate — it's the reason the Step 5 edit works
with a normal editor and no rebuild, so it makes the next demo make sense
rather than look like a trick.

### Step 4 — read the definition

The whole environment is one readable text file living next to the code. Walk
each section briefly. Note: changing this file means rebuilding, which is slow
— that's why it's read-only for us today.

### Step 5 — change and re-run

Reproducible ≠ frozen. It means *controlled*. This is the "modify and observe"
moment that earns the Analyze/Create objective without a live build.

`LFC 1 → 0` is the lever: **3 → 16** significant genes. Do not use `PADJ`
for this — at the defaults only 3 genes clear `|LFC| > 1` and all 3 already
have `padj < 0.01`, so tightening PADJ changes nothing and the demo falls
flat. (That is measured, not assumed; the table is in `INSTRUCTOR_GUIDE.md`.)

The concept underneath is worth naming out loud: `PADJ` is *statistical*
significance, `LFC` is *biological* significance, and dropping the effect-size
bar keeps genes that are reliably different but only slightly so. Neither is
the "right" threshold.

Point at the count in the summary block, then at the two timestamped
`sigDEGs` tables — 3 rows and 16 rows, both preserved. Do **not** promise the
volcano will look different: its colouring comes from Hour 1's fixed
`padj < 0.1`, so it will not visibly change. Only the dashed guide lines move.

If you have time, the follow-up is `PADJ 0.05 → 0.01` for 16 → 9, which now
works because the effect-size filter is off.

### Step 6 — it all travels together

This completes the Part 3 Git story. Code was already versioned; now the
environment is captured too — as a diffable text file and a pullable image.
This is the goal of the whole series, made concrete.

### Where to go next

The live session is for the concept landing. The async guide is for
completeness — **authoring** containers, not just using them.

---

## If you're running short on time

Cut in this order:

1. The `%environment` / `%test` detail in Step 4 — the section headings alone
   carry the point
2. The second "try another" change (`CONDITION`) — the `LFC` change alone
   delivers the modify-and-observe objective
3. The Berkeley Lab origin story — keep "runs as you," drop the history
4. The virtual-machine table as a one-line spoken contrast ("it doesn't
   simulate a computer, it borrows the kernel") rather than a walked table
5. The host-vs-container table as a *spoken* comparison rather than a walked
   one — it's in the student guide either way

Never cut: the four-words vocabulary table, the Linux-only reframe, and the
run-the-pipeline demo. The vocabulary table looks skippable and isn't —
learners who blur *image* and *container* get lost during the demos, not there.

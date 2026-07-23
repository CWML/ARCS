# ARCS Workshop — Part 3 Setup Guide

**For students joining at Session 3 only** (you did not attend Sessions 1–2).

Work through this guide *before* the session starts. It gets your computer and project folder into the same state as everyone who attended Parts 1–2, so you're ready for **05-tidyverse** and **06-git**.

------------------------------------------------------------------------

## 1. Install the Required Software

Check each of these off before the session:

- [ ] [R](https://cran.r-project.org/)
- [ ] [Positron](https://positron.posit.co/)
- [ ] [Quarto](https://quarto.org/docs/get-started/)
- [ ] A free [GitHub account](https://github.com/signup)
- [ ] [GitHub Desktop](https://desktop.github.com/), signed in with your GitHub account
- [ ] **Windows only:** [Git Bash](https://git-scm.com/downloads/)

To confirm Quarto installed correctly, open a terminal and run:

``` bash
quarto --version
```

If you see a version number, you're set.

> **Already have all of this installed?** If you've got the software but haven't created a project yet, skip ahead to **Step 2**.

------------------------------------------------------------------------

## 2. Create Your Project

1.  Open **Positron**.
2.  Create a new R Project named **demo_project** (Desktop is a fine location).
3.  **Important:** when the project creation dialog appears, check the box to **initialize a git repository**. This is the step some students miss — if you're not sure whether you checked it, don't worry, Step 6 below will confirm it either way.

------------------------------------------------------------------------

## 3. Set Up Your Folder Structure

Inside **demo_project**, create these four folders (in the Explorer pane, or with R — see below):

```         
demo_project/
├── raw_data/         # original data — never edit these files
├── processed_data/   # cleaned data goes here
├── scripts/          # your code goes here
└── outputs/          # analysis outputs (figures, tables) go here
```

In the R console, you can create them all at once:

```{r}
dir.create("raw_data")
dir.create("processed_data")
dir.create("scripts")
dir.create("outputs")
```

------------------------------------------------------------------------

## 4. Get the Workshop Data

You'll need two CSV files for the workshop dataset (GSE113754):

- `GSE113754_GeneLevel_Raw_data.csv`
- `GSE113754_filtered_metadata.csv`

Get these from your workshop coordinator (they'll be in the same place as the rest of the workshop materials) and place both files in your **raw_data/** folder.

------------------------------------------------------------------------

## 5. Run the Catch-Up Script

The **`part-3-catch-up.R`** script in this folder covers everything from Sessions 1–2 — R fundamentals, project setup with `renv`, and importing/cleaning/harmonizing the workshop data — so you arrive at Session 3 on equal footing.

1.  Copy `part-3-catch-up.R` into your **scripts/** folder.
2.  Open it in Positron.
3.  Work through it top to bottom, running one line or block at a time (`Cmd/Ctrl + Enter`) and reading the comments as you go.

By the end, you'll have cleaned data saved in `processed_data/` and a fully reproducible project environment.

------------------------------------------------------------------------

## 6. Confirm Git Is Tracking Your Project

Open the **Terminal** tab in Positron (it opens in your project folder automatically) and run:

``` bash
git status
```

- If you see a list of files, git is already tracking your project — you're done.

- If you see `fatal: not a git repository`, run:

  ``` bash
  git init
  ```

  then run `git status` again to confirm.

(This exact check is also covered in **Section 0.5** of the 06-git materials, so you'll see it again — that's intentional.)

------------------------------------------------------------------------

## You're Ready for Session 3

You should now have:

- [x] R, Positron, Quarto, and GitHub Desktop installed
- [x] A **demo_project** folder with `raw_data/`, `processed_data/`, `scripts/`, and `outputs/`
- [x] The workshop data in `raw_data/` and cleaned versions in `processed_data/`
- [x] A git repository tracking your project (confirmed via `git status`)

See you in **05-tidyverse**!
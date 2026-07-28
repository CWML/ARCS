# ============================================================================
# ARCS Workshop — Part 3 Catch-Up Script
# ============================================================================
#
# For students who missed Sessions 1 and/or 2 and need to get caught up before
# Session 3. Work through this script top to bottom, running one line or
# block at a time and reading the comments as you go.
#
# This script contains everything from the Part 2 catch-up script PLUS the
# relevant R content from Session 2's Reports material (04-reports), so a
# student who runs this end to end will be caught up through:
#   Part A — R Fundamentals            (01-fundamentals)
#   Part B — Project Management        (02-projects)
#   Part C — Data Structures           (03-structures)
#   Part D — Reports & Gene Analysis   (04-reports)
# ...and ready for Session 3 (arcs_03).
#
# HOW TO RUN: Place this file in your scripts/ folder and open it in Positron.
# Run a line with Cmd/Ctrl + Enter. Read every comment (#) — they explain the
# "why," not just the "what."
# ============================================================================


# ============================================================================
# PART A — FUNDAMENTALS OF R  (from 01-fundamentals)
# ============================================================================

# ---- A1. The Working Directory --------------------------------------------
# Your working directory is the folder R reads from and writes to by default.
# We work from a folder called ARCS_project, where your data and scripts live.

# Find out where R is currently pointed:
getwd()

# To learn about ANY function, put a ? in front of it:
?getwd

# Set your working directory to YOUR ARCS_project folder. Edit the path to
# match your machine, then un-comment and run the correct line.

# Mac example:
# setwd("~/Desktop/ARCS_project")

# Windows example:
# setwd("C:/Users/YourName/Desktop/ARCS_project")

# Confirm you are in the right place — the path should end in ARCS_project:
getwd()


# ---- A2. Four Basic Rules for Writing Code --------------------------------
# 1. Use # to annotate/document your code (everything after # is ignored by R)
# 2. Use a noticeable pattern to break between coding chunks, e.g.:
#----- Section Title ------#
########################

# 3. Numbers and basic arithmetic work just as they do on paper:
2025        # a number
1 + 1       # summation
1 - 1       # subtraction
1 * 2       # multiplication
2 / 1       # division
2^2         # exponentiation

# The colon : gives you a range of numbers between two values:
4:8
8:4

# 4. Letters/text must be written between quotation marks "" (a "string").
#    Exception: the NAME of an object is written without quotation marks.

# Notice the difference:
"Hello world!"   # a character string — R prints it back
# Hello world!   # WITHOUT quotes this is an error (unless it names an object)


# ---- A3. Storing Information in R Objects ----------------------------------
# Objects let us store values under a name so we can reuse them without
# repeating work. Assign with the <- operator:  name <- data
# Keyboard shortcut for <- :  Mac = Option + -   |   PC = Alt + -

x <- "X marks the spot of the "   # store a string in the object x

# paste0() glues strings together with no separator:
paste0(x, "treasure.")

# You can reuse the object as many times as you like:
paste0(x, c("treasure.", " gold.", " map."))

# Naming rules for objects:
#   No empty spaces          (my age  -> invalid)
#   Cannot start with a number (2x -> invalid, but x2 -> valid)
#   Avoid names that are already function names (it gets confusing)

# Example — assign your age, then compute your birth year:
my_age <- 30                 # <-- change to your age
birth_year <- 2026 - my_age
birth_year


# ---- A4. Vectors ----------------------------------------------------------
# A vector is a series of values of ONE data type, built with c() ("combine").
#
# The 5 main data types in R:
#   double/numeric  numbers with decimals   1.2
#   integer         whole numbers           10L
#   complex         imaginary component     2i
#   logical         TRUE or FALSE           TRUE
#   character       string of characters    "Sofia"

# Make a vector of ages for four people you know:
FamAges <- c(34, 28, 61, 5)

# Vectors are used by name — no quotation marks needed:
FamYear <- 2026 - FamAges
FamYear


# ---- A5. Tabular Data: Data Frames vs. Matrices ---------------------------
# Both store rows-and-columns (2D) data, but:
#   Data frame — can MIX data types (numbers + text). Used for data
#                processing, statistics, and plotting. This is our workhorse.
#   Matrix     — SINGLE data type only. Used for mathematical operations.

# Pack the two vectors into a data frame with data.frame():
df_FamInfo <- data.frame(FamAges, FamYear)
df_FamInfo

# For big tables, inspect just the top/bottom rows:
head(df_FamInfo)
tail(df_FamInfo)

# Add a column of NAMES (character) with cbind() ("column bind"):
FamNames <- c("Ana", "Ben", "Carla", "Dev")   # must match the ages above
df_FamInfo <- cbind(df_FamInfo, FamNames)
df_FamInfo
# Because it is a data frame, mixing numbers and text in one table is fine.


# ============================================================================
# PART B — PROJECT MANAGEMENT  (from 02-projects)
# ============================================================================
# Good project structure is part of reproducible research. Two practices you
# will use in every project: a reproducible environment (renv) and documentation.
#
# NOTE: The renv and fs steps below RUN IN THE CONSOLE and change files on your
# computer. They are commented out so this script runs cleanly. Un-comment and
# run them one at a time in your Console when you are ready.

# ---- B1. Create a Reproducible R Environment with renv --------------------
# renv records the exact package versions you used so a collaborator can
# restore the same environment — no more "it works on my machine."

# 1. Make sure you are in your project directory:
# getwd()

# 2. Initialize renv (creates renv/, renv.lock, and updates .gitignore):
# renv::init()

# 3. Restart R (circular arrow icon at the top-right of the Console).

# 4. Snapshot the packages currently in use:
# renv::snapshot()
#    If prompted that the project "hasn't been activated yet", choose
#    option 1: Activate the project and use the project library.

# When someone later clones your repo, renv::restore() rebuilds your environment.


# ---- B2. Set Up Your Folder Structure -------------------------------------
# A consistent folder layout for every project:
#   raw_data/        original data goes here (never edit these files)
#   processed_data/  cleaned data goes here
#   scripts/         code for analyses goes here (this file lives here)
#   outputs/         analysis outputs go here
#
# You can create these folders manually in the Explorer, or with R:
# dir.create("raw_data")
# dir.create("processed_data")
# dir.create("scripts")
# dir.create("outputs")


# ---- B3. Write a README with fs::dir_tree() -------------------------------
# A README is the entry point to your project — what it is, what the data is,
# and how to use it.

# Install and load fs, then print your project's file tree:
# install.packages("fs")
# library(fs)
# fs::dir_tree()

# Write that tree to a README file:
# capture.output(fs::dir_tree(), file = "README.txt")

# Then open README.txt and add a project description. A simple template:
#   This readme file was generated on [YYYY-MM-DD] by [NAME]
#   Title of Dataset:
#   Author/PI: Name / ORCID / Institution / Email
#   Source: GREIN platform (interfaces with NIH GEO)
#     https://www.ilincs.org/apps/grein/?gse=GSE113754
#   File List / folder descriptions (raw_data, processed_data, scripts, outputs)


# ============================================================================
# PART C — DATA STRUCTURES: IMPORTING, CLEANING & HARMONIZING (03-structures)
# ============================================================================

# ---- C1. Confirm your working directory -----------------------------------
# Before importing anything, make sure you are inside your project so the
# relative paths below (raw_data/...) resolve correctly.
getwd()

# ---- C2. Load a package ----------------------------------------------------
# We use the readr package for reading data. To learn about a whole package:
#   help(package = "readr")
# Install readr (only needs to be done once per machine/environment):
install.packages("readr")
# Then load it into your session (do this every session you use it):
library(readr)

# ---- C3. Import the workshop data with read.csv() -------------------------
# We work with two tables from the GREIN / GSE113754 dataset. Make sure both
# files are in your raw_data/ folder before running these lines.

# 1. Raw counts at the gene level:
rawc <- read.csv("raw_data/GSE113754_GeneLevel_Raw_data.csv")

# 2. Sample metadata — information about the sequenced samples:
info <- read.csv("raw_data/GSE113754_filtered_metadata.csv")

# A quick look to confirm the imports worked:
dim(rawc)   # rows (genes) x columns (samples + gene info)
dim(info)   # rows (samples) x columns (metadata fields)
head(info)


# ---- C4. Inspecting Data Structures ---------------------------------------
# Find what kind of structure an object is with class():
class(rawc)
class(info)

# Find the type of data stored in an object with typeof():
typeof(rawc)
typeof(info)

# Use $ to access a single column by name, then inspect its type:
typeof(rawc$GSM3119002)

# Dimensions (rows, columns):
dim(rawc)
dim(info)

# str() gives a detailed look at the overall structure of an object:
str(rawc)
str(info)

# summary() gives minimal statistics per column.
#   Numeric columns  -> Min, 1st Qu., Median, Mean, 3rd Qu., Max
#   Character columns -> Length, Class, Mode
summary(rawc)


# ---- C5. Identifying Missing Values ---------------------------------------
# Quick check for ANY missing (NA) values in a large object:
anyNA(rawc)

# is.na() tests each element — try it on a small example first:
is.na(c(1, NA, 3, 6, 0))
# On a big data frame is.na() returns a value for every element, which is
# impractical — prefer anyNA() or which(is.na()) (below) for large objects.


# ---- C6. Manipulating Specific Data Points (Indexing) ---------------------
# R uses 1-based indexing (the first element is position 1; Python starts at 0).
#   vector[1]      -> first element of a vector
#   table[1, 2]    -> row 1, column 2
#   table[1059, ]  -> the entire row 1059
#   table[, 3]     -> the entire column 3
#
# Conditional operators: ==(equal) !=(not equal) > < >= <= %in%(included in)

# rawc has an NA in column GSM3119015. Nest is.na() inside which() to find the
# row number where it occurs:
which(is.na(rawc$GSM3119015 == "NA"))

# Confirm the NA is in row 1059 by inspecting that whole row:
rawc[1059, ]

# Fix the NA by its positional coordinates (row number, column name):
rawc[1059, "GSM3119015"] <- 0
rawc[1059, ]


# ---- C7. Exploring Unique Values ------------------------------------------
# Look at what distinct values exist in a column, and count them:
unique(info$genotype)
table(info$genotype)

# Apply the same functions across every column at once with sapply():
sapply(info, unique)
sapply(info, table)


# ---- C8. Data Cleaning and Subsetting -------------------------------------

# Rename columns using colnames() and []. (colnames() returns a vector, so it
# needs [] WITHOUT a comma — a vector is one-dimensional.)
colnames(info)[1:3] <- c("sample_id", "condition", "genotype")

# Remove the redundant genotype.ch1 column by its index (the - means "drop"):
info <- info[, -4]

# Recode the genotype column — collapse "Shank3 Mutant" to "Shank3".
# ifelse(test, value_if_true, value_if_false); grepl() tests for a pattern.
genotype_clean <- ifelse(grepl("WT", info$genotype),           # test
                         "WT",                                  # yes
                         ifelse(grepl("Shank3", info$genotype), # no
                                "Shank3",
                                as.character(info$genotype)))

# Extract housing condition from the condition column:
condition_clean <- ifelse(grepl("homecage control", info$condition),  # test
                          "normal",                                    # yes
                          ifelse(grepl("sleep deprivation",           # no
                                       info$condition),
                                 "sleep_deprived",
                                 as.character(info$condition)))

# Combine genotype and condition into one label, separated by "_":
geno_cond <- paste(genotype_clean, condition_clean, sep = "_")

# Build the final cleaned metadata data frame with just the columns we want:
info_clean <- data.frame(
  sample_id = info[, 1],
  genotype  = genotype_clean,
  condition = condition_clean,
  geno_cond = geno_cond
)

head(info_clean)


# ---- C9. Data Harmonization -----------------------------------------------
# Harmonization = unifying data from different sources into a consistent format
# so the tables are compatible for downstream analysis. Here, the samples in
# rawc (counts) must be in the SAME number and order as in info_clean (metadata).

# Do the column names of rawc already match the sample IDs in info_clean?
identical(colnames(rawc), info_clean$sample_id)

# Look at each to see how they differ:
colnames(rawc)
info_clean$sample_id

# Step 1: Build a gene_id by merging the gene ID and gene symbol columns
# (columns 1 and 2 of rawc), separated by "|":
gene_id <- paste(rawc[, 1], rawc[, 2], sep = "|")

# Step 2: Keep only the columns that match info_clean$sample_id, and set
# gene_id as the row names so it is not treated as a data column:
rawc_clean <- data.frame(
  rawc[, info_clean$sample_id],
  row.names = gene_id
)


# ---- C10. Save the Cleaned Tables -----------------------------------------
# Write the cleaned metadata and counts to your processed_data/ folder.
# (write.csv() writes to your local file system.)
dir.create("processed_data", showWarnings = FALSE)   # create folder if absent
write.csv(info_clean, "processed_data/Shank3_metadata_clean.csv")
write.csv(rawc_clean, "processed_data/Shank3_rawCounts_clean.csv")


# ============================================================================
# PART D — REPORTS: QUARTO DOCUMENTS & GENE VARIABILITY ANALYSIS (04-reports)
# ============================================================================
# Quarto documents (.qmd) combine code, results, and narrative text in one
# file that renders to HTML/PDF/Word — your analysis and its documentation
# stay in sync. Some of this section is done in the Finder/Explorer and
# Terminal rather than the R console, so those steps are given as commented
# reference instructions. The R code that IS meant to run is left active.

# ---- D1. Convert README.txt to a Quarto Document (.qmd) -------------------
# 1. In Finder/Explorer, right-click README.txt -> Rename -> change the
#    extension from .txt to .qmd
#
# 2. Check for required packages (run this block in the console):
# if (!require("knitr"))     install.packages("knitr")
# if (!require("rmarkdown")) install.packages("rmarkdown")
# if (!require("yaml"))      install.packages("yaml")
# if (!require("dplyr"))     install.packages("dplyr")
# if (!require("stringr"))   install.packages("stringr")
#
# 3. Confirm Quarto is installed — run this in your TERMINAL (not console):
#      quarto --version
#    If no version number appears, install from https://quarto.org/docs/get-started/
#
# 4. Create a file named _quarto.yml in your project ROOT directory with:
#      project:
#        type: default
#
# 5. In your README.qmd, wrap the file-structure tree in triple backticks
#    (```) so it renders as a code block.
#
# 6. In your TERMINAL, run:
#      quarto render
#      quarto preview readme.qmd
#    A browser window opens showing your README.qmd as HTML.
#
# WHAT IS LOCALHOST? The browser address starts with "localhost" plus a port
# number — your computer is serving the file to itself locally. It is not on
# the internet; it's a local preview only.


# ---- D2. Automate README.qmd Updates with dir_tree() -----------------------
# Instead of manually updating your README every time your project structure
# changes, embed an R chunk that regenerates the file tree on every render.
# This code is meant to be pasted into README.qmd as an {r} chunk (replacing
# the static tree from Part B) — you can also run it here to preview the output.

# install.packages("fs")   # only if not already installed
library(fs)

# Get the actual project structure
tree_output <- capture.output(dir_tree(".", recurse = 2))

# Define comments for specific files/folders
comments <- list(
  "raw_data"       = " (original data goes here)",
  "processed_data" = " (clean data goes here)",
  "scripts"        = " (code goes here)",
  "outputs"        = " (results and charts go here)",
  "README.qmd"     = " (project documentation)"
)

# Add comments to matching lines
for (item in seq_along(tree_output)) {
  line <- tree_output[item]
  for (name in names(comments)) {
    if (grepl(name, line)) {
      tree_output[item] <- paste0(line, comments[[name]])
      break
    }
  }
}

# Print the annotated tree
cat(paste(tree_output, collapse = "\n"))

# In README.qmd, this same logic is wrapped with:
#   #| echo: false
#   #| message: false
#   #| results: asis
# ...and prints inside triple-backtick fences with cat("```\n") / cat("\n```\n")
# so it renders as a formatted code block instead of raw R output.


# ---- D3. Create a Quarto Document for Publishing (PLOS template) ----------
# Check/install the packages needed for the publication analysis below:
install.packages("tidyverse")
install.packages("readxl")
install.packages("scales")

library(tidyverse)   # dplyr, tidyr, ggplot2, etc.
library(scales)      # for scales::squish() used in the heatmap below

# Install a PLOS journal template — run these in your TERMINAL, one at a time:
#   quarto add quarto-journals/plos
#   quarto use template quarto-journals/plos
# This formats a .qmd document to match PLOS journal submission requirements
# (layout, fonts, figure formatting). The same approach works for other
# journal templates available through quarto-journals.


# ---- D4. Gene Variability Analysis -----------------------------------------
# This block would normally go in a code chunk under a heading like
# "## Gene Variability Analysis" in your publication.qmd, with chunk options:
#   #| message: false
#   #| warning: false
#
# We reuse rawc_clean from Part C (row names are "ensembl_id|gene_symbol",
# columns are sample IDs) instead of re-importing a separate Excel file —
# reshape it into the long ensembl_id / gene_symbol / sample / expression
# format the original analysis expects:
gene_data_long <- rawc_clean %>%
  rownames_to_column("gene_id_full") %>%
  separate(gene_id_full, into = c("ensembl_id", "gene_symbol"), sep = "\\|") %>%
  filter(!is.na(gene_symbol), gene_symbol != "") %>%
  pivot_longer(cols = -c(ensembl_id, gene_symbol),
               names_to = "sample",
               values_to = "expression")

# Calculate variance for each gene across all samples
gene_variability <- gene_data_long %>%
  group_by(gene_symbol, ensembl_id) %>%
  summarise(
    mean_expression        = mean(expression, na.rm = TRUE),
    variance               = var(expression, na.rm = TRUE),
    coefficient_of_variation = sd(expression, na.rm = TRUE) / mean_expression,
    .groups = 'drop'
  )

# Identify top 15 most variable genes
top_genes <- gene_variability %>%
  arrange(desc(variance)) %>%
  slice_head(n = 15)

# Display summary statistics
cat("Total genes analyzed:", nrow(gene_variability), "\n")
cat("Mean variance across all genes:",
    round(mean(gene_variability$variance, na.rm = TRUE), 2), "\n")
cat("Most variable gene:", top_genes$gene_symbol[1],
    "with variance =", round(top_genes$variance[1], 2), "\n")

# Show the top 10 most variable genes
cat("\nTop 10 most variable genes:\n")
print(top_genes %>%
        select(gene_symbol, variance) %>%
        slice_head(n = 10) %>%
        mutate(variance = round(variance, 2)))


# ---- D5. Data Visualization: Expression Heatmap ----------------------------
# This block would go under a heading like "## Data Visualization" in
# publication.qmd, with chunk options:
#   #| fig-cap: "Expression heatmap showing scaled expression levels of the
#   #|   15 most variable genes across all samples. Blue indicates
#   #|   below-average expression, white indicates average expression,
#   #|   and red indicates above-average expression for each gene."
#   #| fig-width: 10
#   #| fig-height: 6

# Prepare heatmap data
heatmap_data <- gene_data_long %>%
  filter(gene_symbol %in% top_genes$gene_symbol) %>%
  left_join(top_genes %>% select(gene_symbol, variance),
            by = "gene_symbol") %>%
  group_by(gene_symbol) %>%
  mutate(scaled_expr = scale(expression)[, 1]) %>%
  ungroup()

# Create heatmap visualization
expression_heatmap <- heatmap_data %>%
  ggplot(aes(x = sample,
             y = reorder(gene_symbol, variance),
             fill = scaled_expr)) +
  geom_tile(color = "white", linewidth = 0.1) +
  scale_fill_gradient2(
    low   = "blue",
    mid   = "white",
    high  = "red",
    name  = "Scaled\nExpression",
    limits = c(-3, 3),
    oob   = scales::squish
  ) +
  labs(
    title    = "Expression Variability Heatmap: Top 15 Most Variable Genes",
    subtitle = "Genes ordered by variance (highest at top)",
    x        = "Sample ID",
    y        = "Gene Symbol"
  ) +
  theme_minimal() +
  theme(
    axis.text.x  = element_text(angle = 45, hjust = 1, size = 8),
    axis.text.y  = element_text(size = 10, face = "italic"),
    plot.title   = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "right",
    panel.grid   = element_blank()
  )

print(expression_heatmap)

# Save a high-resolution figure with a timestamped filename to outputs/ —
# the same automated file-naming pattern introduced in Project Management.
if (!dir.exists("outputs")) dir.create("outputs")
timestamp <- format(Sys.time(), "%Y%m%dT%H%M%S")

ggsave(paste0("outputs/", timestamp, "_expression_heatmap.png"),
       plot   = expression_heatmap,
       width  = 10,
       height = 6,
       dpi    = 300)


# ============================================================================
# You are now caught up through Sessions 1 and 2! You have covered R
# fundamentals, project management, data import/cleaning/harmonization, and
# Quarto reporting with a gene variability analysis and heatmap. This is
# where Session 3 (arcs_03) picks up.
# ============================================================================

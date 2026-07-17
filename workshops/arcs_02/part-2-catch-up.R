# ============================================================================
# ARCS Workshop — Part 2 Catch-Up Script
# ============================================================================
#
# For students who missed Session 1 (Part 1) and need to get caught up before
# Session 2 (Part 2). Work through this script top to bottom, running one line
# or block at a time and reading the comments as you go.
#
# By the end of this script you will have:
#   - Set your working directory inside your ARCS_project folder
#   - Reviewed R fundamentals: arithmetic, objects, vectors, data frames
#   - Set up a reproducible project (renv) and a documented folder structure
#   - Loaded a package and imported the workshop data with read.csv()
#     (this is exactly where Session 2 / 03-structures picks up)
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
# PART C — GETTING READY FOR PART 2: IMPORTING DATA  (start of 03-structures)
# ============================================================================
# This is where Session 2 begins. Everything above got you here.

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
# You are now caught up through all of Session 2 (03-structures)! You have
# imported, inspected, cleaned, and harmonized both tables and saved the
# cleaned versions to processed_data/. This is where Part 4 picks up.
# ============================================================================

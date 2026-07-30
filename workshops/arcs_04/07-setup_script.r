# =============================================================
# Script: 00_setup.R
# Purpose: Install all packages required for the DESeq2 workshop
# Run: ONCE before opening the analysis Quarto file
# Author: Sofia Fertuzinhos, PhD
# Date: 2026
# =============================================================

# ------------------------------------------------------------- #
# STEP 1 — Install renv (if not already installed)              #
# ------------------------------------------------------------- #

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# ------------------------------------------------------------- #
# STEP 2 — Initialise renv for this project                     #
# ------------------------------------------------------------- #
# This creates:
#   - renv/             (local package library)
#   - renv.lock         (snapshot of exact package versions)
#   - .Rprofile         (auto-activates renv when project opens)
#
# If renv is already initialised (e.g. cloned from GitHub),
# renv::restore() will reinstall all packages from renv.lock
# instead of reinstalling from scratch.

if (file.exists("renv.lock")) {
  
  message("📦 renv.lock found — restoring packages from lockfile...")
  renv::restore()                    # reproduces exact environment
  
} else {
  
  message("🆕 No renv.lock found — initialising fresh environment...")
  renv::init(bare = TRUE)            # bare = TRUE: does not auto-snapshot yet

  # ----------------------------------------------------------- #
  # STEP 3 — Install CRAN packages                              #
  # ----------------------------------------------------------- #
  cran_packages <- c(
    "here",
    "ggplot2",
    "dplyr",
    "tibble",
    "pheatmap",
    "RColorBrewer"
  )
  
  installed <- rownames(installed.packages())
  to_install <- cran_packages[!cran_packages %in% installed]
  
  if (length(to_install) > 0) {
    message("Installing CRAN packages: ", paste(to_install, collapse = ", "))
    install.packages(to_install)
  } else {
    message("✅ All CRAN packages already installed.")
  }
  
  # ----------------------------------------------------------- #
  # STEP 4 — Install Bioconductor packages                      #
  # ----------------------------------------------------------- #
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  
  bioc_packages <- c(
    "DESeq2",
    "apeglm"          # required for lfcShrink(type = "apeglm")
  )
  
  bioc_installed <- bioc_packages[
    !bioc_packages %in% installed.packages()[, "Package"]
  ]
  
  if (length(bioc_installed) > 0) {
    message("Installing Bioconductor packages: ", paste(bioc_installed, collapse = ", "))
    BiocManager::install(bioc_installed, ask = FALSE, update = FALSE)
  } else {
    message("✅ All Bioconductor packages already installed.")
  }
  
  # ----------------------------------------------------------- #
  # STEP 5 — Snapshot the environment into renv.lock            #
  # ----------------------------------------------------------- #
  message("📸 Snapshotting environment to renv.lock...")
  renv::snapshot()
  
}

# ------------------------------------------------------------- #
# STEP 6 — Verify all packages load correctly                   #
# ------------------------------------------------------------- #
required_packages <- c(
  "DESeq2", "apeglm",
  "ggplot2", "dplyr", "tibble",
  "pheatmap", "RColorBrewer", "here"
)

message("\n🔍 Verifying package installation...\n")

for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("✅", pkg, "\n")
  } else {
    cat("❌", pkg, "— FAILED to install, please check manually\n")
  }
}

message("\n🎉 Setup complete! You can now open 01_DESeq2_workshop.qmd")
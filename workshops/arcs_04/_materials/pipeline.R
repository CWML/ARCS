#!/usr/bin/env Rscript
# =====================================================================
# ARCS Part 4 — DESeq2 differential-expression pipeline
#
# *** SCAFFOLD / STAND-IN ***
# This is a complete, runnable placeholder so the Apptainer half of the
# workshop works end-to-end today. The DESeq2 instructor can replace the
# body with their pipeline as long as it honours the I/O contract in
# README.md (inputs: data/counts.csv + data/metadata.csv; outputs written
# to outputs/). See README.md for the exact column spec.
#
# Run from workshops/arcs_04/_materials:
#   apptainer exec ~/deseq2.sif Rscript pipeline.R
#
# Dataset: Shank3 / GSE113754 mouse RNA-seq — 20 samples,
#          genotype (WT / Shank3) x condition (normal / sleep_deprived).
# =====================================================================

# ---- Tunable parameters --------------------------------------------
# These are the levers to change in the LIVE demo. Edit PADJ, re-run, and
# watch the number of significant genes change — same image, same data,
# different question.
PADJ     <- 0.05                              # adjusted p-value cutoff
LFC      <- 0                                 # |log2 fold change| cutoff (0 = off)
CONTRAST <- c("genotype", "Shank3", "WT")    # factor, numerator, denominator

# ---- Paths (relative to _materials/, the working directory) ---------
COUNTS_CSV <- "data/counts.csv"
META_CSV   <- "data/metadata.csv"
OUT_DIR    <- "outputs"

suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
})

dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# ---- Load & align data ---------------------------------------------
counts <- as.matrix(read.csv(COUNTS_CSV, row.names = 1, check.names = FALSE))
meta   <- read.csv(META_CSV, row.names = 1, check.names = FALSE)
rownames(meta) <- meta$sample_id

# Put count columns in the same order as the metadata rows.
counts <- counts[, meta$sample_id, drop = FALSE]
stopifnot(all(colnames(counts) == meta$sample_id))

meta$genotype  <- factor(meta$genotype,  levels = c("WT", "Shank3"))
meta$condition <- factor(meta$condition, levels = c("normal", "sleep_deprived"))

# ---- Build dataset & run DESeq2 ------------------------------------
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData   = meta,
                              design    = ~ condition + genotype)
dds <- dds[rowSums(counts(dds)) >= 10, ]      # defensive low-count prefilter
dds <- DESeq(dds)

res <- results(dds, contrast = CONTRAST, alpha = PADJ)
res <- res[order(res$padj), ]

sig <- subset(as.data.frame(res),
              !is.na(padj) & padj < PADJ & abs(log2FoldChange) >= LFC)

# ---- Write result tables -------------------------------------------
write.csv(data.frame(gene = rownames(res), as.data.frame(res), row.names = NULL),
          file.path(OUT_DIR, "deseq2_results.csv"), row.names = FALSE)
write.csv(data.frame(gene = rownames(sig), sig, row.names = NULL),
          file.path(OUT_DIR, "significant_genes.csv"), row.names = FALSE)

# ---- PCA plot ------------------------------------------------------
vsd <- vst(dds, blind = TRUE)
ggsave(file.path(OUT_DIR, "pca_plot.png"),
       plotPCA(vsd, intgroup = c("genotype", "condition")) +
         ggtitle("PCA (variance-stabilized counts)"),
       width = 7, height = 5, dpi = 120)

# ---- Volcano plot --------------------------------------------------
vol <- as.data.frame(res)
vol$significant <- !is.na(vol$padj) & vol$padj < PADJ & abs(vol$log2FoldChange) >= LFC
ggsave(file.path(OUT_DIR, "volcano_plot.png"),
       ggplot(vol, aes(log2FoldChange, -log10(pvalue), color = significant)) +
         geom_point(alpha = 0.5, size = 0.8) +
         scale_color_manual(values = c(`FALSE` = "grey70", `TRUE` = "firebrick")) +
         labs(title = sprintf("Volcano: %s %s vs %s",
                              CONTRAST[1], CONTRAST[2], CONTRAST[3]),
              x = "log2 fold change", y = "-log10(p-value)") +
         theme_minimal(),
       width = 7, height = 5, dpi = 120)

# ---- Console summary -----------------------------------------------
cat("\n========================================================\n")
cat(sprintf("Contrast : %s  %s vs %s\n", CONTRAST[1], CONTRAST[2], CONTRAST[3]))
cat("Design   : ~ condition + genotype\n")
cat(sprintf("Cutoffs  : padj < %g   |log2FC| >= %g\n", PADJ, LFC))
cat(sprintf("Significant genes: %d  (of %d tested)\n",
            nrow(sig), sum(!is.na(res$padj))))
cat("Outputs written to: outputs/\n")
cat("========================================================\n\n")

#!/usr/bin/env Rscript
# =====================================================================
# ARCS Part 4 — Shank3 vs WT differential expression with DESeq2
#
# This is the SAME analysis you worked through in Hour 1
# (07-deseq2_pipeline.qmd), collected into a single script so it can be
# run non-interactively from inside the Apptainer container.
#
# Run from workshops/arcs_04/_materials:
#   apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R
#
# Dataset: Shank3 / GSE113754 mouse RNA-seq.
#   genotype  : WT | Shank3
#   condition : normal | sleep_deprived
# Following Hour 1, we keep only the NORMAL-condition samples, which
# reduces the design to a clean two-group comparison: ~ genotype.
# =====================================================================

# ---- Tunable parameters ---------------------------------------------
# These are the levers to change in the LIVE demo. Edit PADJ, re-run, and
# watch the number of significant genes change — same image, same data,
# a different question.
PADJ      <- 0.05      # adjusted p-value (FDR) cutoff
LFC       <- 1         # |log2 fold change| cutoff for calling a gene significant
CONDITION <- "normal"  # which condition to keep; "sleep_deprived" also works
REFERENCE <- "WT"      # baseline level — results read as <other> relative to this

# ---- Paths ----------------------------------------------------------
# Relative to _materials/, which is the working directory. Hour 1 used
# here::here() because it ran inside an RStudio/Positron project; a script
# run with `Rscript` from a known folder does not need it.
COUNTS_CSV <- file.path("processed_data", "Shank3_rawCounts_clean.csv")
META_CSV   <- file.path("processed_data", "Shank3_metadata_clean.csv")

# Hour 1 splits its outputs the same way, so the two hours produce identical
# folder structures and a student can compare them file for file.
FIG_DIR    <- file.path("outputs", "figures")
TAB_DIR    <- file.path("outputs", "tables")

suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
  library(dplyr)
  library(tibble)
  library(pheatmap)
  library(RColorBrewer)
})

for (d in c(FIG_DIR, TAB_DIR)) dir.create(d, showWarnings = FALSE, recursive = TRUE)

# =====================================================================
# Part 1 — Load and inspect the data
# =====================================================================
rawc <- read.csv(COUNTS_CSV, header = TRUE, row.names = 1, check.names = FALSE)
info <- read.csv(META_CSV,   header = TRUE, row.names = 1, stringsAsFactors = TRUE)

cat(sprintf("Loaded: %d genes x %d samples\n", nrow(rawc), ncol(rawc)))

# The count columns must line up with the metadata rows. Reorder rather
# than assume — a silent mismatch here corrupts every result downstream.
info$sample_id <- as.character(info$sample_id)
stopifnot(all(info$sample_id %in% colnames(rawc)))
rawc <- rawc[, info$sample_id, drop = FALSE]
stopifnot(identical(colnames(rawc), info$sample_id))

# =====================================================================
# Part 2 — Subset to a simple two-group comparison
# =====================================================================
# The full dataset crosses genotype with condition. Keeping one condition
# removes the second variable entirely, leaving a ~ genotype design that
# needs no interaction term to interpret.
info_sub <- info %>% filter(condition == CONDITION)
rawc_sub <- rawc[, info_sub$sample_id, drop = FALSE]

# Drop levels that no longer occur, then make WT the reference so results
# read as "Shank3 relative to WT".
info_sub$genotype <- droplevels(info_sub$genotype)
info_sub$genotype <- relevel(info_sub$genotype, ref = REFERENCE)

cat(sprintf("Subset to condition '%s': %d genes x %d samples\n",
            CONDITION, nrow(rawc_sub), ncol(rawc_sub)))

# =====================================================================
# Part 3 — Build the DESeq2 object and run the analysis
# =====================================================================
dds <- DESeqDataSetFromMatrix(countData = rawc_sub,
                              colData   = info_sub,
                              design    = ~ genotype)

# Pre-filter: keep genes with at least 10 counts in at least 3 samples.
keep <- rowSums(counts(dds) >= 10) >= 3
dds  <- dds[keep, ]
cat(sprintf("Genes remaining after filtering: %d\n", nrow(dds)))

dds <- DESeq(dds)

# =====================================================================
# Part 4 — Quality control
# =====================================================================
vsd <- vst(dds, blind = TRUE)

# ---- PCA ----
pca_data <- plotPCA(vsd, intgroup = "genotype", returnData = TRUE)
pct_var  <- round(100 * attr(pca_data, "percentVar"))

pca_plot <- ggplot(pca_data,
                   aes(x = PC1, y = PC2, color = genotype, label = name)) +
  geom_point(size = 4, alpha = 0.8) +
  geom_text(vjust = -0.8, size = 3) +
  labs(title = sprintf("PCA: Shank3 vs WT (%s condition)", CONDITION),
       x = paste0("PC1: ", pct_var[1], "% variance"),
       y = paste0("PC2: ", pct_var[2], "% variance")) +
  theme_classic(base_size = 13)

ggsave(file.path(FIG_DIR, "pca_plot.png"),
       pca_plot, width = 7, height = 5, dpi = 150)

# ---- Sample-to-sample distances ----
samp_dists <- dist(t(assay(vsd)))
samp_mat   <- as.matrix(samp_dists)
rownames(samp_mat) <- colnames(samp_mat) <-
  paste(colData(vsd)$genotype, colData(vsd)$sample_id, sep = " | ")

pheatmap(samp_mat,
         col = colorRampPalette(rev(brewer.pal(9, "Blues")))(255),
         clustering_distance_rows = samp_dists,
         clustering_distance_cols = samp_dists,
         main     = "Sample-to-Sample Distances",
         fontsize = 10,
         filename = file.path(FIG_DIR, "sample_distances.png"))

# =====================================================================
# Part 5 — Extract and shrink results
# =====================================================================
coef_name <- paste0("genotype_", setdiff(levels(info_sub$genotype), REFERENCE),
                    "_vs_", REFERENCE)
stopifnot(coef_name %in% resultsNames(dds))

# res        -> hypothesis testing
# res_shrunk -> ranking and visualisation (lfcShrink tames noisy low-count genes)
res        <- results(dds, name = coef_name, alpha = PADJ)
res_shrunk <- lfcShrink(dds, coef = coef_name, type = "apeglm")

# ---- MA plot ----
png(file.path(FIG_DIR, "ma_plot.png"), width = 700, height = 500, res = 120)
plotMA(res_shrunk, ylim = c(-5, 5), main = "MA Plot: Shank3 vs WT",
       alpha = PADJ, colSig = "#F44336", colNonSig = "grey60")
invisible(dev.off())

# ---- Volcano plot ----
res_df <- as.data.frame(res_shrunk) %>%
  rownames_to_column("gene") %>%
  filter(!is.na(padj)) %>%
  mutate(significance = case_when(
    padj < PADJ & log2FoldChange >  LFC ~ "Up in Shank3",
    padj < PADJ & log2FoldChange < -LFC ~ "Down in Shank3",
    TRUE                                ~ "Not significant"))

volcano_plot <- ggplot(res_df,
                       aes(x = log2FoldChange, y = -log10(padj),
                           color = significance)) +
  geom_point(alpha = 0.5, size = 1.5) +
  scale_color_manual(values = c("Up in Shank3"    = "#F44336",
                                "Down in Shank3"  = "#2196F3",
                                "Not significant" = "grey70")) +
  geom_vline(xintercept = c(-LFC, LFC), linetype = "dashed", color = "grey40") +
  geom_hline(yintercept = -log10(PADJ), linetype = "dashed", color = "grey40") +
  labs(title    = "Volcano Plot: Shank3 vs WT",
       subtitle = sprintf("Up: %d | Down: %d",
                          sum(res_df$significance == "Up in Shank3"),
                          sum(res_df$significance == "Down in Shank3")),
       x = "Log2 Fold Change (Shank3 / WT)",
       y = "-Log10 Adjusted P-value", color = NULL) +
  theme_classic(base_size = 13) +
  theme(legend.position = "top")

ggsave(file.path(FIG_DIR, "volcano_plot.png"),
       volcano_plot, width = 8, height = 6, dpi = 150)

# ---- Counts for the single most significant gene ----
if (any(!is.na(res$padj))) {
  top_gene <- rownames(res)[which.min(res$padj)]
  cat(sprintf("Most significant gene: %s\n", top_gene))

  png(file.path(FIG_DIR, "top_gene_counts.png"),
      width = 600, height = 400, res = 120)
  plotCounts(dds, gene = top_gene, intgroup = "genotype", pch = 19,
             main = paste("Normalized Counts:", top_gene))
  invisible(dev.off())
}

# =====================================================================
# Part 6 — Export tables
# =====================================================================
res_all <- as.data.frame(res_shrunk) %>%
  rownames_to_column("gene") %>%
  arrange(padj)

res_sig <- res_all %>%
  filter(!is.na(padj), padj < PADJ, abs(log2FoldChange) > LFC)

write.csv(res_all, file.path(TAB_DIR, "deseq2_results.csv"), row.names = FALSE)
write.csv(res_sig, file.path(TAB_DIR, "significant_genes.csv"), row.names = FALSE)

write.csv(counts(dds, normalized = TRUE),
          file.path(TAB_DIR, "normalized_counts.csv"), row.names = TRUE)

# =====================================================================
# Summary — the number the live demo watches
# =====================================================================
cat("\n========================================================\n")
cat(sprintf("Contrast : genotype  %s vs %s\n",
            setdiff(levels(info_sub$genotype), REFERENCE), REFERENCE))
cat(sprintf("Design   : ~ genotype   (condition == '%s' only)\n", CONDITION))
cat(sprintf("Cutoffs  : padj < %g   |log2FC| > %g\n", PADJ, LFC))
cat(sprintf("Significant genes: %d  (of %d tested)\n",
            nrow(res_sig), sum(!is.na(res$padj))))
cat("Outputs written to: outputs/figures/ and outputs/tables/\n")
cat("========================================================\n\n")

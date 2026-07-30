#!/usr/bin/env Rscript
# =====================================================================
# ARCS Part 4 — Shank3 vs WT differential expression with DESeq2
#
# This is the Hour 1 lesson (07-deseq2_pipeline.qmd) as a single
# non-interactive script, so it can be run from inside the Apptainer
# container. The processing steps, thresholds, variable names and output
# filenames all match the lesson exactly — run both and you get identical
# results, which is the whole point of Hour 2.
#
# Run from workshops/arcs_04/_materials:
#   apptainer exec ~/deseq2.sif Rscript scripts/pipeline.R
#
# Differences from the .qmd, none of which affect the outputs:
#   - interactive display calls (print, head, summary, sessionInfo, the
#     dev.new() second heatmap, the inline plotMA) are omitted; a script
#     has no graphics device and they write no files
#   - here::here() is replaced by paths relative to _materials/, which is
#     the working directory when the container runs
# =====================================================================

# ---- Tunable parameters ---------------------------------------------
# The levers for the LIVE demo. Defaults match the lesson exactly; edit
# PADJ, re-run, and watch the significant-gene count change.
PADJ      <- 0.05      # FDR cutoff for results() and the exported DEG table
LFC       <- 1         # |log2 fold change| cutoff for the exported DEG table
CONDITION <- "normal"  # condition to keep; "sleep_deprived" also works
REFERENCE <- "WT"      # baseline level — results read as Shank3 relative to WT

# Plot-only threshold. The lesson colours the MA and volcano plots at
# padj < 0.1 while exporting tables at padj < 0.05; kept as-is so the
# figures match Hour 1 exactly.
PADJ_PLOT <- 0.1

# ---- Run tagging ----------------------------------------------------
# Every output gets this suffix, so re-running never overwrites an earlier
# run. That is what makes Step 5 work: change PADJ, re-run, and compare the
# new volcano against the previous one side by side instead of losing it.
#
# Set RUN_ID <- "" to write the bare filenames Hour 1 produces, which is
# what you want when checking that the two hours agree.
RUN_ID <- format(Sys.time(), "%Y%m%d-%H%M%S")

# Insert RUN_ID before the file extension: "x.png" -> "x_20260730-144530.png"
tag <- function(filename) {
  if (!nzchar(RUN_ID)) return(filename)
  ext  <- tools::file_ext(filename)
  stem <- tools::file_path_sans_ext(filename)
  sprintf("%s_%s.%s", stem, RUN_ID, ext)
}

# ---- Paths ----------------------------------------------------------
path_counts   <- file.path("processed_data", "Shank3_rawCounts_clean.csv")
path_metadata <- file.path("processed_data", "Shank3_metadata_clean.csv")
path_figures  <- file.path("outputs", "figures")
path_tables   <- file.path("outputs", "tables")

for (dir in c(path_figures, path_tables)) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat("Created:", dir, "\n")
  }
}

suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
  library(dplyr)
  library(tibble)
  library(pheatmap)
  library(RColorBrewer)
  library(apeglm)      # reached by lfcShrink(type = "apeglm"), not called directly
})

# =====================================================================
# Part 2 — Load & inspect the data
# =====================================================================
clean_counts <- read.csv(path_counts,   header = TRUE, row.names = 1)
clean_info   <- read.csv(path_metadata, header = TRUE, stringsAsFactors = TRUE)

cat("Dimensions: ", nrow(clean_counts), "genes x", ncol(clean_counts), "samples\n")

# Counts columns must match metadata sample_ids, in order.
if (!all(colnames(clean_counts) == clean_info$sample_id)) {
  stop("Sample names do not match between counts and metadata — reorder before proceeding")
}

# =====================================================================
# Part 3 — Subset to a simple two-group comparison
# =====================================================================
info_sub   <- clean_info %>% filter(condition == CONDITION)
counts_sub <- clean_counts[, info_sub$sample_id]

info_sub$genotype <- droplevels(info_sub$genotype)
info_sub$genotype <- relevel(info_sub$genotype, ref = REFERENCE)

cat("Subsetted dataset:", nrow(counts_sub), "genes x", ncol(counts_sub), "samples\n")

# =====================================================================
# Part 4 — Build the DESeq2 object
# =====================================================================
dds <- DESeqDataSetFromMatrix(countData = counts_sub,
                              colData   = info_sub,
                              design    = ~ genotype)

# Keep genes with at least 10 counts in at least 3 samples.
keep <- rowSums(counts(dds) >= 10) >= 3
dds  <- dds[keep, ]

cat("Genes remaining after filtering:", nrow(dds), "\n")

# =====================================================================
# Part 5 — Run DESeq2
# =====================================================================
dds <- DESeq(dds)

# =====================================================================
# Part 6 — Quality control
# =====================================================================
vsd <- vst(dds, blind = TRUE)

# ---- 6.2 PCA plot ----
pca_data <- plotPCA(vsd, intgroup = "genotype", returnData = TRUE)
pct_var  <- round(100 * attr(pca_data, "percentVar"))

pca_plot <- ggplot(pca_data, aes(x = PC1, y = PC2, color = genotype, label = name)) +
  geom_point(size = 4, alpha = 0.8) +
  geom_text(vjust = -0.8, size = 3) +
  scale_color_manual(values = c("WT" = "#2196F3", "Shank3" = "#F44336")) +
  labs(title = "PCA: Shank3 vs WT (normal condition)",
       x = paste0("PC1: ", pct_var[1], "% variance"),
       y = paste0("PC2: ", pct_var[2], "% variance")) +
  theme_classic(base_size = 13) +
  theme(legend.position = "right")

ggsave(filename = file.path(path_figures, tag("PCA_Shank3vsWT.png")),
       plot = pca_plot, width = 7, height = 5, dpi = 300)

# ---- 6.3 Sample distance heatmap ----
samp_dists <- dist(t(assay(vsd)))
samp_mat   <- as.matrix(samp_dists)

rownames(samp_mat) <- colnames(samp_mat) <-
  paste(colData(vsd)$genotype, colData(vsd)$sample_id, sep = " | ")

colors <- colorRampPalette(rev(brewer.pal(9, "Blues")))(255)

pheatmap(samp_mat, col = colors,
         clustering_distance_rows = samp_dists,
         clustering_distance_cols = samp_dists,
         main = "Sample-to-Sample Distances", fontsize = 10,
         filename = file.path(path_figures, tag("SampleDistances_Shank3vsWT.png")))

# =====================================================================
# Part 7 — Extract & interpret results
# =====================================================================
coef_name <- paste0("genotype_",
                    setdiff(levels(info_sub$genotype), REFERENCE),
                    "_vs_", REFERENCE)
stopifnot(coef_name %in% resultsNames(dds))

# res        -> hypothesis testing
# res_shrunk -> ranking and visualisation
res        <- results(dds, name = coef_name, alpha = PADJ)
res_shrunk <- lfcShrink(dds, coef = coef_name, type = "apeglm")

# ---- 7.4 MA plot ----
png(file.path(path_figures, tag("MAplot_Shank3vsWT.png")),
    width = 700, height = 500, res = 120)
plotMA(res_shrunk, ylim = c(-5, 5),
       main      = "MA Plot: Shank3 vs WT",
       alpha     = PADJ_PLOT,
       colSig    = "#F44336",
       colNonSig = "grey60")
invisible(dev.off())

# ---- 7.5 Volcano plot ----
res_df <- as.data.frame(res_shrunk) %>%
  rownames_to_column("gene") %>%
  filter(!is.na(padj)) %>%
  mutate(
    significance = case_when(
      padj < PADJ_PLOT & log2FoldChange > 0 ~ "Up in Shank3",
      padj < PADJ_PLOT & log2FoldChange < 0 ~ "Down in Shank3",
      TRUE                                  ~ "Not significant"
    )
  )

deg_counts <- table(res_df$significance)

volcano_plot <- ggplot(res_df, aes(x = log2FoldChange, y = -log10(padj),
                                   color = significance)) +
  geom_point(alpha = 0.5, size = 1.5) +
  scale_color_manual(values = c(
    "Up in Shank3"    = "#F44336",
    "Down in Shank3"  = "#2196F3",
    "Not significant" = "grey70"
  )) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "grey40") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey40") +
  labs(
    title    = "Volcano Plot: Shank3 vs WT",
    subtitle = paste0("Up: ",    deg_counts["Up in Shank3"],
                      " | Down: ", deg_counts["Down in Shank3"]),
    x = "Log2 Fold Change (Shank3 / WT)",
    y = "-Log10 Adjusted P-value",
    color = NULL
  ) +
  theme_classic(base_size = 13) +
  theme(legend.position = "top")

ggsave(file.path(path_figures, tag("Volcano_Shank3vsWT.png")),
       plot = volcano_plot, width = 8, height = 6, dpi = 300)

# =====================================================================
# Part 8 — Export results
# =====================================================================
res_all <- as.data.frame(res_shrunk) %>%
  rownames_to_column("gene") %>%
  arrange(padj)

res_sig <- res_all %>% filter(padj < PADJ, abs(log2FoldChange) > LFC)

cat("Total DEGs (padj <", PADJ, ", |LFC| >", LFC, "):", nrow(res_sig), "\n")

write.csv(res_all, file = file.path(path_tables, tag("DESeq2_Shank3vsWT_allGenes.csv")),
          row.names = FALSE)
write.csv(res_sig, file = file.path(path_tables, tag("DESeq2_Shank3vsWT_sigDEGs.csv")),
          row.names = FALSE)

norm_counts <- counts(dds, normalized = TRUE)
write.csv(norm_counts, file = file.path(path_tables, tag("normCounts_Shank3vsWT.csv")),
          row.names = TRUE)

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
if (nzchar(RUN_ID)) {
  cat(sprintf("Run ID   : %s   (appended to every output filename)\n", RUN_ID))
}
cat("Tables  -> outputs/tables/\n")
cat("Figures -> outputs/figures/\n")
cat("========================================================\n\n")

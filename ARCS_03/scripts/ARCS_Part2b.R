# title: "Introduction to Programming in R Part 2: Data Structures and Reports"
# author: "Levi Dolan"
# Date: "2025/2026"

#----Reports----#

# EXERCISE 1
# Convert README.txt 
# 1. Navigate to your README.txt file in your R Project folder for ARCS (PC: Windows Explorer; Mac: Finder)
# 2. Right click (Mac: control + right click) on the file and select "Rename"
# 3. Change the file extension ".txt" to ".qmd". (Mac: type ".qmd" after "README").
# 4. Accept the file extension change and save the file. 
# 5. Go back to RStudio, and open your README.qmd file (if you already had it open, RStudio will ask
#    if you want to close the .txt file, say yes and then reopen the README.qmd file).
# 6. Add triple back ticks ( ``` ) before and after your README's file structure tree.
# 7. In the Source pane (upper left) menu, click on the "-> Render" button.
# 8. A browser window should pop up and display your README.qmd file as HTML in your browser. 
# 9. Notice that this browser window's address starts with "localhost" followed by a port number. 
#    This shows that your computer is serving your .qmd file locally to itself. 

# EXERCISE 2
# Automate README.qmd updates
# 1. Check to see if you have this library installed by running the line below:
library(fs)
# if not, in your Console run:
install.packages(fs)

# 2. Copy the script below 
#| echo: false
#| message: false
#| results: asis

library(fs)

# Get the actual structure
tree_output <- capture.output(dir_tree(".", recurse = 2))

# Define comments for specific files/folders
comments <- list(
  "raw_data" = " (original data goes here)",
  "processed_data" = " (clean data goes here)", 
  "scripts" = " (code goes here)",
  "outputs" = " (results and charts go here)",
  "README.qmd" = " (project documentation)"
)

# Add comments to matching lines
for(item in seq_along(tree_output)) {
  line <- tree_output[item]
  for(name in names(comments)) {
    if(grepl(name, line)) {
      tree_output[item] <- paste0(line, comments[[name]])
      break
    }
  }
}

# Print the result
cat("```\n")
cat(paste(tree_output, collapse = "\n"))
cat("\n```\n")

# 3. Paste this script in between the triple back ticks ( ``` ) in your README.qmd file
# 4. Next to the first set of triple back ticks, add {r} (repeat these steps for every code block)
# 5. Save your new README.qmd file
# 6. In the Source pane (upper left) menu, click on the "Render" button.
# 7. Go back to your browser window where your README.qmd previously rendered to see the result!
# 8. Make any changes that you would like to see in the "comments <- list()" function and re-render.

#----Script for Automating README Updates----#

#| echo: false
#| message: false
#| results: asis

library(fs)

# Get the actual structure
tree_output <- capture.output(dir_tree(".", recurse = 2))

# Define comments for specific files/folders
comments <- list(
  "raw_data" = " (original data goes here)",
  "processed_data" = " (clean data goes here)", 
  "scripts" = " (code goes here)",
  "outputs" = " (results and charts go here)",
  "README.qmd" = " (project documentation)"
)

# Add comments to matching lines
for(item in seq_along(tree_output)) {
  line <- tree_output[item]
  for(name in names(comments)) {
    if(grepl(name, line)) {
      tree_output[item] <- paste0(line, comments[[name]])
      break
    }
  }
}

# Print the result
cat("```\n")
cat(paste(tree_output, collapse = "\n"))
cat("\n```\n")

# EXERCISE 3
# Create a Quarto Document for Publishing
# 1. Check to see if you have the following libraries (packages) installed 
# by running the lines below:

library(tidyverse)
library(readxl)
library(scales)

# If not, use install.packages(name_of_library) in your console to install
# (You can also check in your File Manager > Packages tab (lower right) by searching 
# for a library by name. Tick the box next to the library if you see it unticked.)

# 2. Install the PLOS template for Quarto:
#     - In your terminal, type this and hit enter: quarto add quarto-journals/plos
#     - Then type this and hit enter: quarto use template quarto-journals/plos

# 3. Run the code below:

#| message: false
#| warning: false

# Prepare data - rename the first column and use both ID columns
gene_data_long <- gene_data %>%
  # Rename the first column for clarity
  rename(ensembl_id = `...1`) %>%
  # Remove rows where gene_symbol is missing
  filter(!is.na(gene_symbol), gene_symbol != "") %>%
  # Convert to long format, keeping both ID columns
  pivot_longer(cols = -c(ensembl_id, gene_symbol), 
               names_to = "sample", 
               values_to = "expression")

# Calculate variance for each gene across all samples
gene_variability <- gene_data_long %>%
  group_by(gene_symbol, ensembl_id) %>%
  summarise(
    mean_expression = mean(expression, na.rm = TRUE),
    variance = var(expression, na.rm = TRUE),
    coefficient_of_variation = sd(expression, na.rm = TRUE) / mean_expression,
    .groups = 'drop'
  )

# Identify top 15 most variable genes
top_genes <- gene_variability %>%
  arrange(desc(variance)) %>%
  slice_head(n = 15)

# Display summary statistics
cat("Total genes analyzed:", nrow(gene_variability), "\n")
cat("Mean variance across all genes:", round(mean(gene_variability$variance, na.rm = TRUE), 2), "\n")
cat("Most variable gene:", top_genes$gene_symbol[1], "with variance =", round(top_genes$variance[1], 2), "\n")

# Show the top 10 most variable genes
cat("\nTop 10 most variable genes:\n")
print(top_genes %>% 
        select(gene_symbol, variance) %>% 
        slice_head(n = 10) %>%
        mutate(variance = round(variance, 2)))

# 4. Paste the code from step #3 (previous step) into your publication.qmd file underneath the heading
## Gene Variability Analysis.
# (Start your code block with ```{r} and close it with ``` if you have not already done this.)
# 5. Run the code below (for data visualization):
#| fig-cap: "Expression heatmap showing scaled expression levels of the 15 most variable genes across all samples. Blue indicates below-average expression, white indicates average expression, and red indicates above-average expression for each gene."
#| fig-width: 10
#| fig-height: 6

# Prepare heatmap data
heatmap_data <- gene_data_long %>%
  # Filter to include only the most variable genes
  filter(gene_symbol %in% top_genes$gene_symbol) %>%
  # Join with variance data for proper ordering
  left_join(top_genes %>% select(gene_symbol, variance), by = "gene_symbol") %>%
  # Calculate scaled expression values within each gene
  group_by(gene_symbol) %>%
  mutate(scaled_expr = scale(expression)[,1]) %>%
  ungroup()

# Create heatmap visualization
expression_heatmap <- heatmap_data %>%
  ggplot(aes(x = sample, y = reorder(gene_symbol, variance), fill = scaled_expr)) +
  geom_tile(color = "white", linewidth = 0.1) +
  scale_fill_gradient2(
    low = "blue", 
    mid = "white", 
    high = "red",
    name = "Scaled\nExpression",
    limits = c(-3, 3),
    oob = scales::squish
  ) +
  labs(
    title = "Expression Variability Heatmap: Top 15 Most Variable Genes",
    subtitle = "Genes ordered by variance (highest at top)",
    x = "Sample ID", 
    y = "Gene Symbol"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    axis.text.y = element_text(size = 10, face = "italic"),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "right",
    panel.grid = element_blank()
  )

print(expression_heatmap)

# Save high-resolution figure
ggsave(paste0("outputs/", timestamp, "_expression_heatmap.png"), 
       plot = expression_heatmap, width = 10, height = 6, dpi = 300)
# 6. Paste the code into your publication.qmd file underneath ## Data Visualization
# Remember to start your code block with ```{r} and end with ``` 
# 7. Render your publication.qmd document to see your PLOS-formatted article

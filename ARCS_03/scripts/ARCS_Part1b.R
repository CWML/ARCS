# title: "Introduction to Programming in R Part 1: Fundamentals and Project Management"
# author: "Levi Dolan"
# Date: "2025/2026"

# ----Project Management----

# STEP 1
# Create an R Project
# 1. Click "Create a Project" icon (second from left in RStudio top menu bar)
# 2. If prompted, save any current files that have been changed
# 3. Select "Existing Directory" option
# 4. Make sure that you are in your "ARCS" folder
# 5. Click "Create Project" button (you will see a .Rproj file appear in File Manager)
# 6. Navigate to Tools > Project Options
# 7. Click Git/SVN in the left column 
# 8. Under the "Version control system" dropdown menu, select "Git" and confirm
# 9. Restart RStudio when prompted
# 10. Notice the new files that exist in your ARCS folder (which is now an R project):
#       a. .Rproj
#       b. .gitignore

# STEP 2
# Organize your R Project
# 1. In the RStudio Files pane (lower right), click the "Create a new folder" icon
# 2. Create four new folders called:
#       a. raw_data
#       b. processed_data
#       c. scripts
#       d. outputs
# 3. Move the files from GREIN into the "raw_data" folder
#       a. In the RStudio Files pane, tick the boxes next to:
#           GSE113754_GeneLevel_Raw_data.xlsx
#           GSE113754_filtered_metadata.csv
#       b. Click on the gear icon dropdown menu
#       c. Select "Move"
#       d. Navigate to your "raw_data" folder and click "Open" (on Mac)
#       e. Open the "raw_data" folder to confirm you moved the files
# 4. Move any files ending in .R into the "scripts" folder
#       a. In the RStudio Files pane, tick the boxes next to .R files
#       b. Click on the gear icon dropdown menu
#       c. Select "Move"
#       d. Navigate to your "scripts" folder and click "Open" (on Mac)
#       e. Open the "scripts" folder to confirm you moved the files

# STEP 3 
# Write a README
# 1. Confirm that you are in the root directory of your R project (in your ARCS folder)
# 2. In the RStudio Files pane, click "create a new file in the current directory" dropdown
#    (icon second from left)
# 3. Select "Text File"
# 4. Name new text file "README" and click "OK"
# 5. Copy the text in lines 54-71 and paste into your README.txt file (open in another window):

# README

## Project title: ARCS_series

## In this project:

## What this project does:
#TODO write a one-sentence description in your own words
#
## How to use this project:
# 1. Open the .Rproj file
# 2. Run "scripts/*.R"
# 3. Look for results in the "output/" folder

## About the data:
# This data was retrieved through the Geo RNA-seq Experiments Interactive Navigator
# GREIN web platform, which interfaces with the NIH's Gene Expression Omnibus (GEO) repository. 
# Link to dataset: https://www.ilincs.org/apps/grein/?gse=GSE113754 

# 6. Go to your web browser and paste in this URL:
#     https://tree.nathanfriend.com/
# 7. In the left pane, recreate your folder and file structure from your R project
#       a. start with ARCS as the root
#       b. indent for each folder: 
#           raw_data
#           processed_data
#           scripts
#           outputs
#       c. indent again and add the files from GREIN:
#           GSE113754_GeneLevel_Raw_data.csv
#           GSE113754_filtered_metadata.csv
#       d. add any .R files (indented underneath "scripts")
# 8. When you are happy with the results, click the "Copy" button
# 9. Paste your folder structure diagram into your README underneath "in this project"
# 10. Write a short description of what each folder contains
#     (for instance, next to raw_data you could write "(original data goes here)")

#SCRIPTS FOR R PROJECT MANAGEMENT

# Metadata Cleaning for Analysis
# This script creates the metadata file that we need for further analysis
# It is the same example used to contrast with Excel in this class
library(dplyr)
library(stringr)

# Load data
metadata <- read.csv("raw_data/GSE113754_filtered_metadata.csv", header = TRUE, stringsAsFactors = TRUE)

# Create the desired output format
metadata_parsed <- metadata %>%
  dplyr::mutate(
    # Clean up genotype column - convert "Shank3 Mutant" to "Shank3"
    genotype = case_when(
      str_detect(genotype, "WT") ~ "WT",
      str_detect(genotype, "Shank3") ~ "Shank3",
      TRUE ~ as.character(genotype)
    ),
    
    # Extract condition from characteristics column,format and store in a new column called "Condition" 
    Condition = case_when(
      str_detect(characteristics, "homecage control") ~ "_normal",
      str_detect(characteristics, "sleep deprivation") ~ "_sleep_deprived",
      TRUE ~ "Unknown"
      ),
    
    # Create Geno_Cond column by combining results from the "genotype" and "Condition" column mutations
    Geno_Cond = paste(genotype, str_remove(Condition, "^_"), sep = "_")
  ) %>%
  # Select only the columns you want in the final output
  dplyr::select(Sample = 1, genotype, Condition, Geno_Cond)  # assuming first column is Sample

# Check the result
head(metadata_parsed)

# Save to CSV
write.csv(metadata_parsed, "Shank3_metadata_parsed.csv", row.names = FALSE)


# Automate Filenaming
# This script demonstrates how to automatically add a timestamp to any R function 
# and store the result in your outputs folder as a new file each time you call the function

# Load required libraries
library(readxl)
library(writexl)
library(dplyr)
library(lubridate)

# Configuration section
CONFIG <- list(
  input_file = "raw_data/GSE113754_GeneLevel_Raw_data.xlsx",  # Update this path
  output_folder = "outputs", # Update this path
  prefix = "LD_ProjectARCS"
)

# Function to generate timestamped filename
generate_filename <- function(prefix, analysis_type = "", extension = ".xlsx") {
  timestamp <- format(Sys.time(), "%Y%m%dT%H%M%S")  # ISO 8601 format
  if (analysis_type != "") {
    filename <- paste0(timestamp, "_", prefix, "_", analysis_type, extension)
  } else {
    filename <- paste0(timestamp, "_", prefix, extension)
  }
  return(filename)
}

# Function to ensure output directory exists
ensure_output_dir <- function(output_folder) {
  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
    cat("Created output directory:", output_folder, "\n")
  }
}

# Function to load Excel data
load_excel_data <- function(file_path, sheet = 1) {
  cat("Loading data from:", file_path, "\n")
  data <- read_excel(file_path, sheet = sheet)
  cat("Data loaded successfully. Dimensions:", dim(data), "\n")
  return(data)
}

# Function to save results
save_results <- function(data, output_folder, prefix, analysis_type = "") {
  ensure_output_dir(output_folder)
  filename <- generate_filename(prefix, analysis_type)
  full_path <- file.path(output_folder, filename)
  
  write_xlsx(data, full_path)
  cat("Results saved to:", full_path, "\n")
  return(full_path)
}

# Analysis functions (examples - customize these for your needs)

# Analysis 1: Basic summary statistics
analysis_summary_stats <- function(df, output_folder, prefix) {
  cat("\n=== Running Summary Statistics Analysis ===\n")
  
  # Example manipulation: create summary statistics
  summary_data <- df %>%
    summarise_if(is.numeric, list(
      mean = ~mean(., na.rm = TRUE),
      median = ~median(., na.rm = TRUE),
      sd = ~sd(., na.rm = TRUE),
      min = ~min(., na.rm = TRUE),
      max = ~max(., na.rm = TRUE)
    ))
  
  # Save results
  save_path <- save_results(summary_data, output_folder, prefix, "summary_stats")
  return(summary_data)
}

# Analysis 2: Filtered data analysis
analysis_filtered_data <- function(df, output_folder, prefix, filter_condition = NULL) {
  cat("\n=== Running Filtered Data Analysis ===\n")
  
  # Example manipulation: filter and process data
  if (!is.null(filter_condition)) {
    processed_data <- df %>%
      filter(eval(parse(text = filter_condition))) %>%
      arrange(desc(if(is.numeric(.[,1])) .[,1] else row_number()))
  } else {
    # Default: just sort by first column if numeric
    processed_data <- df %>%
      arrange(if(is.numeric(.[,1])) desc(.[,1]) else .[,1])
  }
  
  # Save results
  save_path <- save_results(processed_data, output_folder, prefix, "filtered_data")
  return(processed_data)
}

# Analysis 3: Grouped analysis
analysis_grouped <- function(df, output_folder, prefix, group_by_col = NULL) {
  cat("\n=== Running Grouped Analysis ===\n")
  
  if (!is.null(group_by_col) && group_by_col %in% names(df)) {
    # Group by specified column and summarize
    grouped_data <- df %>%
      group_by(across(all_of(group_by_col))) %>%
      summarise_if(is.numeric, list(
        count = ~n(),
        mean = ~mean(., na.rm = TRUE),
        sum = ~sum(., na.rm = TRUE)
      ), .groups = 'drop')
  } else {
    # Default: create a simple count by first non-numeric column
    first_char_col <- names(select_if(df, is.character))[1]
    if (!is.null(first_char_col)) {
      grouped_data <- df %>%
        count(across(all_of(first_char_col)), name = "frequency") %>%
        arrange(desc(frequency))
    } else {
      grouped_data <- data.frame(note = "No grouping column available")
    }
  }
  
  # Save results
  save_path <- save_results(grouped_data, output_folder, prefix, "grouped_analysis")
  return(grouped_data)
}

# Main execution function
run_analysis <- function() {
  cat("=== Starting Analysis Pipeline ===\n")
  cat("Timestamp:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")
  
  # Load the original data (never modified)
  original_data <- load_excel_data(CONFIG$input_file)
  
  # Create a working copy for manipulations
  working_data <- original_data
  
  # Run multiple analyses
  results <- list()
  
  # Analysis 1: Summary Statistics
  results$summary <- analysis_summary_stats(
    working_data, 
    CONFIG$output_folder, 
    CONFIG$prefix
  )
  
  # Analysis 2: Filtered Data (example filter - modify as needed)
  results$filtered <- analysis_filtered_data(
    working_data, 
    CONFIG$output_folder, 
    CONFIG$prefix
    # filter_condition = "column_name > 100"  # Uncomment and modify as needed
  )
  
  # Analysis 3: Grouped Analysis (specify grouping column as needed)
  results$grouped <- analysis_grouped(
    working_data, 
    CONFIG$output_folder, 
    CONFIG$prefix
    # group_by_col = "category_column"  # Uncomment and specify column name
  )
  
  cat("\n=== Analysis Pipeline Complete ===\n")
  cat("All results saved to:", CONFIG$output_folder, "\n")
  
  return(results)
}

# Helper function to run individual analyses
run_single_analysis <- function(analysis_type, ...) {
  original_data <- load_excel_data(CONFIG$input_file)
  working_data <- original_data
  
  switch(analysis_type,
         "summary" = analysis_summary_stats(working_data, CONFIG$output_folder, CONFIG$prefix),
         "filtered" = analysis_filtered_data(working_data, CONFIG$output_folder, CONFIG$prefix, ...),
         "grouped" = analysis_grouped(working_data, CONFIG$output_folder, CONFIG$prefix, ...),
         stop("Unknown analysis type. Use 'summary', 'filtered', or 'grouped'")
  )
}

# Example usage:
# Update the CONFIG section above with your file paths, then run:

# Run all analyses:
# results <- run_analysis()

# Or run individual analyses:
summary_result <- run_single_analysis("summary")
filtered_result <- run_single_analysis("filtered", filter_condition = "column_name > 50")
grouped_result <- run_single_analysis("grouped", group_by_col = "category")

cat("Script loaded successfully!\n")
cat("To use:\n")
cat("1. Update the CONFIG section with your file paths\n")
cat("2. Run: results <- run_analysis()\n")
cat("3. Or run individual analyses with: run_single_analysis('analysis_type')\n")


#testing git commits
adding more text

# This is our first tracked change.
print("Hello from R!")

#ntest

{r}
#| eval: false
# Load and explore data
data <- mtcars
summary(data)
# Create a simple plot
plot(data$mpg, data$hp, 
     xlab = "Miles per Gallon", 
     ylab = "Horsepower")

# This is our first tracked change.
print("Hello from R!")


# title: "Introduction to Programming in R Part 2: Data Structures and Reports"
# author: "Sofia Fertuzinhos, PhD"
# Date: "2025/2026"

#---- Opening Project  ----#



#---- Importing data set into RStudio ----#

# Activating readr package (to learn more run in console 
# help(package = "*package_name*"))

library(readr)

# importing data set tables with read.csv() 
# (to learn more run in console ?*function_name*)

# 1. Table containing raw counts at the gene level

rawc <- read.csv("raw_data/GSE113754_GeneLevel_Raw_data_3.csv")

# 2. Table containing the information about the sequenced samples - metadata

info <- read.csv("raw_data/GSE113754_filtered_metadata.csv")


#---- Inspecting the structure of the data set  ----#

# Find what type of structure our objects have with function class()

class(rawc)

class(info)

# Find the type of data stored in an object with function typeof() 

typeof(rawc)

typeof(info)

# Exercise 1: Find the type of data stored in a specific column of an object
# using $ after the object name 

typeof(rawc$GSM3119002)

# Find the dimensions of the both tables we imported using dim() 

dim(rawc)

dim(info)

# Find more detailed information about the overall structure of an object with
# function str() 

str(rawc)

str(info)

# To have an idea of the type of data and some minimal statistics it is common
# to use the function summary()

summary(rawc)

# For example, when applied to a numeric vector, summary() returns a five-number summary
# and the mean:
#       Min.: The minimum value in the vector.
#    1st Qu.: The first quartile (25th percentile) of the data.
#     Median: The median (50th percentile) of the data.
#       Mean: The arithmetic mean of the data.
#    3rd Qu.: The third quartile (75th percentile) of the data.
#       Max.: The maximum value in the vector.

# For character variables, summary() provides:
#     Length: The total number of elements in the vector.
#      Class: The data type, which will be "character".
#       Mode: The storage mode, which will be "character".


#---- Alternative ways to inspect of missing values ----#

# To check if there is any "Not Available" or Missing values we can use several
# function. 

# to get a general idea of whether an object has any NA or missing data 
# we can use *anyNA(rawc)*

# For a more granular analysis we can use the function is.na()

# run the line below

is.na(c(1, NA, 3, 6, 0))

# This function can be impractical when looking at a big data frame like
# object rawc. 

#---- Manipulating specific data points ----#

# The selection or inspection of specific elements or subsets
# of data are made easier in R by the use of elements numerical position or
# index. In R, elements numbering starts with 1. Note, Python uses a 0-based
# indexing.

# In the rawc object, we know that we have a NA value in a specific column.
# (i.e., $GSM3119015). To retrieve the specific row where this NA value
# is, we can nest the function is.na() inside the function which().

which(is.na(rawc$GSM3119015 == "NA")) # conditional codes: 
                                      #  ==  equal 
                                      #  !=  not equal 
                                      #   >  greater than 
                                      #   <  less than
                                      #  >=  greater than or equal to 
                                      #  <=  less than or equal to 
                                      # %in% including


# We can confirm if the NA value is in row number 1059 of object rawc using
# *table*[*row* , *column*]

rawc[1059, ]

------
# Note:

# 1. Indexing Vectors:
# By Position: Elements can be accessed by their numerical position. 
# Example: first element in a vector is index 1 - *vector*[1]

# 2. Indexing Matrices and Data Frames:
# By Position (Row, Column): For 2-dimensional objects, indexing uses a comma
# to separate row and column indices -
# Example: Element in the first row and second column would be retrieved
# using *table*[1,2]
-----
  
# Exercise 2: Fix the NA value by using it's positional coordinates, 
# row and column indexes or names

rawc[1059, "GSM3119015" ] <- 0
rawc[1059, ]

# Let's turn now to the info object and inspect what type of unique values
# can we find using the functions unique() and table()

unique(info$genotype)

table(info$genotype)

# For an organized view of the whole table we can apply the same function

sapply(info, unique)

sapply(info, table)

#---- Data cleaning and sub-setting using indexing ----#

# Changing specific column names using function *colnames()* and [] to change 
# the names of the first three columns

colnames(info)[1:3] <- c("sample_id", "condition", "genotype")

# note: *colnames()* function retrieves a vector, therefore we only need []
# without comma because a vector is a one dimensional data structure.

# Remove redundant column *genotype.ch1* using its index number
info <- info[,-4]

# Clean up genotype column - convert "Shank3 Mutant" to "Shank3", format and
# store in column called "genotype"

genotype_clean <- ifelse(grepl("WT", info$genotype),                      # test
                         "WT",                                            # yes
                         ifelse(grepl("Shank3", info$genotype), "Shank3", # no
                                as.character(info$genotype )))             #  

# Extract housing condition information from condition column, 
# format and store in column "condition"

condition_clean <- ifelse(grepl("homecage control", info$condition), # test
                          "normal",                                        # yes
                          ifelse(grepl("sleep deprivation", info$condition),# no
                                 "sleep_deprived",
                                 as.character(info$condition)))

# Create a vector for a new column with name Geno_Cond by combining the new
# "genotype" and "condition" columns separated by "_"

geno_cond <- paste(genotype_clean, condition_clean, sep = "_")

# Create the final data frame with selected columns

info_clean <- data.frame(
  sample_id = info[, 1],  # assuming first column is sample_id
  genotype = genotype_clean,
  condition = condition_clean,
  geno_cond = geno_cond
)

# Check the result

head(info_clean)


#---- Data harmonization ----#

# Data harmonization is the process of collecting and unifying disparate data
# from various sources and formats into a consistent, standardized, and
# meaningful format, making it compatible for integration and analysis.

# We have two tables that we need to harmonize in order to conduct
# analysis such, differential gene expression analysis.

# Specifically, we need to make sure that the samples on the object rawc 
# (raw counts) are in the same number and order as in object info
# (metadata).

# To do so, we can use the function identical()

identical(colnames(rawc), info_clean$sample_id)

# Lets have a closer look at the columns names of object rawc

colnames(rawc)

# Lets have a closer look at the row names of object info_clean

info_clean$sample_id

# To harmonize objects rawc and info we need to:
# 1 - Create a vector by merging columns 2 and 3, using 
#    * paste() function 
#    * | to separate Ensemble gene ID from Gene Symbols
#    * [,] to manipulate specific columns 2 and 3. 

gene_id <- paste(rawc[, 2], rawc[, 3], sep = "|")

# 2 - Create a new data frame by:
#     * keeping only columns with the same name and order specified in info,
# 3 - set as gene_id merged column as row names so it is not interpreted as data 
# for analysis

rawc_clean <- data.frame(
  rawc[ ,info_clean$sample_id],  # Keep only GSM columns
  row.names = gene_id)

# Save new metadata and raw counts tables as .csv files in processed data
# folder.

write.csv(info_clean, "processed_data/Shank3_metadata_clean.csv")
write.csv(rawc_clean, "processed_data/Shank3_rawCounts_clean.csv")



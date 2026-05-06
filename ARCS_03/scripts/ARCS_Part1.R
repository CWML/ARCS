# title: "Introduction to Programming in R Part 1: Fundamentals and Project Management"
# author: "Sofia Fertuzinhos, PhD"
# Date: "2025/2026" 

#---- Setting up the working directory ----#

# What is your working directory? 

# Run the function getwd() ((to learn more about any function run
# in the console ?*function_name*))

getwd()

# For the sake of simplifying reading data into RStudio/R, we need to set our
# working directory to the folder where our data is located. 

# In Rstudio you can do so by using Files space in the bottom right quarter
# 1- Select folder where your data is located
# 2- Hit the blue mechanical wheel in the tool bar of Files (bottom right
# quadrant)
# 3- Select "Set as Working directory"

# Notice in your console that a code will appear similar to this:

setwd("/Users/justin/Desktop/ARCS")

# Indeed, setwd() is the programmatic way to establish a working directory.
# One just needs to know and write the full path to the folder where our data is.


#---- Four Basic rules to write code in the source ----#

# 1. Use # to annotate/document your code

# 2. Use a noticeable pattern to break between coding chunks such as
               #----- ------#
          ########################

# 3. When writing code notice that we can write numbers and basic arithmetic 
# equations just as if on a paper

#random number
2025
# Summation
1+1
# Subtraction
1-1
# Multiplication
1*2
# Division
2/1
# Exponentiation
2^2

# Note: if you use the symbol colon : you will get the range of
# numbers indicated

4:8
8:4

# 3. Contrarily to numbers, letter need to be written between quotation marks ""

# Exercise 1: Write and run: Hello world!
 


# Exercise 2: Now write and run: "Hello world!"

"Hello, World!"

# Exception: characters/letters defining the name of an 
# *object* can be written without "".


#---- Storing information in R objects ----#

# Objects simplify data manipulation. Objects result from assigning to a name
# values or data we want to transform/analyse. This data can then be easily
# used and re-used. This way, we don't have to repeat operations.

# To create an object, we need: 

# *name* <- *data*

# This way we are assigning to objects on the left the values on the right. 

# Exercise 3: run lines 61, 66 and 77, one at a time

x <- "X marks the spot of the " 

# You have now stored in the object x the information on the right. That object
# is now seen in your environment (top right quadrant of RStudio).

x

# When now you run x, R retrieves the information stored in it.

paste0(x, "treasure.") 

# Finally, you can manipulate the information stored in the object by simply
# using the object name, saving you from repeating operations. 

# Let's play a little more! Fill the blank:

paste0(x, c("treasure.", " gold", " 2"))

 
#---- Tricks and rules to create R objects ----#

# 1. It is good practice to always use <- instead of = .

# 2. Key board shortcut to type <-  

# on a PC:

# Alt & - (push Alt at the same time as the - key),

# on a Mac:

# Option & - (push Option at the same time as the - key) 

y <- "ten"

# 3. An R object can have almost any name. However, there are some
# important considerations:
 
# - No empty spaces (the code will not run)
# - Cannot start with numbers (2x is not valid, but x2 is)
# - Cannot have the same name as functions (it gets confusing)


# Exercise 4: 
# a) assign your age to an object (give it a descriptive name) 


age <- 38

# b) subtract your object to the current year to obtain your birth 
# year.

2025 - age

?c()
#----- Vectors ----# 

# A vector is the most common and basic data structure 
# in R.

# A vector is composed by a series of values of one specific data type.

# There are 5 main types of data : 

# - double or numeric (numbers with decimals such as 1.2), 
# - integer (whole number such as 10),
# - complex (numbers with an imaginary component such as 2i),
# - logical (True or False)
# - character (string of caracters such as "Sofia")

# To create a vector we use the function *c()* (learn more with ?c()). 

#----- Note: Functions, arguments and Packages ----# 

# Functions like *c()* are “canned scripts” that automate
# more complicated sets of commands including operations
# assignments, etc. 

# A function often (but not always) takes one or more inputs called
# *arguments*. But this is not always true. 

# Functions often (but not always) return a value. 

# Many functions are predefined, or can be made available 
# by importing R *packages* (more on that later). 

#---- -----#

# Exercise 5: make a vector by combining the ages of four individuals you know
# with the function *c()*, separating the ages with commas,
# and assign that vector to an object (name the object).

FamilyAges <- c(14,36,3,4)

MyAge <- age
# Now we can manipulate the information in the vector
# by simply using the name of the object, no need for
# quotation marks "".

# Exercise 6: subtract the vector you created in Exercise 5, 
# to our current year.
2025 - FamilyAges


# Exercise 7: assign to a new object, the equation we did in Exercise 6

FamilyBirthYears <- 2025 - FamilyAges


rm(age)
#----- Tabular data ----#

# Matrices and data frames are both two-dimensional data structures used
# to store tabular data (rows and columns), but they differ primarily in
# the types of data they can contain and their underlying structure.

# Data frames contain heterogeneous data and are the **de facto** data 
# structure for tabular data in R, and what we will most commonly use for data
# processing, statistics, and plotting. 

# A data.frame is really a list of vectors, in which all the vectors
# must have the same length and are arranged in columns.

# A matrix can only store data of a single class or type. All elements within
# a matrix must be of the same data type (e.g., all numeric, all character or
# all logical)

# A matrix is essentially a vector with added dimension attributes
# (number of rows and columns).


# Let's pack the two vectors we have created into a data frame using
# the function *data.frame()* (learn more with ?data.frame()).

df_FamInfo <- data.frame(FamilyAges, FamilyBirthYears)

# Since the two vectors are numeric, we can combine the two vectors and
# create into a matrix with the function *matrix()* (learn more with ?matrix()).

mx_FamInfo <- matrix(c(FamilyAges, FamilyBirthYears), nrow = 4, ncol = 2)

#Let's look at both tables to see how they look

df_FamInfo

mx_FamInfo


#----- Note: quick inspection of top and bottom of tables ----# 

# Use functions such as *head()* or *tail()*, to inspect tables with more than 
# 6 rows (learn by running code ?head() and ?tail())

#---- ----#
head(df_FamInfo)

# The advantage of using data frame format instead of
# matrix, is that we can combine different data types in the same table
 
# To exemplify, let's create a vector with characters. 

# Exercise 6: Assign to a new object a vector containing
# the names your family members with the correspondent ages described in
# the vector we have previously created.

FamNames <- c("Steve French","Lisa","Grace","Finn")


# Exercise 7: Let's add the vector containing the names to 
# the data frame that we created in Exercise 5 using the  
# function *cbind()* (learn more with ?cbind())

?cbind()
df_FamInfo <- cbind(df_FamInfo, FamNames)

dfdf_FamInfo
# Exercise 8: What to you think it will happen if use *cbind()* 
# to add a character vector to our matrix?

mx_FamInfo <- cbind(mx_FamInfo, FamNames)
df_FamInfo
mx_FamInfo



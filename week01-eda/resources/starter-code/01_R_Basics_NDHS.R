###############################################################################
# ADA GLOBAL ACADEMY - MicroMasters: Data Science, AI & Research Methods
# SESSION 1 (HOUR 1): "R FOR COMPLETE BEGINNERS"
# Using the Nigeria NDHS 2024 Children's Recode dataset (NGKR8BFL)
#
# GOAL OF THIS SESSION:
#   - Get comfortable with RStudio
#   - Learn what R "objects" are (numbers, text, vectors, data frames)
#   - Learn how to load a real dataset and look at it
#   - Learn basic operations: select columns, filter rows, summarise
#
# HOW TO USE THIS FILE:
#   - This is a normal R script (.R), NOT an RMarkdown file.
#   - Run each line/section with: CTRL + ENTER (Windows) or CMD + ENTER (Mac)
#   - Read the comments (lines starting with #) - they explain everything.
#   - Nothing here is "too simple" - we build up slowly on purpose.
###############################################################################


###############################################################################
# PART 0 - WELCOME TO RSTUDIO
###############################################################################

# RStudio has 4 main windows (panes):
#   1. SOURCE (top-left)     - this script. Where you write code.
#   2. CONSOLE (bottom-left) - where code actually runs, and results appear.
#   3. ENVIRONMENT (top-right) - shows the "objects" you've created.
#   4. FILES/PLOTS/HELP (bottom-right) - file browser, charts, help pages.

# Try it now: click on the line below, then press CTRL+ENTER (or CMD+ENTER)
print("Hello, NDHS class! Welcome to R.")

# Notice the result appears in the CONSOLE below. That's how R works:
# you write code here, and R "runs" it and shows you the answer.


###############################################################################
# PART 1 - R AS A CALCULATOR
###############################################################################

# R can do basic maths, just like a calculator.

2 + 2
10 - 3
6 * 7
100 / 4
2 ^ 3        # "^" means "to the power of" -> 2 cubed = 8

# Run each line above one at a time and watch the Console.


###############################################################################
# PART 2 - "OBJECTS": STORING INFORMATION WITH NAMES
###############################################################################

# In R, we save information into "objects" using the arrow: <-
# Think of an object as a labelled box that holds a value.

children_surveyed <- 27783     # a number (numeric)
country_name      <- "Nigeria" # a piece of text (character / string)
survey_year       <- 2024      # also a number

# To SEE what is inside a box, just type its name and run it:
children_surveyed
country_name
survey_year

# You can do maths with number-objects too:
children_surveyed / 1000   # how many thousand children, roughly

# IMPORTANT: R is case-sensitive.
# "country_name" and "Country_Name" are NOT the same object.


###############################################################################
# PART 3 - VECTORS: A LIST OF VALUES IN ONE BOX
###############################################################################

# A "vector" is simply a collection of values of the same type.
# We create one using c() which means "combine".

regions <- c("North West", "North East", "North Central",
              "South East", "South South", "South West")

regions            # see all 6 regions
regions[1]         # the FIRST item (R counts from 1, not 0)
regions[3]         # the THIRD item
length(regions)    # how many items are in this vector?

# A numeric vector example: stunting rates (made-up example numbers)
example_rates <- c(54.2, 48.7, 35.1, 22.4, 18.9, 15.3)

mean(example_rates)   # average
max(example_rates)    # highest value
min(example_rates)    # lowest value
sort(example_rates)   # arrange from smallest to largest


###############################################################################
# PART 4 - LOADING THE PACKAGES (TOOLS) WE NEED
###############################################################################

# R comes with basic tools built in, but for real data work we use
# extra "packages" - like apps you install on a phone.

# STEP A: INSTALL the packages (only needs to be done ONCE on your computer).
# Remove the # from the lines below and run them ONCE, then put the # back.

# install.packages("tidyverse")  # data wrangling + plotting (run once)
# install.packages("skimr")      # nice summary statistics (run once)

# STEP B: LOAD the packages (do this every time you start a new R session)
library(tidyverse)   # gives us functions like filter(), select(), mutate()
library(skimr)       # gives us the skim() summary function

cat("Packages loaded successfully. You're ready to load data!\n")


###############################################################################
# PART 5 - LOADING THE NDHS DATASET
###############################################################################

# Make sure the file "NGKR8BFL (1).csv" is saved in the SAME FOLDER
# as this R script. In RStudio, go to:
#   Session > Set Working Directory > To Source File Location
# This tells R "look for files in the same folder as this script".

ndhs <- read.csv("NGKR8BFL (1).csv")

# Let's look at this new object. A dataset in R is called a "data frame":
# think of it like an Excel spreadsheet - rows and columns.

# How many rows (children) and columns (variables) do we have?
nrow(ndhs)   # number of children
ncol(ndhs)   # number of variables (columns)
dim(ndhs)    # both at once: rows, columns

# See the FIRST 6 rows (like the top of an Excel sheet)
head(ndhs)

# See the column (variable) NAMES
names(ndhs)

# Click on "ndhs" in the Environment pane (top-right) to view it
# like a spreadsheet - or run:
# View(ndhs)


###############################################################################
# PART 6 - SELECTING COLUMNS WE CARE ABOUT
###############################################################################

# The full dataset has HUNDREDS of columns. For our class, we only need a few:
#   hw70 = HAZ (height-for-age z-score, x100)
#   b4   = sex of child
#   b8   = child's age in years
#   v024 = region
#   v025 = urban/rural
#   v106 = mother's education level
#   v190 = household wealth quintile
#   v005 = sample weight

# select() picks specific columns and keeps them, in this order:
ndhs_small <- ndhs %>%
  select(hw70, b4, b8, v024, v025, v106, v190, v005)

# %>% is called the "pipe". Read it as "and then".
# So the line above means:
#   "Take ndhs, AND THEN select these columns, AND THEN save as ndhs_small"

head(ndhs_small)
dim(ndhs_small)


###############################################################################
# PART 7 - LOOKING AT ONE COLUMN AT A TIME
###############################################################################

# Use $ to grab a single column from a data frame:

ndhs_small$b4      # sex column (1 = male, 2 = female, in DHS coding)
ndhs_small$hw70    # HAZ values (still x100, with codes like 9999 = missing)

# table() counts how many of each value appear - useful for categories:
table(ndhs_small$b4)

# Quick summary of a numeric column:
summary(ndhs_small$hw70)


###############################################################################
# PART 8 - FILTERING ROWS (KEEPING ONLY WHAT WE WANT)
###############################################################################

# filter() keeps only rows that match a condition.

# Example: keep only male children (b4 == 1)
boys_only <- ndhs_small %>%
  filter(b4 == 1)

nrow(boys_only)   # how many boys?

# Example: keep only children aged exactly 1 year (b8 == 1)
age1 <- ndhs_small %>%
  filter(b8 == 1)

nrow(age1)

# You can combine conditions with & (AND) or | (OR):
# Example: boys aged 1
boys_age1 <- ndhs_small %>%
  filter(b4 == 1 & b8 == 1)

nrow(boys_age1)


###############################################################################
# PART 9 - CREATING NEW COLUMNS WITH mutate()
###############################################################################

# mutate() creates a NEW column based on existing ones.

# DHS stores HAZ multiplied by 100 (e.g. -152 means -1.52).
# Let's fix that, and also turn the missing-value codes (>= 9996) into NA.

ndhs_small <- ndhs_small %>%
  mutate(
    haz = ifelse(hw70 >= 9996, NA, hw70 / 100)
  )

# Check it worked:
summary(ndhs_small$haz)

# NA means "Not Available" / missing - R understands this is "no data",
# not zero, and will exclude it from most calculations automatically
# if we tell it to with na.rm = TRUE (we'll use this a lot).

mean(ndhs_small$haz, na.rm = TRUE)   # average HAZ, ignoring missing values


###############################################################################
# PART 10 - RECODING NUMBERS INTO LABELS
###############################################################################

# v025 = 1 means "Urban", v025 = 2 means "Rural".
# Numbers like "1" and "2" don't mean anything to a reader -
# let's give them real labels using recode().

ndhs_small <- ndhs_small %>%
  mutate(
    residence = recode(v025, `1` = "Urban", `2` = "Rural")
  )

table(ndhs_small$residence)


###############################################################################
# PART 11 - YOUR FIRST SUMMARY TABLE
###############################################################################

# group_by() + summarise() is one of the most useful combinations in R.
# It means: "split the data into groups, then calculate something for each."

# Example: average HAZ for Urban vs Rural children
ndhs_small %>%
  group_by(residence) %>%
  summarise(
    average_haz   = mean(haz, na.rm = TRUE),
    children_count = n()
  )

# Read this as:
#   "Take ndhs_small, AND THEN group by residence,
#    AND THEN calculate the average HAZ and count of children per group."


###############################################################################
# PART 12 - YOUR FIRST PLOT
###############################################################################

# ggplot2 (part of tidyverse) builds plots in LAYERS, joined with "+"

ggplot(data = ndhs_small %>% filter(!is.na(haz)),
       aes(x = haz)) +
  geom_histogram(bins = 40, fill = "#22784F") +
  labs(
    title = "Distribution of HAZ (Height-for-Age) - Nigeria NDHS 2024",
    x     = "HAZ Z-score",
    y     = "Number of children"
  )

# Read this as:
#   "Use ndhs_small (without missing HAZ) as the data,
#    AND THEN map 'haz' to the x-axis,
#    AND THEN draw a histogram,
#    AND THEN add a title and axis labels."


###############################################################################
# PART 13 - QUICK RECAP / CHEAT SHEET
###############################################################################

# <-              : assign a value to a name        (x <- 5)
# c(...)          : combine values into a vector     (c(1,2,3))
# %>%             : pipe, "and then"
# read.csv()      : load a CSV file as a data frame
# head()          : show first few rows
# names()         : show column names
# select()        : keep specific columns
# filter()        : keep specific rows based on a condition
# mutate()        : create/change a column
# recode()        : turn number codes into readable labels
# group_by()      : split data into groups
# summarise()     : calculate summary values per group
# table()         : count values in a categorical column
# summary()       : quick stats for a numeric column
# mean(x, na.rm = TRUE) : average, ignoring missing values
# ggplot()        : start building a plot
# is.na(x)        : TRUE if a value is missing


###############################################################################
# END OF HOUR 1
# Next hour: full Exploratory Data Analysis (EDA) on this same dataset,
# focused on understanding stunting (HAZ) across Nigeria.
# See: 02_EDA_HAZ_NDHS.R
###############################################################################

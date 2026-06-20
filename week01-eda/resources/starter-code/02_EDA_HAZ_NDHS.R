###############################################################################
# ADA GLOBAL ACADEMY - MicroMasters: Data Science, AI & Research Methods
# SESSION 1 (HOUR 2): EXPLORATORY DATA ANALYSIS (EDA)
# Nigeria NDHS 2024 - Children's Recode (NGKR8BFL)
# Outcome variable: HAZ (Height-for-Age Z-score) -> measures STUNTING
#
# WHAT YOU WILL PRODUCE TODAY:
#   A complete EDA on the HAZ variable, with tables, plots and
#   interpretations, that you will write up into a short report.
#
# FILE TO USE: NGKR8BFL (1).csv  (same folder as this script)
#
# HOW TO USE THIS FILE:
#   - Plain R script (.R) - run section by section with CTRL+ENTER / CMD+ENTER
#   - Read each comment block BEFORE running the code below it
#   - "Interpretation" comments explain what the output means
#   - "YOUR NOTES" sections are for YOU to fill in during class
###############################################################################


###############################################################################
# STEP 0 - INSTALL PACKAGES (RUN ONCE ONLY)
###############################################################################
# Run this block ONCE in your Console if these packages are not yet installed.
# Then leave it commented out / skip it on future runs.

install.packages(c(
  "tidyverse",   # data wrangling and plotting
  "skimr",       # summary statistics
   "e1071",       # skewness function
   "corrplot",    # correlation heatmap
   "patchwork",   # combine multiple plots
   "knitr"        # nice tables (kable)
))


###############################################################################
# STEP 1 - LOAD LIBRARIES AND DATA
###############################################################################

## 1.1 Load libraries -------------------------------------------------------

library(tidyverse)
library(skimr)
library(e1071)
library(corrplot)
library(patchwork)
library(knitr)

cat("All libraries loaded successfully.\n")

# WHAT THIS DOES: We load the packages (tools) that R needs to run the
# analysis. Think of them like apps you open before you use them.


## 1.2 Load the dataset ------------------------------------------------------

# Make sure "NGKR8BFL (1).csv" is in the SAME FOLDER as this script.
df_raw <- read.csv("NGKR8BFL (1).csv")

df_raw <- df_raw[, c("hw70","hw71","hw72","hw1","b4","b5","b8",
                      "v024","v025","v106","v190","v005")]
nrow(df_raw)

cat("Raw dataset loaded:\n")
cat("  Rows (children):", format(nrow(df_raw), big.mark = ","), "\n")
cat("  Columns (variables selected):", ncol(df_raw), "\n")

1# WHAT THIS DOES: We read the DHS dataset file. It has 27,783 children and
# 12 variables covering height, weight, age, region, wealth, and education.


## 1.3 Clean and prepare the data --------------------------------------------

# DHS stores Z-scores multiplied by 100 (e.g. -1.52 is stored as -152).
# Codes 9996, 9997, 9998 mean "invalid" - we replace them with NA (missing).
df_raw$hw70
df_raw$v024

df <- df_raw %>%
  mutate(
    haz = ifelse(as.numeric(hw70) >= 9996, NA, as.numeric(hw70) / 100),

    region = recode(as.numeric(v024),
      `1` = "North West",    `2` = "North East",
      `3` = "North Central", `4` = "South East",
      `5` = "South South",   `6` = "South West"),

    residence = recode(as.numeric(v025),
      `1` = "Urban", `2` = "Rural"),

    wealth = recode(as.numeric(v190),
      `1` = "Poorest", `2` = "Poorer", `3` = "Middle",
      `4` = "Richer",  `5` = "Richest"),

    educ = recode(as.numeric(v106),
      `0` = "No education", `1` = "Primary",
      `2` = "Secondary",    `3` = "Higher"),

    sex = recode(as.numeric(b4), `1` = "Male", `2` = "Female"),

    wealth = factor(wealth,
      levels = c("Poorest","Poorer","Middle","Richer","Richest")),
    educ   = factor(educ,
      levels = c("No education","Primary","Secondary","Higher")),
    region = factor(region,
      levels = c("North West","North East","North Central",
                 "South East","South South","South West")),

    wt = as.numeric(v005) / 1e6
  )

cat("After preprocessing:\n")
cat("  Total children:", format(nrow(df), big.mark = ","), "\n")
cat("  Children with valid HAZ:", sum(!is.na(df$haz)), "\n")

# WHAT THIS DOES: We fix the Z-scores (divide by 100) and replace invalid
# codes with NA. We also label the region, wealth, and education categories
# with their real names so the tables and plots are easier to read.


###############################################################################
# STEP 2 - DESCRIPTIVE STATISTICS
###############################################################################

## 2.1 Missing values ---------------------------------------------------------
library(tidyr)
missing_report <- df %>%
  select(haz, region, residence, wealth, educ, sex, b8) %>%
  summarise(across(everything(),
    ~ round(mean(is.na(.)) * 100, 1),
    .names = "{.col}")) %>%
  pivot_longer(everything(),
               names_to  = "Variable",
               values_to = "Missing_%") %>%
  arrange(desc(`Missing_%`))

print(kable(missing_report, caption = "Table 1: Missing Value Summary (%)"))

# INTERPRETATION: HAZ shows about 66% missing, which is normal for DHS -
# only children who were physically measured during the survey have these
# values. All other variables (region, wealth, education) have no missing
# data.


## 2.2 Summary statistics for HAZ ---------------------------------------------
library(skimr)
# skim() gives mean, standard deviation, percentiles, and a mini histogram
df %>%
  select(`HAZ (Stunting)` = haz) %>%
  skim()

# INTERPRETATION: The HAZ mean is negative (below 0), meaning Nigerian
# children on average fall below the WHO reference population. A strongly
# negative mean indicates stunting is widespread.


## 2.3 Stats table with skewness ----------------------------------------------
library(e1071)
stats_tbl <- df %>%
  summarise(across((haz), list(
    Mean     = ~ round(mean(.,     na.rm = TRUE), 3),
    Median   = ~ round(median(.,   na.rm = TRUE), 3),
    SD       = ~ round(sd(.,       na.rm = TRUE), 3),
    Min      = ~ round(min(.,      na.rm = TRUE), 3),
    Max      = ~ round(max(.,      na.rm = TRUE), 3),
    Skewness = ~ round(skewness(., na.rm = TRUE), 3)
  ), .names = "{.col}_{.fn}")) %>%
  pivot_longer(everything()) %>%
  separate(name, into = c("Variable", "Statistic"), sep = "_(?=[^_]+$)") %>%
  pivot_wider(names_from = Statistic, values_from = value) %>%
  mutate(Variable = recode(Variable,
    "haz" = "HAZ (Stunting)"))

print(kable(stats_tbl,
            caption = "Table 2: Summary Statistics for Child HAZ Z-Score"))

# INTERPRETATION: The mean HAZ is below zero (around -1.5), confirming
# stunting is a major concern. Negative skewness means many children have
# very low scores - a long left tail toward severe malnutrition.


## 2.4 National malnutrition prevalence ---------------------------------------

# WHO cutoff: Z-score below -2 = malnourished (stunted); below -3 = severe.
df <- df %>%
  mutate(
    stunted     = as.integer(haz < -2),
    sev_stunted = as.integer(haz < -3)
  )

prev_tbl <- df %>%
  summarise(
    `Stunting (%)`        = round(mean(stunted,     na.rm = TRUE) * 100, 1),
    `Severe Stunting (%)` = round(mean(sev_stunted, na.rm = TRUE) * 100, 1)
  ) %>%
  pivot_longer(everything(),
               names_to  = "Indicator",
               values_to = "Prevalence (%)")

print(kable(prev_tbl,
            caption = "Table 3: National Stunting Prevalence, Nigeria NDHS 2024"))

# INTERPRETATION: Stunting (low height-for-age) affects a large share of
# children nationally. Severe stunting represents the most critical group.


## 2.5 Prevalence by region -----------------------------------------------------

region_prev <- df %>%
  filter(!is.na(region)) %>%
  group_by(Region = region) %>%
  summarise(
    `Stunting (%)` = round(mean(stunted, na.rm = TRUE) * 100, 1),
    N              = n()
  ) %>%
  arrange(desc(`Stunting (%)`))

print(kable(region_prev, caption = "Table 4: Stunting Prevalence by Region (%)"))

# INTERPRETATION: Northern regions (North West, North East) consistently
# show the highest stunting rates. Southern regions generally have lower
# prevalence, suggesting a strong geographic divide in child nutrition.


## 2.6 Wealth and education distribution ----------------------------------------

cat("Wealth Index Distribution:\n")
df %>%
  count(wealth) %>%
  mutate(Percentage = round(n / sum(n) * 100, 1)) %>%
  rename(Quintile = wealth, Count = n) %>%
  kable(caption = "Table 5: Household Wealth Index Distribution") %>%
  print()

cat("\nMother's Education Level:\n")
df %>%
  count(educ) %>%
  mutate(Percentage = round(n / sum(n) * 100, 1)) %>%
  rename(`Education Level` = educ, Count = n) %>%
  kable(caption = "Table 6: Mother's Education Distribution") %>%
  print()

# INTERPRETATION: The sample is spread across wealth quintiles, with
# slightly more children from poorer households. A large proportion of
# mothers have no formal education or only primary schooling, which has
# important implications for child nutrition outcomes.


###############################################################################
# STEP 3 - VISUALISE DISTRIBUTIONS
###############################################################################
## 3.1 HAZ histogram (Figure 1) -------------------------------------------------
library(patchwork)
make_hist <- function(var, title, outcome_label) {
  prev <- round(mean(df[[var]] < -2, na.rm = TRUE) * 100, 1)

  ggplot(df %>% filter(!is.na(.data[[var]])),
         aes(x = .data[[var]])) +
    geom_histogram(aes(y = after_stat(density)),
                   bins  = 50,
                   fill  = "#22784F",
                   alpha = 0.75) +
    geom_density(color = "#C5A028", linewidth = 1.1) +
    geom_vline(xintercept = -2, color = "#C5A028",
               linetype = "dashed", linewidth = 1.0) +
    geom_vline(xintercept = -3, color = "#7B1C2E",
               linetype = "dotted", linewidth = 1.0) +
    labs(
      title    = title,
      subtitle = paste0(outcome_label, " prevalence: ", prev, "%"),
      x        = "Z-Score",
      y        = "Density",
      caption  = "Dashed = -2 SD  |  Dotted = -3 SD"
    ) +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(face = "bold"))
}

p_haz <- make_hist("haz", "Height-for-Age (HAZ)", "Stunting")
#p_haz <- make_hist("waz", "Weight-for-Age (WAZ)", "Underweight")

print(
  (p_haz) +
    plot_annotation(
      title    = "Figure 1: Child HAZ Z-Score Distribution",
      subtitle = "Nigeria NDHS 2024 - Children's Recode (NGKR8BFL)"
    )
)

# ggsave("fig1_haz_distribution.png", width = 14, height = 4.5, dpi = 150)

# INTERPRETATION: The distribution is shifted to the left of zero, with a
# large portion of children falling below the -2 SD cutoff line - confirming
# that stunting is severe and prevalent in this sample.


## 3.2 HAZ by region (Figure 2) --------------------------------------------------

print(
  ggplot(
    df %>% filter(!is.na(haz), !is.na(region)),
    aes(x    = reorder(region, haz, FUN = median),
        y    = haz,
        fill = region)
  ) +
    geom_boxplot(alpha = 0.70, outlier.size = 0.6, outlier.alpha = 0.20,
                 show.legend = FALSE) +
    geom_hline(yintercept = -2, color = "#C5A028",
               linetype = "dashed", linewidth = 1.0) +
    geom_hline(yintercept = -3, color = "#7B1C2E",
               linetype = "dotted", linewidth = 1.0) +
    scale_fill_brewer(palette = "Greens") +
    labs(
      title    = "Figure 2: Height-for-Age Z-Score Distribution by Region",
      subtitle = "Nigeria NDHS 2024 | Regions sorted by median HAZ (worst to best)",
      x        = "Geopolitical Zone",
      y        = "Height-for-Age Z-Score (HAZ)",
      caption  = "Dashed = -2 SD  |  Dotted = -3 SD"
    ) +
    theme_minimal(base_size = 11) +
    theme(plot.title  = element_text(face = "bold"),
          axis.text.x = element_text(angle = 15, hjust = 1))
)

# INTERPRETATION: Northern regions have median HAZ values well below -2,
# meaning the average child there is stunted by WHO standards. Southern
# regions sit higher, though all regions still have medians below zero,
# showing malnutrition is a national - not just northern - challenge.


## 3.3 HAZ by residence (Figure 3) -----------------------------------------------

pv1 <- ggplot(
  df %>% filter(!is.na(haz), !is.na(residence)),
  aes(x = residence, y = haz, fill = residence)
) +
  geom_violin(alpha = 0.75, draw_quantiles = c(0.25, 0.50, 0.75),
              show.legend = FALSE) +
  geom_hline(yintercept = -2, color = "#C5A028",
             linetype = "dashed", linewidth = 1) +
  scale_fill_manual(values = c("Urban" = "#22784F", "Rural" = "#7B1C2E")) +
  labs(title = "HAZ by Residence Type", x = "Residence", y = "HAZ Score") +
  theme_minimal(base_size = 10) +
  theme(plot.title = element_text(face = "bold"))

print(
  (pv1) +
    plot_annotation(
      title    = "Figure 3: HAZ Distribution by Residence Type",
      subtitle = "Nigeria NDHS 2024"
    )
)

# INTERPRETATION: Rural children have lower HAZ scores than urban children,
# and the gap is substantial - confirming that residence type is linked
# to nutrition outcomes.


###############################################################################
# STEP 4 - CORRELATION ANALYSIS
###############################################################################

## 4.1 Build the correlation matrix -----------------------------------------------

# We use Spearman correlation because wealth and education are ranked
# categories (not continuous numbers), and Spearman works well for ranked data.

corr_df <- df %>%
  transmute(
    HAZ         = haz,
    Wealth      = as.numeric(v190),
    MothersEduc = as.numeric(v106),
    Residence   = as.numeric(v025),
    ChildAge    = as.numeric(b8)
  ) %>%
  drop_na()

cat("Complete cases for correlation:", nrow(corr_df), "\n\n")

corr_mat <- cor(corr_df, method = "spearman")

cat("Spearman Correlation Matrix:\n")
print(round(corr_mat, 3))

# INTERPRETATION: Wealth and mother's education show positive correlations
# with HAZ - richer, more educated households tend to have better-nourished
# children.


## 4.2 Correlation heatmap (Figure 4) ----------------------------------------------

# The heatmap colour shows the strength of each correlation
# Green = positive (good), Red = negative, White = no relationship
library(corrplot)
corrplot(
  corr_mat,
  method      = "color",
  type        = "upper",
  addCoef.col = "black",
  number.cex  = 0.80,
  tl.col      = "black",
  tl.cex      = 0.90,
  tl.srt      = 45,
  col = colorRampPalette(c("#7B1C2E", "white", "#22784F"))(200),
  title = "Figure 4: Spearman Correlation Matrix\nNigeria NDHS 2024",
  mar = c(0, 0, 3.5, 0)
)

# INTERPRETATION: The heatmap confirms wealth and maternal education have
# the strongest positive links with HAZ. Residence (urban vs rural) also
# correlates with HAZ, while child age shows weaker and mixed associations.


## 4.3 Top correlations table ---------------------------------------------------------
install.packages("tibble")
library(tibble)
library(tidyverse)
corr_pairs <- corr_mat %>%
  as.data.frame() %>%
  rownames_to_column("Var1") %>%
  pivot_longer(-Var1, names_to = "Var2", values_to = "rho") %>%
  filter(match(Var1, colnames(corr_mat)) > match(Var2, colnames(corr_mat))) %>%
  mutate(
    abs_rho   = abs(rho),
    Strength  = case_when(
      abs_rho >= 0.7 ~ "Strong",
      abs_rho >= 0.5 ~ "Moderate",
      abs_rho >= 0.3 ~ "Weak",
      TRUE           ~ "Negligible"
    ),
    Direction = ifelse(rho > 0, "Positive", "Negative")
  ) %>%
  arrange(desc(abs_rho)) %>%
  select(Var1, Var2, rho = rho, Strength, Direction)

print(kable(corr_pairs, digits = 3,
            caption = "Table 7: All Pairwise Spearman Correlations (ranked by |rho|)"))

# INTERPRETATION: Among predictors, wealth typically shows the highest
# correlation with HAZ, followed by maternal education.


###############################################################################
# STEP 5 - OUTLIER DETECTION
###############################################################################

## 5.1 IQR and Z-score outlier summary ---------------------------------------------

# The IQR method flags values that fall very far outside the middle 50% of
# data. For health data like this, these are often real extreme cases,
# not errors.

outlier_check <- function(var_name, label) {
  x   <- df[[var_name]][!is.na(df[[var_name]])]
  Q1  <- quantile(x, 0.25)
  Q3  <- quantile(x, 0.75)
  IQR <- Q3 - Q1

  n_iqr <- sum(x < Q1 - 1.5*IQR | x > Q3 + 1.5*IQR)
  n_z   <- sum(abs(scale(x)) > 3)

  tibble(
    Variable      = label,
    `N valid`     = length(x),
    `Lower fence` = round(Q1 - 1.5*IQR, 2),
    `Upper fence` = round(Q3 + 1.5*IQR, 2),
    `IQR flagged` = n_iqr,
    `% flagged`   = round(n_iqr / length(x) * 100, 1),
    `Z-score |>3|`= n_z
  )
}

outlier_tbl <- map_dfr(
  list(c("haz","HAZ (Stunting)")),
  ~ outlier_check(.x[1], .x[2])
)

print(kable(outlier_tbl, caption = "Table 8: Outlier Summary - IQR and Z-Score Methods"))

# INTERPRETATION: A small percentage of children are flagged as outliers by
# both methods. These are not data errors - they represent genuinely
# severely malnourished children, especially in Northern Nigeria, and
# should be kept in the analysis.


## 5.2 Who are the flagged children? -----------------------------------------------

Q1_h  <- quantile(df$haz, 0.25, na.rm = TRUE)
Q3_h  <- quantile(df$haz, 0.75, na.rm = TRUE)
IQR_h <- Q3_h - Q1_h

flagged_haz <- df %>%
  filter(haz < Q1_h - 1.5 * IQR_h | haz > Q3_h + 1.5 * IQR_h) %>%
  select(HAZ = haz, Region = region, Residence = residence, Wealth = wealth)

cat("IQR-flagged HAZ records:", nrow(flagged_haz), "\n\n")
cat("Regional breakdown of flagged records:\n")
print(sort(table(flagged_haz$Region), decreasing = TRUE))

cat("\n10 most extreme HAZ cases (lowest HAZ first):\n")
flagged_haz %>%
  arrange(HAZ) %>%
  head(10) %>%
  kable(caption = "Table 9: 10 Most Extreme HAZ Records") %>%
  print()

# INTERPRETATION: Flagged HAZ records are concentrated in Northern regions,
# confirming that extreme stunting is geographically clustered rather than
# randomly distributed. These children represent the most vulnerable group
# and should remain in the dataset.


## 5.3 Outlier box plot (Figure 5) --------------------------------------------------

# Orange dots are the IQR-flagged outliers; the diamond shows the mean.

make_outlier_box <- function(var_name, label) {
  s   <- df[[var_name]][!is.na(df[[var_name]])]
  Q1  <- quantile(s, 0.25); Q3 <- quantile(s, 0.75)
  n_out <- sum(s < Q1-1.5*(Q3-Q1) | s > Q3+1.5*(Q3-Q1))

  ggplot(data.frame(val = s), aes(x = "", y = val)) +
    geom_boxplot(fill = "#22784F", alpha = 0.60,
                 outlier.colour = "orange", outlier.size = 1.0,
                 outlier.alpha  = 0.50) +
    stat_summary(fun = mean, geom = "point", shape = 18,
                 size = 3, color = "#7B1C2E") +
    geom_hline(yintercept = -2, color = "#C5A028",
               linetype = "dashed", linewidth = 0.8) +
    labs(title    = label,
         subtitle = paste0("IQR flagged: ", n_out),
         x = NULL, y = "Z-Score") +
    theme_minimal(base_size = 10) +
    theme(plot.title    = element_text(face = "bold"),
          plot.subtitle = element_text(color = "orange", face = "italic"))
}

po1 <- make_outlier_box("haz", "HAZ (Stunting)")

print(
  (po1) +
    plot_annotation(
      title    = "Figure 5: HAZ Distribution with IQR Outliers",
      subtitle = "Nigeria NDHS 2024 | Orange = IQR flagged | Diamond = mean"
    )
)

# INTERPRETATION: HAZ has flagged outliers (orange dots) below the lower
# whisker, meaning it has a heavy left tail of severely stunted children.
# The diamond (mean) sits below the median line, confirming leftward
# skewness caused by these extreme cases.


###############################################################################
# YOUR NOTES - STEP 5 (fill in during/after class)
###############################################################################
#
# Complete the outlier decision table for your report:

#
# | Variable | IQR flagged | Main region | Decision   | Justification |
# |----------|-------------|-------------|------------|---------------|
# | HAZ      | (fill)      | (fill)      | Keep/Remove| (fill)        |
#
###############################################################################


###############################################################################
# STEP 6 - RESEARCH QUESTIONS & CONCLUSION
###############################################################################

## 6.1 Tips for good research questions ------------------------------------------
#
# A research question from EDA must be:
#   - SPECIFIC  : names an outcome variable and a population subgroup
#   - GROUNDED  : arises from a pattern you observed in Steps 1-5
#   - TESTABLE  : could be answered with regression or ML in a future sprint
#
# Examples:
#   WEAK:   "What affects child malnutrition?"
#   STRONG: "What is the association between household wealth quintile and
#            HAZ among children aged 0-23 months in Northern Nigeria?"
#
#   WEAK:   "Is education related to health?"
#   STRONG: "Does maternal education level moderate the urban-rural gap in
#            stunting prevalence after adjusting for household wealth?"


## 6.2 Your research questions (fill in) ---------------------------------------
#
# Research Question 1:
#   (Write your first research question here, ground it in a pattern you saw)
#
# Research Question 2:
#   (Write your second question, consider a different outcome or subgroup)
#
# Research Question 3 (optional):
#   (A third question, consider a moderating variable or regional comparison)


## 6.3 Conclusion (fill in) -------------------------------------------------------
#
# Conclusion:
#   (Write 2-4 sentences summarising your most important findings and
#    recommending next analytical steps. Reference specific numbers from
#    your tables.)


###############################################################################
# ADA Global Academy . MicroMasters Sprint 01 . Nigeria NDHS 2024 . NGKR8BFL
###############################################################################

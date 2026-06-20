###############################################################################
# ADA Global Academy MicroMasters
# Week 1 - Exploratory Data Analysis
# Child Undernutrition in Nigeria: WAZ and WHZ EDA using NDHS 2024
# Version: 0.1
# Last Updated: 2026-06-20
# Author: Basil Oforbuike Emeokoro
#
# This script is self-contained in base R. It creates cleaned variables, tables,
# eight figures, a PDF report, and reproducibility metadata.
###############################################################################

options(stringsAsFactors = FALSE)

show_plots_env <- tolower(trimws(Sys.getenv("SHOW_PLOTS", unset = "")))
rstudio_session <- identical(Sys.getenv("RSTUDIO"), "1")
SHOW_PLOTS <- show_plots_env %in% c("true", "1", "yes") ||
  ((show_plots_env == "" || show_plots_env == "auto") && interactive())
SHOW_PLOTS <- SHOW_PLOTS && (interactive() || rstudio_session)
cat("SHOW_PLOTS:", SHOW_PLOTS, "\n")
cat("Interactive session:", interactive(), "\n")
set.seed(20260620)

`%||%` <- function(x, y) if (is.null(x)) y else x

normalize_dir <- function(path) normalizePath(path, winslash = "/", mustWork = FALSE)

get_script_path <- function() {
  script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(script_arg) > 0) return(normalize_dir(sub("^--file=", "", script_arg[1])))

  frame_files <- vapply(sys.frames(), function(frame) frame$ofile %||% NA_character_, character(1))
  frame_files <- frame_files[!is.na(frame_files)]
  if (length(frame_files) > 0) return(normalize_dir(frame_files[length(frame_files)]))

  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    context <- tryCatch(rstudioapi::getSourceEditorContext(), error = function(e) NULL)
    if (!is.null(context$path) && nzchar(context$path)) return(normalize_dir(context$path))
  }

  NULL
}

find_upward <- function(start_dir, predicate, max_depth = 8) {
  current <- normalize_dir(start_dir)
  for (i in seq_len(max_depth)) {
    if (predicate(current)) return(current)
    parent <- normalize_dir(file.path(current, ".."))
    if (identical(parent, current)) break
    current <- parent
  }
  NA_character_
}

script_path <- get_script_path()
start_candidates <- unique(c(
  if (!is.null(script_path)) dirname(script_path),
  getwd()
))

repo_dir <- NA_character_
for (candidate in start_candidates) {
  found <- find_upward(candidate, function(path) {
    dir.exists(file.path(path, ".git")) ||
      (dir.exists(file.path(path, "week01-eda")) && file.exists(file.path(path, "README.md")))
  })
  if (!is.na(found)) {
    repo_dir <- found
    break
  }
}
if (is.na(repo_dir)) {
  stop("Could not locate repository root. Run from the repository, week01-eda/assignment, or source the script file.")
}

assignment_dir <- normalize_dir(file.path(repo_dir, "week01-eda", "assignment"))
if (!dir.exists(assignment_dir)) {
  if (!is.null(script_path) && basename(dirname(script_path)) == "assignment") {
    assignment_dir <- normalize_dir(dirname(script_path))
  } else if (basename(getwd()) == "assignment") {
    assignment_dir <- normalize_dir(getwd())
  } else {
    stop("Could not locate week01-eda/assignment directory.")
  }
}

root_dir <- normalize_dir(file.path(assignment_dir, ".."))
legacy_tasks_dir <- file.path(repo_dir, "Tasks")
week_tasks_dir <- file.path(root_dir, "Tasks")
datasets_dir <- file.path(root_dir, "resources", "datasets")
ci_mode <- identical(tolower(Sys.getenv("CI")), "true") || identical(tolower(Sys.getenv("GITHUB_ACTIONS")), "true")

figures_dir <- file.path(assignment_dir, "figures")
tables_dir <- file.path(assignment_dir, "tables")
outputs_dir <- file.path(assignment_dir, "outputs")
report_dir <- file.path(assignment_dir, "report")
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(outputs_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(report_dir, showWarnings = FALSE, recursive = TRUE)

dataset_filenames <- c("NGKR8BFL.csv", "NGKR8BFL (1).csv")
dataset_locations <- list(
  "week01-eda/resources/datasets" = datasets_dir,
  "week01-eda/assignment" = assignment_dir,
  "repository root data" = file.path(repo_dir, "data"),
  "repository root datasets" = file.path(repo_dir, "datasets"),
  "legacy local Tasks" = legacy_tasks_dir,
  "legacy week01 Tasks" = week_tasks_dir,
  "current working directory" = getwd()
)

dataset_candidates <- unlist(lapply(dataset_locations, function(folder) {
  file.path(folder, dataset_filenames)
}), use.names = FALSE)
csv_file <- dataset_candidates[file.exists(dataset_candidates)][1]

if (is.na(csv_file) && (interactive() || rstudio_session)) {
  message("DHS CSV dataset not found in standard locations. Choose NGKR8BFL.csv or NGKR8BFL (1).csv.")
  selected_file <- tryCatch(file.choose(), error = function(e) NA_character_)
  if (!is.na(selected_file) && basename(selected_file) %in% dataset_filenames) {
    csv_file <- normalize_dir(selected_file)
  } else if (!is.na(selected_file)) {
    stop("Selected file is not a recognized DHS child recode filename. Expected NGKR8BFL.csv or NGKR8BFL (1).csv.")
  }
}

if (is.na(csv_file)) {
  stop(
    "Could not find the DHS CSV dataset.\n",
    "Expected one of: NGKR8BFL.csv or NGKR8BFL (1).csv\n",
    "Place the approved DHS child recode CSV in one of these supported locations:\n",
    "  1. week01-eda/resources/datasets/\n",
    "  2. week01-eda/assignment/\n",
    "  3. repository root data/ or datasets/\n",
    "  4. legacy local Tasks/\n",
    "  5. current working directory\n",
    "Interactive RStudio sessions may also choose the file manually when prompted.\n",
    "For GitHub Actions, the workflow creates a synthetic fixture in week01-eda/resources/datasets before running this script."
  )
}
csv_file <- normalize_dir(csv_file)
if (ci_mode && grepl("resources/datasets/NGKR8BFL", csv_file, fixed = TRUE)) {
  message("CI mode detected: using synthetic fixture at ", csv_file)
}
cat("Assignment directory:", assignment_dir, "\n")
cat("Repository root:", repo_dir, "\n")
cat("Figures directory:", figures_dir, "\n")
cat("Tables directory:", tables_dir, "\n")
cat("Outputs directory:", outputs_dir, "\n")
cat("Report directory:", report_dir, "\n")
cat("Dataset file:", csv_file, "\n")

needed_vars <- c("hw70", "hw71", "hw72", "hw1", "b4", "b5", "m4", "v024", "v025",
                 "v106", "v701", "v130", "v190", "v136", "v137", "v005")
header <- names(read.csv(csv_file, nrows = 1, check.names = FALSE))
missing_cols <- setdiff(needed_vars, header)
if (length(missing_cols) > 0) stop("Missing columns in CSV: ", paste(missing_cols, collapse = ", "))
col_classes <- ifelse(header %in% needed_vars, "numeric", "NULL")

df_raw <- read.csv(csv_file, colClasses = col_classes, check.names = FALSE)

clean_z <- function(x) {
  x <- as.numeric(x)
  ifelse(is.na(x) | x >= 9996, NA_real_, x / 100)
}

recode_numeric <- function(x, labels, default = NA_character_) {
  out <- rep(default, length(x))
  for (code in names(labels)) out[!is.na(x) & x == as.numeric(code)] <- labels[[code]]
  out
}

pct <- function(x, digits = 1) round(100 * x, digits)

weighted_pct <- function(condition, weight = NULL) {
  ok <- !is.na(condition)
  if (!any(ok)) return(NA_real_)
  if (is.null(weight)) return(mean(condition[ok]) * 100)
  w <- weight[ok]
  sum(w * condition[ok], na.rm = TRUE) / sum(w, na.rm = TRUE) * 100
}

skewness_base <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 3) return(NA_real_)
  m <- mean(x)
  s <- stats::sd(x)
  if (is.na(s) || s == 0) return(NA_real_)
  mean((x - m)^3) / s^3
}

mean_se <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  if (n == 0) return(c(mean = NA_real_, se = NA_real_))
  c(mean = mean(x), se = stats::sd(x) / sqrt(n))
}

format_num <- function(x, digits = 2) {
  ifelse(is.na(x), "NA", formatC(x, format = "f", digits = digits, big.mark = ","))
}

wrap_lines <- function(text, width = 92) unlist(strwrap(text, width = width))

df <- within(df_raw, {
  haz <- clean_z(hw70)
  waz <- clean_z(hw71)
  whz <- clean_z(hw72)
  age_months <- hw1
  sex <- factor(recode_numeric(b4, c(`1` = "Male", `2` = "Female")))
  child_alive <- factor(recode_numeric(b5, c(`0` = "No", `1` = "Yes")))
  breastfeeding <- factor(recode_numeric(m4, c(`93` = "Never", `94` = "Still breastfeeding", `95` = "Stopped")),
                          levels = c("Never", "Still breastfeeding", "Stopped"))
  region <- factor(recode_numeric(v024, c(`1` = "North west", `2` = "North east", `3` = "North central",
                                          `4` = "South east", `5` = "South south", `6` = "South west")),
                   levels = c("North west", "North east", "North central", "South east", "South south", "South west"))
  residence <- factor(recode_numeric(v025, c(`1` = "Urban", `2` = "Rural")),
                      levels = c("Urban", "Rural"))
  mother_educ <- factor(recode_numeric(v106, c(`0` = "None", `1` = "Primary", `2` = "Secondary", `3` = "Higher")),
                        levels = c("None", "Primary", "Secondary", "Higher"), ordered = TRUE)
  father_educ <- factor(recode_numeric(ifelse(v701 == 8, NA, v701),
                                       c(`0` = "None", `1` = "Primary", `2` = "Secondary", `3` = "Higher")),
                        levels = c("None", "Primary", "Secondary", "Higher"), ordered = TRUE)
  religion_raw <- recode_numeric(v130, c(`1` = "Catholic", `2` = "Other Christian", `3` = "Islam",
                                         `4` = "Traditionalist", `96` = "Other"))
  religion <- factor(ifelse(religion_raw %in% c("Catholic", "Other Christian"), "Christianity",
                            ifelse(religion_raw == "Islam", "Islam",
                                   ifelse(is.na(religion_raw), NA, "Other"))),
                     levels = c("Christianity", "Islam", "Other"))
  wealth <- factor(recode_numeric(v190, c(`1` = "Poorest", `2` = "Poorer", `3` = "Middle",
                                          `4` = "Richer", `5` = "Richest")),
                   levels = c("Poorest", "Poorer", "Middle", "Richer", "Richest"), ordered = TRUE)
  household_size <- v136
  under5_children <- v137
  sample_weight <- v005 / 1000000
})

total_rows <- nrow(df)
valid_waz <- sum(!is.na(df$waz))
valid_whz <- sum(!is.na(df$whz))
missing_waz_pct <- pct(mean(is.na(df$waz)))
missing_whz_pct <- pct(mean(is.na(df$whz)))

cat("Total rows:", total_rows, "\n")
cat("Valid WAZ observations:", valid_waz, "\n")
cat("Valid WHZ observations:", valid_whz, "\n")
cat("Missing WAZ (%):", missing_waz_pct, "\n")
cat("Missing WHZ (%):", missing_whz_pct, "\n")

analysis_vars <- c("haz", "waz", "whz", "age_months", "sex", "child_alive", "breastfeeding",
                   "region", "residence", "mother_educ", "father_educ", "religion", "wealth",
                   "household_size", "under5_children", "sample_weight")
missing_table <- data.frame(
  Variable = analysis_vars,
  Missing_N = sapply(df[analysis_vars], function(x) sum(is.na(x))),
  Missing_Percent = sapply(df[analysis_vars], function(x) pct(mean(is.na(x)), 2)),
  stringsAsFactors = FALSE
)
missing_table <- missing_table[order(-missing_table$Missing_Percent, missing_table$Variable), ]

summary_stats <- data.frame(
  Outcome = c("WAZ", "WHZ"),
  Mean = c(mean(df$waz, na.rm = TRUE), mean(df$whz, na.rm = TRUE)),
  Median = c(stats::median(df$waz, na.rm = TRUE), stats::median(df$whz, na.rm = TRUE)),
  SD = c(stats::sd(df$waz, na.rm = TRUE), stats::sd(df$whz, na.rm = TRUE)),
  Min = c(min(df$waz, na.rm = TRUE), min(df$whz, na.rm = TRUE)),
  Max = c(max(df$waz, na.rm = TRUE), max(df$whz, na.rm = TRUE)),
  Skewness = c(skewness_base(df$waz), skewness_base(df$whz))
)
summary_stats[-1] <- lapply(summary_stats[-1], round, 3)

prevalence_table <- data.frame(
  Indicator = c("Underweight (WAZ < -2)", "Severe underweight (WAZ < -3)",
                "Wasting (WHZ < -2)", "Severe wasting (WHZ < -3)"),
  Valid_N = c(sum(!is.na(df$waz)), sum(!is.na(df$waz)), sum(!is.na(df$whz)), sum(!is.na(df$whz))),
  Percent = round(c(weighted_pct(df$waz < -2, df$sample_weight),
                    weighted_pct(df$waz < -3, df$sample_weight),
                    weighted_pct(df$whz < -2, df$sample_weight),
                    weighted_pct(df$whz < -3, df$sample_weight)), 2)
)

comparison_table <- data.frame(
  Indicator = c("Stunting (HAZ < -2)", "Underweight (WAZ < -2)", "Wasting (WHZ < -2)"),
  Outcome = c("HAZ", "WAZ", "WHZ"),
  Valid_N = c(sum(!is.na(df$haz)), sum(!is.na(df$waz)), sum(!is.na(df$whz))),
  Percent = round(c(weighted_pct(df$haz < -2, df$sample_weight),
                    weighted_pct(df$waz < -2, df$sample_weight),
                    weighted_pct(df$whz < -2, df$sample_weight)), 2)
)
comparison_table <- comparison_table[order(-comparison_table$Percent), ]

group_prev <- function(var_name, label) {
  g <- df[[var_name]]
  levels_use <- if (is.factor(g)) levels(g) else sort(unique(g[!is.na(g)]))
  out <- do.call(rbind, lapply(levels_use, function(level) {
    idx <- !is.na(g) & g == level & !is.na(df$waz)
    data.frame(Grouping = label, Category = as.character(level), Valid_N = sum(idx),
               Underweight_Percent = round(weighted_pct(df$waz[idx] < -2, df$sample_weight[idx]), 2))
  }))
  out
}

underweight_by_group <- rbind(
  group_prev("region", "Region"),
  group_prev("residence", "Residence"),
  group_prev("wealth", "Wealth quintile"),
  group_prev("mother_educ", "Mother's education"),
  group_prev("religion", "Religion")
)

cor_data <- data.frame(
  WAZ = df$waz,
  WHZ = df$whz,
  Wealth = as.numeric(df$wealth),
  Mothers_Education = as.numeric(df$mother_educ),
  Household_Size = df$household_size,
  Under5_Children = df$under5_children
)
cor_matrix <- stats::cor(cor_data, method = "spearman", use = "pairwise.complete.obs")
pair_grid <- utils::combn(colnames(cor_matrix), 2)
ranked_pairs <- data.frame(
  Variable_1 = pair_grid[1, ],
  Variable_2 = pair_grid[2, ],
  Spearman_rho = mapply(function(a, b) cor_matrix[a, b], pair_grid[1, ], pair_grid[2, ])
)
ranked_pairs$Abs_rho <- abs(ranked_pairs$Spearman_rho)
ranked_pairs <- ranked_pairs[order(-ranked_pairs$Abs_rho), ]
ranked_pairs$Spearman_rho <- round(ranked_pairs$Spearman_rho, 3)
ranked_pairs$Abs_rho <- round(ranked_pairs$Abs_rho, 3)

strongest_for <- function(outcome) {
  candidates <- setdiff(colnames(cor_matrix), c("WAZ", "WHZ"))
  vals <- cor_matrix[outcome, candidates]
  candidates[which.max(abs(vals))]
}
strongest_waz <- strongest_for("WAZ")
strongest_whz <- strongest_for("WHZ")

flag_outliers <- function(x) {
  qs <- stats::quantile(x, c(0.25, 0.75), na.rm = TRUE, names = FALSE)
  iqr <- qs[2] - qs[1]
  iqr_flag <- !is.na(x) & (x < qs[1] - 1.5 * iqr | x > qs[2] + 1.5 * iqr)
  z <- as.numeric(scale(x))
  z_flag <- !is.na(z) & abs(z) > 3
  list(iqr = iqr_flag, z = z_flag)
}
waz_flags <- flag_outliers(df$waz)
whz_flags <- flag_outliers(df$whz)

outlier_summary <- data.frame(
  Variable = c("WAZ", "WHZ"),
  Valid_N = c(sum(!is.na(df$waz)), sum(!is.na(df$whz))),
  IQR_Flagged = c(sum(waz_flags$iqr), sum(whz_flags$iqr)),
  IQR_Percent = round(c(mean(waz_flags$iqr[!is.na(df$waz)]) * 100,
                        mean(whz_flags$iqr[!is.na(df$whz)]) * 100), 2),
  Z_Flagged = c(sum(waz_flags$z), sum(whz_flags$z)),
  Z_Percent = round(c(mean(waz_flags$z[!is.na(df$waz)]) * 100,
                      mean(whz_flags$z[!is.na(df$whz)]) * 100), 2)
)

main_regions <- function(flag) {
  tab <- sort(table(df$region[flag]), decreasing = TRUE)
  if (length(tab) == 0) return("None")
  paste(names(tab)[seq_len(min(2, length(tab)))], collapse = ", ")
}

decision_table <- data.frame(
  Variable = c("WAZ", "WHZ"),
  IQR_Flagged = outlier_summary$IQR_Flagged,
  Percent_Flagged = outlier_summary$IQR_Percent,
  Main_Regions = c(main_regions(waz_flags$iqr), main_regions(whz_flags$iqr)),
  Decision = c("Keep", "Keep"),
  Reason = c("Anthropometric extremes are plausible child-health findings after DHS invalid codes were removed.",
             "Anthropometric extremes are plausible child-health findings after DHS invalid codes were removed.")
)

write.csv(missing_table, file.path(tables_dir, "table_01_missing_values.csv"), row.names = FALSE)
write.csv(summary_stats, file.path(tables_dir, "table_02_waz_whz_summary.csv"), row.names = FALSE)
write.csv(prevalence_table, file.path(tables_dir, "table_03_national_prevalence.csv"), row.names = FALSE)
write.csv(comparison_table, file.path(tables_dir, "table_04_haz_waz_whz_comparison.csv"), row.names = FALSE)
write.csv(underweight_by_group, file.path(tables_dir, "table_05_underweight_by_group.csv"), row.names = FALSE)
write.csv(round(cor_matrix, 3), file.path(tables_dir, "table_06_spearman_matrix.csv"))
write.csv(ranked_pairs, file.path(tables_dir, "table_07_ranked_correlation_pairs.csv"), row.names = FALSE)
write.csv(outlier_summary, file.path(tables_dir, "table_08_outlier_summary.csv"), row.names = FALSE)
write.csv(decision_table, file.path(tables_dir, "table_09_outlier_decision.csv"), row.names = FALSE)

publication_style <- list(
  text_col = "#1f1f1f",
  axis_col = "#333333",
  cutoff_col = "#d7301f",
  severe_col = "#7f0000",
  outlier_col = "#f16913",
  mean_col = "#54278f",
  grid_neg = "#2166ac",
  grid_pos = "#b2182b",
  caption_cex = 0.82,
  subtitle_cex = 0.9,
  title_cex = 1.15,
  dpi = 300
)

publication_margins <- function(plot_type = "default") {
  switch(plot_type,
         histogram = c(6.5, 5.5, 5, 2),
         horizontal_box = c(6.5, 9, 5, 2),
         violin = c(7, 5.5, 5, 2),
         bar = c(6.5, 5.5, 5, 2),
         heatmap = c(12, 9, 5.5, 3),
         outlier = c(7, 5.5, 5, 2),
         c(6.5, 5.5, 5, 2))
}

theme_publication <- function(plot_type = "default") {
  par(
    bg = "white",
    fg = publication_style$axis_col,
    col.axis = publication_style$axis_col,
    col.lab = publication_style$text_col,
    col.main = publication_style$text_col,
    family = "sans",
    mar = publication_margins(plot_type),
    mgp = c(3.1, 0.8, 0),
    tcl = -0.3,
    cex.axis = 0.95,
    cex.lab = 1.02
  )
}

can_preview_plots <- function() interactive() || rstudio_session

preview_figure <- function(plot_fun, force = FALSE) {
  if (!force && !SHOW_PLOTS) return(invisible(FALSE))
  if (!can_preview_plots()) {
    message("Plot preview skipped: no interactive graphics session is available.")
    return(invisible(FALSE))
  }
  plot_fun()
  invisible(TRUE)
}

save_figure <- function(filename, plot_fun, width = 10, height = 7, dpi = publication_style$dpi) {
  grDevices::png(filename, width = width, height = height, units = "in", res = dpi)
  tryCatch(plot_fun(), error = function(e) {
    if (grDevices::dev.cur() > 1) grDevices::dev.off()
    stop(e)
  })
  if (grDevices::dev.cur() > 1) grDevices::dev.off()
  preview_figure(plot_fun)
  invisible(filename)
}

scrub_pdf_metadata <- function(filename) {
  bytes <- readBin(filename, what = "raw", n = file.info(filename)$size)

  find_raw <- function(x, pattern) {
    if (length(x) < length(pattern)) return(integer(0))
    candidates <- which(x[seq_len(length(x) - length(pattern) + 1)] == pattern[1])
    candidates[vapply(candidates, function(i) {
      identical(x[i:(i + length(pattern) - 1)], pattern)
    }, logical(1))]
  }

  replace_pdf_date <- function(x, field, replacement = "D:20260620000000") {
    prefix <- charToRaw(paste0("/", field, " ("))
    pos <- find_raw(x, prefix)
    if (length(pos) == 0) return(x)
    start <- pos[1] + length(prefix)
    end_candidates <- which(x[start:length(x)] == charToRaw(")"))
    if (length(end_candidates) == 0) return(x)
    end <- start + end_candidates[1] - 2
    replacement_raw <- charToRaw(replacement)
    target_length <- end - start + 1
    if (length(replacement_raw) > target_length) replacement_raw <- replacement_raw[seq_len(target_length)]
    if (length(replacement_raw) < target_length) {
      replacement_raw <- c(replacement_raw, rep(charToRaw("0"), target_length - length(replacement_raw)))
    }
    x[start:end] <- replacement_raw
    x
  }

  bytes <- replace_pdf_date(bytes, "CreationDate")
  bytes <- replace_pdf_date(bytes, "ModDate")
  writeBin(bytes, filename)
  invisible(filename)
}

plot_header_caption <- function(main, subtitle, caption, caption_line = 4.2) {
  title(main = main, line = 2.2, cex.main = publication_style$title_cex)
  mtext(subtitle, side = 3, line = 0.65, cex = publication_style$subtitle_cex)
  mtext(caption, side = 1, line = caption_line, cex = publication_style$caption_cex)
}

plot_waz_hist <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("histogram")
  on.exit(par(op), add = TRUE)
  hist(df$waz, breaks = 40, col = "#9ecae1", border = "white",
       xlab = "Weight-for-age z-score (WAZ)", ylab = "Number of children",
       main = "")
  abline(v = c(-2, -3), col = c(publication_style$cutoff_col, publication_style$severe_col), lwd = 2, lty = c(2, 3))
  legend("topright", legend = c("-2 underweight cutoff", "-3 severe cutoff"), lty = c(2, 3),
         col = c(publication_style$cutoff_col, publication_style$severe_col), bty = "n")
  plot_header_caption(
    "Figure 1. Distribution of WAZ",
    paste0("Nigeria NDHS 2024; underweight prevalence = ", format_num(prevalence_table$Percent[1], 1), "%"),
    "Caption: WAZ distribution with clinical underweight and severe underweight cutoffs."
  )
}

plot_whz_hist <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("histogram")
  on.exit(par(op), add = TRUE)
  hist(df$whz, breaks = 40, col = "#a1d99b", border = "white",
       xlab = "Weight-for-height z-score (WHZ)", ylab = "Number of children",
       main = "")
  abline(v = c(-2, -3), col = c(publication_style$cutoff_col, publication_style$severe_col), lwd = 2, lty = c(2, 3))
  legend("topright", legend = c("-2 wasting cutoff", "-3 severe cutoff"), lty = c(2, 3),
         col = c(publication_style$cutoff_col, publication_style$severe_col), bty = "n")
  plot_header_caption(
    "Figure 2. Distribution of WHZ",
    paste0("Nigeria NDHS 2024; wasting prevalence = ", format_num(prevalence_table$Percent[3], 1), "%"),
    "Caption: WHZ distribution with wasting and severe wasting cutoffs."
  )
}

plot_waz_region_box <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("horizontal_box")
  on.exit(par(op), add = TRUE)
  med <- tapply(df$waz, df$region, median, na.rm = TRUE)
  ordered_region <- names(sort(med))
  boxplot(waz ~ factor(region, levels = ordered_region), data = df, las = 2,
          horizontal = TRUE,
          col = "#fdd0a2", border = "#636363",
          xlab = "Weight-for-age z-score (WAZ)",
          ylab = "",
          main = "")
  abline(v = -2, col = publication_style$cutoff_col, lwd = 2, lty = 2)
  plot_header_caption(
    "Figure 3. WAZ by region",
    "Nigeria NDHS 2024; red dashed line marks underweight cutoff",
    "Caption: Regions are sorted by median WAZ from lowest to highest."
  )
}

plot_whz_wealth_violin <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("violin")
  on.exit(par(op), add = TRUE)
  vals <- split(df$whz, df$wealth)
  plot(NA, xlim = c(0.5, length(vals) + 0.5), ylim = range(df$whz, na.rm = TRUE),
       xaxt = "n", xlab = "Wealth quintile", ylab = "Weight-for-height z-score (WHZ)",
       main = "")
  axis(1, seq_along(vals), names(vals), las = 1)
  for (i in seq_along(vals)) draw_violin(vals[[i]], i, col = "#c7e9c0")
  abline(h = -2, col = publication_style$cutoff_col, lwd = 2, lty = 2)
  plot_header_caption(
    "Figure 4. WHZ by wealth quintile",
    "Nigeria NDHS 2024; red dashed line marks wasting cutoff",
    "Caption: WHZ density by household wealth quintile with the wasting cutoff."
  )
}

plot_waz_breastfeeding_violin <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("violin")
  on.exit(par(op), add = TRUE)
  df$breastfeeding_short <- factor(
    as.character(df$breastfeeding),
    levels = c("Never", "Still breastfeeding", "Stopped"),
    labels = c("Never", "Still BF", "Stopped")
  )
  vals <- split(df$waz, df$breastfeeding_short)
  plot(NA, xlim = c(0.5, length(vals) + 0.5), ylim = range(df$waz, na.rm = TRUE),
       xaxt = "n", xlab = "Breastfeeding status", ylab = "Weight-for-age z-score (WAZ)",
       main = "")
  axis(1, seq_along(vals), names(vals), las = 1)
  for (i in seq_along(vals)) draw_violin(vals[[i]], i, col = "#fdae6b")
  abline(h = -2, col = publication_style$cutoff_col, lwd = 2, lty = 2)
  plot_header_caption(
    "Figure 5. WAZ by breastfeeding status",
    "Nigeria NDHS 2024; red dashed line marks underweight cutoff",
    "Caption: WAZ density across assignment-defined breastfeeding groups.",
    caption_line = 4
  )
}

draw_violin <- function(x, xpos, width = 0.35, col = "#cccccc") {
  x <- x[!is.na(x)]
  if (length(x) < 2) return(invisible(NULL))
  d <- stats::density(x, na.rm = TRUE)
  scaled <- d$y / max(d$y) * width
  polygon(c(xpos - scaled, rev(xpos + scaled)), c(d$x, rev(d$x)),
          col = col, border = "#636363")
  points(xpos, median(x), pch = 19, cex = 0.8)
}

plot_mean_waz_religion <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("bar")
  on.exit(par(op), add = TRUE)
  stats_by_rel <- do.call(rbind, lapply(levels(df$religion), function(g) {
    ms <- mean_se(df$waz[df$religion == g])
    data.frame(religion = g, mean = ms["mean"], se = ms["se"])
  }))
  bp <- barplot(stats_by_rel$mean, names.arg = stats_by_rel$religion, col = "#bcbddc",
                ylim = range(c(stats_by_rel$mean - stats_by_rel$se, stats_by_rel$mean + stats_by_rel$se, 0), na.rm = TRUE),
                xlab = "Religion", ylab = "Mean WAZ",
                main = "")
  arrows(bp, stats_by_rel$mean - stats_by_rel$se, bp, stats_by_rel$mean + stats_by_rel$se,
         angle = 90, code = 3, length = 0.05, col = "#252525")
  plot_header_caption(
    "Figure 6. Mean WAZ by religion",
    "Nigeria NDHS 2024; error bars show mean +/- standard error",
    "Caption: Mean WAZ by collapsed religion group with standard-error bars."
  )
}

plot_corr_heatmap <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("heatmap")
  on.exit(par(op), add = TRUE)
  m <- cor_matrix[nrow(cor_matrix):1, ]
  axis_labels <- c("WAZ", "WHZ", "Wealth", "Mother educ.", "Household size", "Under-5 kids")
  names(axis_labels) <- colnames(cor_matrix)
  image(seq_len(ncol(m)), seq_len(nrow(m)), t(m), axes = FALSE,
        col = grDevices::colorRampPalette(c(publication_style$grid_neg, "white", publication_style$grid_pos))(101),
        zlim = c(-1, 1), xlab = "", ylab = "", main = "")
  axis(1, seq_len(ncol(m)), axis_labels[colnames(m)], las = 2, cex.axis = 0.78)
  axis(2, seq_len(nrow(m)), rev(axis_labels[rownames(cor_matrix)]), las = 1, cex.axis = 0.78)
  for (i in seq_len(ncol(m))) {
    for (j in seq_len(nrow(m))) text(i, j, format_num(m[j, i], 2), cex = 0.78)
  }
  plot_header_caption(
    "Figure 7. Spearman correlation heatmap",
    "Nigeria NDHS 2024; blue is negative and red is positive",
    "Caption: Spearman correlation matrix for anthropometry and household predictors.",
    caption_line = 8.2
  )
}

plot_outlier_box <- function() {
  op <- par(no.readonly = TRUE)
  theme_publication("outlier")
  on.exit(par(op), add = TRUE)
  d <- data.frame(value = c(df$waz, df$whz), variable = rep(c("WAZ", "WHZ"), each = nrow(df)),
                  flagged = c(waz_flags$iqr | waz_flags$z, whz_flags$iqr | whz_flags$z))
  y_range <- range(d$value, na.rm = TRUE)
  y_pad <- diff(y_range) * 0.08
  boxplot(value ~ variable, data = d, col = c("#9ecae1", "#a1d99b"),
          xlab = "Outcome", ylab = "Z-score", main = "",
          outline = FALSE, ylim = c(y_range[1] - y_pad, y_range[2] + y_pad))
  for (i in 1:2) {
    sub <- d[d$variable == c("WAZ", "WHZ")[i] & d$flagged & !is.na(d$value), ]
    points(jitter(rep(i, nrow(sub)), amount = 0.07), sub$value, pch = 19, col = publication_style$outlier_col, cex = 0.6)
    points(i, mean(d$value[d$variable == c("WAZ", "WHZ")[i]], na.rm = TRUE),
           pch = 18, col = publication_style$mean_col, cex = 1.6)
  }
  legend("topright", legend = c("IQR or |z| > 3 flagged", "Mean"), pch = c(19, 18),
         col = c(publication_style$outlier_col, publication_style$mean_col), bty = "n", cex = 0.85)
  plot_header_caption(
    "Figure 8. WAZ and WHZ outlier flags",
    "Nigeria NDHS 2024; orange points are flagged by at least one method",
    "Caption: Side-by-side WAZ and WHZ box plots with orange flagged points and purple means."
  )
}

figure_files <- list(
  list(name = "figure_01_waz_histogram.png", fun = plot_waz_hist, width = 10, height = 7),
  list(name = "figure_02_whz_histogram.png", fun = plot_whz_hist, width = 10, height = 7),
  list(name = "figure_03_waz_by_region_boxplot.png", fun = plot_waz_region_box, width = 11, height = 7.5),
  list(name = "figure_04_whz_by_wealth_violin.png", fun = plot_whz_wealth_violin, width = 10.5, height = 7.5),
  list(name = "figure_05_waz_by_breastfeeding_violin.png", fun = plot_waz_breastfeeding_violin, width = 10.5, height = 7.5),
  list(name = "figure_06_mean_waz_by_religion.png", fun = plot_mean_waz_religion, width = 10, height = 7),
  list(name = "figure_07_spearman_heatmap.png", fun = plot_corr_heatmap, width = 11, height = 8.5),
  list(name = "figure_08_outlier_boxplot.png", fun = plot_outlier_box, width = 11, height = 7.5)
)

preview_all_figures <- function() {
  invisible(lapply(figure_files, function(fig) preview_figure(fig$fun, force = TRUE)))
}

for (fig in figure_files) save_figure(file.path(figures_dir, fig$name), fig$fun, fig$width, fig$height)

table_text <- function(tbl, max_rows = 20) {
  if (nrow(tbl) > max_rows) tbl <- tbl[seq_len(max_rows), , drop = FALSE]
  capture.output(print(tbl, row.names = FALSE, right = FALSE))
}

report_total_pages <- 17
report_page_counter <- 0

add_page_number <- function() {
  report_page_counter <<- report_page_counter + 1
  mtext(
    sprintf("Page %d of %d", report_page_counter, report_total_pages),
    side = 3, adj = 1, line = 3.7, cex = 0.65, col = "#666666"
  )
}

add_text_page <- function(title, body_lines, cex = 0.72) {
  plot.new()
  text(0.02, 0.97, title, adj = c(0, 1), cex = 1.15, font = 2)
  add_page_number()
  y <- 0.91
  for (line in body_lines) {
    if (line == "") {
      y <- y - 0.025
    } else {
      text(0.02, y, line, adj = c(0, 1), cex = cex, family = "mono")
      y <- y - 0.028
    }
    if (y < 0.04) {
      plot.new()
      add_page_number()
      y <- 0.97
    }
  }
}

wrap_by_plot_width <- function(text, max_width = 0.86, cex = 0.72, family = "sans") {
  words <- unlist(strsplit(text, "\\s+"))
  words <- words[nzchar(words)]
  if (length(words) == 0) return(character(0))

  lines <- character(0)
  current <- words[1]
  if (length(words) > 1) {
    for (word in words[-1]) {
      candidate <- paste(current, word)
      if (strwidth(candidate, cex = cex, family = family) <= max_width) {
        current <- candidate
      } else {
        lines <- c(lines, current)
        current <- word
      }
    }
  }
  c(lines, current)
}

draw_justified_line <- function(line, x, y, max_width, cex = 0.72, family = "sans") {
  words <- unlist(strsplit(line, "\\s+"))
  words <- words[nzchar(words)]
  if (length(words) <= 1) {
    text(x, y, line, adj = c(0, 1), cex = cex, family = family)
    return(invisible(NULL))
  }

  line_width <- strwidth(line, cex = cex, family = family)
  space_width <- strwidth(" ", cex = cex, family = family)
  extra_spaces <- max(floor((max_width - line_width) / space_width), 0)
  gap_count <- length(words) - 1
  spaces <- rep(1L, gap_count)

  if (extra_spaces > 0) {
    for (i in seq_len(extra_spaces)) {
      spaces[((i - 1) %% gap_count) + 1] <- spaces[((i - 1) %% gap_count) + 1] + 1L
    }
  }

  justified <- words[1]
  for (i in seq_len(gap_count)) {
    justified <- paste0(justified, strrep(" ", spaces[i]), words[i + 1])
  }
  text(x, y, justified, adj = c(0, 1), cex = cex, family = family)
  invisible(NULL)
}

draw_paragraph <- function(text, x = 0.08, y = 0.80, max_width = 0.84, cex = 0.72,
                           line_height = 0.034, family = "sans", justify = TRUE) {
  lines <- wrap_by_plot_width(text, max_width = max_width, cex = cex, family = family)
  if (length(lines) == 0) return(y)

  for (i in seq_along(lines)) {
    is_last <- i == length(lines)
    if (justify && !is_last) {
      draw_justified_line(lines[i], x, y, max_width, cex = cex, family = family)
    } else {
      text(x, y, lines[i], adj = c(0, 1), cex = cex, family = family)
    }
    y <- y - line_height
  }
  y
}

add_task_e_page <- function(rq_table, conclusion) {
  plot.new()
  text(0.02, 0.97, "Task E Research Questions and Conclusion", adj = c(0, 1), cex = 1.15, font = 2)
  add_page_number()

  y <- 0.90
  text(0.02, y, "Table 9. Future research questions", adj = c(0, 1), cex = 0.82, font = 2)
  text(0.55, y, "Conclusion", adj = c(0, 1), cex = 0.86, font = 2)
  y <- y - 0.035

  for (i in seq_len(nrow(rq_table))) {
    text(0.02, y, rq_table$RQ[i], adj = c(0, 1), cex = 0.70, font = 2, family = "sans")
    y <- y - 0.025
    y <- draw_paragraph(rq_table$Research_question[i], x = 0.04, y = y, max_width = 0.46,
                        cex = 0.59, line_height = 0.026, family = "sans", justify = FALSE)
    y <- y - 0.004
    text(0.04, y, paste("Evidence:", rq_table$Evidence[i]), adj = c(0, 1), cex = 0.58,
         font = 2, family = "sans")
    y <- y - 0.024
    y <- draw_paragraph(paste("Suggested method:", rq_table$Suggested_method[i]), x = 0.04, y = y,
                        max_width = 0.46, cex = 0.58, line_height = 0.024,
                        family = "sans", justify = FALSE)
    y <- y - 0.018
    segments(0.02, y + 0.006, 0.50, y + 0.006, col = "#DDDDDD")
    y <- y - 0.014
  }

  y <- 0.855
  y <- draw_paragraph(conclusion, x = 0.55, y = y, max_width = 0.41, cex = 0.60,
                      line_height = 0.027, family = "mono", justify = TRUE)
  invisible(y)
}

interpret_missing <- paste0("Breastfeeding has the largest missing share because the assignment keeps only codes 93, 94, and 95. ",
                            "WAZ and WHZ have ", missing_waz_pct, "% and ", missing_whz_pct,
                            "% missing respectively after DHS invalid anthropometry codes are removed.")
interpret_summary <- paste0("The average WAZ is ", format_num(summary_stats$Mean[1], 2),
                            " and the average WHZ is ", format_num(summary_stats$Mean[2], 2),
                            ", so weight-for-age is lower nationally than weight-for-height. ",
                            "Both distributions include children below the clinical -2 threshold, making prevalence estimates necessary.")
interpret_prev <- paste0("Nationally, ", format_num(prevalence_table$Percent[1], 1),
                         "% of children are underweight and ", format_num(prevalence_table$Percent[3], 1),
                         "% are wasted. Severe underweight is ", format_num(prevalence_table$Percent[2], 1),
                         "%, while severe wasting is ", format_num(prevalence_table$Percent[4], 1),
                         "%, showing the most extreme WHZ deficits are less common.")
most_common <- comparison_table$Indicator[1]
interpret_comp <- paste0(most_common, " is the most common of the three anthropometric deficits in this dataset. ",
                         "This comparison places the new WAZ and WHZ assignment results beside the HAZ stunting measure from class.")
top_group <- underweight_by_group[order(-underweight_by_group$Underweight_Percent), ][1, ]
interpret_group <- paste0("The highest underweight prevalence appears in ", top_group$Category, " within ",
                          top_group$Grouping, " at ", format_num(top_group$Underweight_Percent, 1),
                          "%. This subgroup is the clearest priority for follow-up modelling and targeted public-health interpretation.")
interpret_cor <- paste0("The strongest non-anthropometric link with WAZ is ", strongest_waz,
                        "; for WHZ it is ", strongest_whz, ". The ranked-pairs table shows that these associations are modest, ",
                        "so correlation should be treated as screening evidence rather than causal evidence.")
interpret_outliers <- paste0("IQR flagged ", outlier_summary$IQR_Flagged[1], " WAZ observations and ",
                             outlier_summary$IQR_Flagged[2], " WHZ observations. These records are kept because the DHS invalid-code rule ",
                             "has already removed non-measurements, and remaining extremes may represent clinically important children.")

assumptions_lines <- c(
  "Unit of analysis: one row represents one child in the Nigeria DHS 2024 Children's Recode file.",
  "Raw DHS anthropometry variables are preserved; cleaned HAZ, WAZ, and WHZ are created separately.",
  "DHS anthropometry codes 9996 and above are treated as missing before dividing valid scores by 100.",
  "Religion was checked against the DHS labels and collapsed to Christianity, Islam, and Other.",
  "The official assignment lists 15 WAZ/WHZ variables; hw70 is read only to reproduce the required HAZ comparison table.",
  "v005 is normalized and used for descriptive prevalence estimates, but no full complex-survey design adjustment is applied.",
  "The draft guidance notes hw73 plausibility flags; hw73 is not applied because it is outside the official assignment variable list."
)

rq_table <- data.frame(
  RQ = c("RQ1", "RQ2", "RQ3"),
  Research_question = c(
    "Among children in the North west and North east, is WAZ lower than in southern zones after adjusting for wealth, mother's education, residence, and household size?",
    "Among children in the poorest wealth quintile, is WHZ lower than in the richer/richest quintiles after controlling for region and mother's education?",
    "Among Muslim children, is WAZ lower than among Christian children after adjusting for region, wealth, mother's education, and rural residence?"
  ),
  Evidence = c("Table 5 and Figure 3", "Figure 4 and Table 5", "Table 5 and Figure 6"),
  Suggested_method = c("Weighted linear regression or logistic model for underweight",
                       "Multivariable linear regression for WHZ and logistic model for wasting",
                       "Multivariable regression or adjusted logistic model for underweight"),
  stringsAsFactors = FALSE
)
write.csv(rq_table, file.path(tables_dir, "table_10_future_research_questions.csv"), row.names = FALSE)

conclusion <- paste0(
  "The NDHS 2024 child-recode analysis shows that undernutrition in Nigeria is broader than one anthropometric measure. ",
  "After removing DHS invalid anthropometry codes, ", format_num(valid_waz, 0), " children had valid WAZ and ",
  format_num(valid_whz, 0), " had valid WHZ. The weighted national prevalence of underweight was ",
  format_num(prevalence_table$Percent[1], 1), "%, compared with ", format_num(prevalence_table$Percent[3], 1),
  "% for wasting. Severe underweight affected ", format_num(prevalence_table$Percent[2], 1),
  "%, while severe wasting affected ", format_num(prevalence_table$Percent[4], 1),
  "%. When compared with the HAZ result from class, stunting was ",
  format_num(comparison_table$Percent[comparison_table$Outcome == "HAZ"], 1),
  "% and remained the largest deficit, consistent with chronic deprivation being more widespread than acute wasting. ",
  "The most at-risk subgroup in the descriptive tables was ", top_group$Category, " (", top_group$Grouping,
  "), where underweight reached ", format_num(top_group$Underweight_Percent, 1),
  "%. The regional and socioeconomic figures also show that risk is not evenly distributed across Nigerian children, so national averages hide important local vulnerability. ",
  "Correlations with wealth, education, household size, and under-five crowding were modest, but they identify plausible predictors for the next sprint. ",
  "The next analytical step should be a weighted multivariable model for underweight and wasting that adjusts for region, wealth, maternal education, household size, and child age."
)
writeLines(strwrap(conclusion, width = 100), file.path(outputs_dir, "conclusion.txt"))
writeLines(capture.output(sessionInfo()), file.path(outputs_dir, "sessionInfo.txt"))

report_pdf <- file.path(assignment_dir, "Sprint01_BasilEmeokoro.pdf")
grDevices::pdf(report_pdf, width = 11, height = 8.5, onefile = TRUE)
add_text_page("Sprint 01 Assignment: Child Undernutrition in Nigeria",
              c("Basil Emeokoro",
                "ADA Global Academy MicroMasters in Data Science, AI & Research Methods",
                "Dataset: Nigeria DHS 2024 Children's Recode - NGKR8BFL",
                "",
                paste("Total rows:", total_rows),
                paste("Valid WAZ observations:", valid_waz),
                paste("Valid WHZ observations:", valid_whz),
                paste("Missing WAZ (%):", missing_waz_pct),
                paste("Missing WHZ (%):", missing_whz_pct),
                "",
                "Breastfeeding recode follows the assignment PDF: 93 = Never, 94 = Still breastfeeding, 95 = Stopped."))
add_text_page("Dataset Understanding, Assumptions, and Limitations",
              c("Research-quality checks from the assignment draft", "", wrap_lines(paste(assumptions_lines, collapse = " "), 92)))
add_text_page("Task B Tables and Interpretations",
              c("Table 1. Missing value table", table_text(missing_table),
                "", wrap_lines(interpret_missing),
                "", "Table 2. Summary statistics for WAZ and WHZ", table_text(summary_stats),
                "", wrap_lines(interpret_summary),
                "", "Table 3. National prevalence", table_text(prevalence_table),
                "", wrap_lines(interpret_prev)))
add_text_page("Task B Continued",
              c("Table 4. HAZ, WAZ, and WHZ comparison", table_text(comparison_table),
                "", wrap_lines(interpret_comp),
                "", "Table 5. Underweight prevalence by subgroup", table_text(underweight_by_group, 40),
                "", wrap_lines(interpret_group)))
plot_waz_hist()
add_page_number()
plot_whz_hist()
add_page_number()
plot_waz_region_box()
add_page_number()
plot_whz_wealth_violin()
add_page_number()
plot_waz_breastfeeding_violin()
add_page_number()
plot_mean_waz_religion()
add_page_number()
plot_corr_heatmap()
add_page_number()
add_text_page("Task D Correlation and Outliers",
              c("Table 6. Ranked Spearman pairs", table_text(ranked_pairs, 20),
                "", wrap_lines(interpret_cor),
                "", "Table 7. Outlier summary", table_text(outlier_summary),
                "", "Table 8. Outlier decision table", table_text(decision_table),
                "", wrap_lines(interpret_outliers)))
plot_outlier_box()
add_page_number()
add_task_e_page(rq_table, conclusion)
grDevices::dev.off()
scrub_pdf_metadata(report_pdf)

cat("Created report:", report_pdf, "\n")
cat("Created figures in:", figures_dir, "\n")
cat("Created tables in:", tables_dir, "\n")
cat("Created session info:", file.path(outputs_dir, "sessionInfo.txt"), "\n")


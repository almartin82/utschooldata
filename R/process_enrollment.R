# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw USBE enrollment data into a
# clean, standardized format.
#
# Utah USBE Data Structure:
# - Files contain multiple sheets: State, By LEA (district), By School
# - Columns include: LEA (district), School, Grade levels (K-12), Demographics
# - Data is reported by individual schools within each LEA (Local Education Agency)
#
# ==============================================================================

#' Process raw USBE enrollment data
#'
#' Transforms raw USBE data into a standardized schema with consistent
#' column names and types.
#'
#' @param raw_data Data frame from get_raw_enr (combined from all sheets)
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr <- function(raw_data, end_year) {

  cols <- names(raw_data)
  n_rows <- nrow(raw_data)

  # Helper to find column by pattern (case-insensitive, partial match)
  find_col <- function(patterns) {
    for (pattern in patterns) {
      matched <- grep(pattern, cols, value = TRUE, ignore.case = TRUE)
      if (length(matched) > 0) return(matched[1])
    }
    NULL
  }

  # Build result dataframe
  result <- data.frame(
    end_year = rep(end_year, n_rows),
    stringsAsFactors = FALSE
  )

  # Determine aggregation type based on 'level' column set in get_raw_enr
  level_col <- find_col(c("^level$"))
  if (!is.null(level_col)) {
    result$type <- raw_data[[level_col]]
    # Map level names to standard types
    result$type <- dplyr::case_when(
      result$type %in% c("State", "state") ~ "State",
      result$type %in% c("District", "LEA", "district", "lea") ~ "District",
      result$type %in% c("Campus", "School", "campus", "school") ~ "Campus",
      TRUE ~ "Campus"
    )
  } else {
    result$type <- rep("Campus", n_rows)
  }

  # LEA (District) name
  lea_name_col <- find_col(c("^lea_name$", "^LEA_Name", "^District"))
  if (!is.null(lea_name_col)) {
    result$district_name <- as.character(raw_data[[lea_name_col]])
  } else {
    result$district_name <- NA_character_
  }

  # School name
  school_name_col <- find_col(c("^school_name$", "^School_Name", "^School$"))
  if (!is.null(school_name_col)) {
    result$campus_name <- as.character(raw_data[[school_name_col]])
  } else {
    result$campus_name <- NA_character_
  }

  # LEA Type (District vs Charter)
  lea_type_col <- find_col(c("^lea_type$", "^LEA_TYPE"))
  if (!is.null(lea_type_col)) {
    lea_types <- as.character(raw_data[[lea_type_col]])
    result$charter_flag <- ifelse(lea_types == "Charter", "Y", "N")
  }

  # Generate synthetic IDs based on names (USBE doesn't include numeric IDs in public files)
  # District ID: hash of district name
  result$district_id <- ifelse(
    !is.na(result$district_name),
    as.character(match(result$district_name, unique(result$district_name))),
    NA_character_
  )

  # Campus ID: combine district ID and school name
  result$campus_id <- ifelse(
    !is.na(result$campus_name),
    paste0(result$district_id, "-", match(
      paste0(result$district_name, "|", result$campus_name),
      unique(paste0(result$district_name, "|", result$campus_name))
    )),
    NA_character_
  )

  # For state and district level, clear campus fields
  result$campus_id[result$type %in% c("State", "District")] <- NA_character_
  result$campus_name[result$type %in% c("State", "District")] <- NA_character_
  result$district_id[result$type == "State"] <- NA_character_
  result$district_name[result$type == "State"] <- NA_character_

  # Total enrollment
  total_col <- find_col(c("^total_k12$", "^Total_K12", "^Total$", "^row_total$"))
  if (!is.null(total_col)) {
    result$row_total <- safe_numeric(raw_data[[total_col]])
  }

  # Demographics - Race/Ethnicity
  white_col <- find_col(c("^white$", "^White$"))
  if (!is.null(white_col)) {
    result$white <- safe_numeric(raw_data[[white_col]])
  }

  black_col <- find_col(c("^black$", "^AfAmBlack", "^African"))
  if (!is.null(black_col)) {
    result$black <- safe_numeric(raw_data[[black_col]])
  }

  hispanic_col <- find_col(c("^hispanic$", "^Hispanic$"))
  if (!is.null(hispanic_col)) {
    result$hispanic <- safe_numeric(raw_data[[hispanic_col]])
  }

  asian_col <- find_col(c("^asian$", "^Asian$"))
  if (!is.null(asian_col)) {
    result$asian <- safe_numeric(raw_data[[asian_col]])
  }

  native_col <- find_col(c("^american_indian$", "^American_Indian", "^Native"))
  if (!is.null(native_col)) {
    result$native_american <- safe_numeric(raw_data[[native_col]])
  }

  pacific_col <- find_col(c("^pacific_islander$", "^Pacific_Islander"))
  if (!is.null(pacific_col)) {
    result$pacific_islander <- safe_numeric(raw_data[[pacific_col]])
  }

  multi_col <- find_col(c("^multiracial$", "^Multiple_Race", "^Two"))
  if (!is.null(multi_col)) {
    result$multiracial <- safe_numeric(raw_data[[multi_col]])
  }

  # Gender
  male_col <- find_col(c("^male$", "^Male$"))
  if (!is.null(male_col)) {
    result$male <- safe_numeric(raw_data[[male_col]])
  }

  female_col <- find_col(c("^female$", "^Female$"))
  if (!is.null(female_col)) {
    result$female <- safe_numeric(raw_data[[female_col]])
  }

  # Special populations
  econ_col <- find_col(c("^econ_disadv$", "^Economically_Disadvantaged"))
  if (!is.null(econ_col)) {
    result$econ_disadv <- safe_numeric(raw_data[[econ_col]])
  }

  lep_col <- find_col(c("^lep$", "^English_Learner", "^EL$", "^ELL$"))
  if (!is.null(lep_col)) {
    result$lep <- safe_numeric(raw_data[[lep_col]])
  }

  sped_col <- find_col(c("^special_ed$", "^Student_With_a_Disability", "^SPED$"))
  if (!is.null(sped_col)) {
    result$special_ed <- safe_numeric(raw_data[[sped_col]])
  }

  # Grade levels
  # Pre-K
  pk_col <- find_col(c("^grade_pk$", "^Preschool$", "^Pre_K$", "^PreK$"))
  if (!is.null(pk_col)) {
    result$grade_pk <- safe_numeric(raw_data[[pk_col]])
  }

  # Kindergarten
  k_col <- find_col(c("^grade_k$", "^K$", "^Kindergarten$"))
  if (!is.null(k_col)) {
    result$grade_k <- safe_numeric(raw_data[[k_col]])
  }

  # Grades 1-12
  for (grade in 1:12) {
    grade_str <- sprintf("%02d", grade)
    grade_patterns <- c(
      paste0("^grade_", grade_str, "$"),
      paste0("^Grade_", grade, "$"),
      paste0("^G", grade, "$")
    )
    grade_col <- find_col(grade_patterns)
    if (!is.null(grade_col)) {
      result[[paste0("grade_", grade_str)]] <- safe_numeric(raw_data[[grade_col]])
    }
  }

  # If we don't have row_total but have grade columns, calculate it
  if (!"row_total" %in% names(result) || all(is.na(result$row_total))) {
    grade_cols <- grep("^grade_", names(result), value = TRUE)
    if (length(grade_cols) > 0) {
      grade_data <- result[, grade_cols, drop = FALSE]
      result$row_total <- rowSums(sapply(grade_data, as.numeric), na.rm = TRUE)
      result$row_total[result$row_total == 0] <- NA_integer_
    }
  }

  # Remove any rows that are all NA (sometimes there are empty rows)
  result <- result[!is.na(result$row_total) | !is.na(result$type), ]

  result
}


#' Convert to numeric, handling suppression markers
#'
#' USBE uses various markers for suppressed data (*, <5, N<10, etc.)
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  if (is.numeric(x)) return(x)

  # Convert to character if needed
  x <- as.character(x)

  # Remove commas and whitespace
  x <- gsub(",", "", x)
  x <- trimws(x)

  # Handle common suppression markers
  x[x %in% c("*", ".", "-", "-1", "<5", "N<10", "N/A", "NA", "", "N < 10", "n<10")] <- NA_character_

  # Handle patterns like "< 10" or "<10"
  x[grepl("^[<>]\\s*\\d+$", x)] <- NA_character_

  suppressWarnings(as.numeric(x))
}

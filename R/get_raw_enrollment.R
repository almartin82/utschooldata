# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from
# the Utah State Board of Education (USBE).
#
# Data Sources:
# - Fall Enrollment by Grade Level and Demographics (2018-present)
#   URL pattern: https://www.schools.utah.gov/datastatistics/_datastatisticsfiles_/
#                _reports_/_enrollmentmembership_/{YEAR}FallEnrollmentGradeLevelDemographics.xlsx
#
# Format Eras:
# - Era 1 (2018-present): Excel files with consistent column structure
#   Contains school-level enrollment with grade and demographic breakdowns
#   Excel workbook has multiple sheets: State, By County, By LEA, By School
#
# ==============================================================================

#' Download raw enrollment data from USBE
#'
#' Downloads enrollment data from USBE's Data and Statistics reports.
#' Data is provided as Excel files with multiple sheets.
#' Returns combined data from State, LEA (district), and School sheets.
#'
#' @param end_year School year end (e.g., 2024 = 2023-24 school year)
#' @return List with state, district, and school data frames
#' @keywords internal
get_raw_enr <- function(end_year) {

  available_years <- get_available_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "Year ", end_year, " not available. ",
      "Available years: ", min(available_years), "-", max(available_years)
    ))
  }

  message(paste("Downloading USBE enrollment data for", end_year, "..."))

  # Download the enrollment file and read all sheets
  raw_data <- download_usbe_enrollment(end_year)

  raw_data
}


#' Download USBE Fall Enrollment data
#'
#' Downloads the Fall Enrollment by Grade Level and Demographics Excel file
#' from the USBE Data and Statistics portal and reads all relevant sheets.
#'
#' @param end_year School year end
#' @return List with state, district (LEA), and school data frames
#' @keywords internal
download_usbe_enrollment <- function(end_year) {

  # Build URL for the enrollment file
  url <- build_usbe_url(end_year)
  message(paste0("  Downloading from: ", url))

  # Create temp file for download
  tname <- tempfile(
    pattern = paste0("usbe_enr_", end_year, "_"),
    tmpdir = tempdir(),
    fileext = ".xlsx"
  )

  # Download file
  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(tname, overwrite = TRUE),
      httr::timeout(120),
      httr::user_agent("utschooldata R package")
    )

    if (httr::http_error(response)) {
      status_code <- httr::status_code(response)
      if (status_code == 404) {
        stop(paste0(
          "Enrollment data not found for year ", end_year, ". ",
          "The file may not yet be published or the URL pattern may have changed."
        ))
      }
      stop(paste("HTTP error:", status_code))
    }

    # Verify file was downloaded
    file_info <- file.info(tname)
    if (is.na(file_info$size) || file_info$size < 1000) {
      stop("Downloaded file is too small - may be an error page")
    }

  }, error = function(e) {
    stop(paste("Failed to download enrollment data for year", end_year,
               "\nError:", e$message,
               "\nURL:", url))
  })

  # Get available sheets
  sheets <- readxl::excel_sheets(tname)

  # Read State sheet - filter to only "State Total" row
  message("  Reading State data...")
  state_df <- tryCatch({
    if ("State" %in% sheets) {
      df <- readxl::read_excel(tname, sheet = "State")
      df <- standardize_columns(df)
      # Filter to only State Total row (not Charter Total or District Total)
      lea_type_col <- grep("lea_type|LEA_TYPE", names(df), value = TRUE, ignore.case = TRUE)
      if (length(lea_type_col) > 0) {
        df <- df[grepl("State Total", df[[lea_type_col[1]]], ignore.case = TRUE), ]
      }
      df$level <- "State"
      df
    } else {
      NULL
    }
  }, error = function(e) {
    warning(paste("Could not read State sheet:", e$message))
    NULL
  })

  # Read LEA (district) sheet
  message("  Reading LEA (district) data...")
  lea_df <- tryCatch({
    if ("By LEA" %in% sheets) {
      df <- readxl::read_excel(tname, sheet = "By LEA")
      df$level <- "District"
      standardize_columns(df)
    } else {
      NULL
    }
  }, error = function(e) {
    warning(paste("Could not read By LEA sheet:", e$message))
    NULL
  })

  # Read School sheet
  message("  Reading School data...")
  school_df <- tryCatch({
    if ("By School" %in% sheets) {
      df <- readxl::read_excel(tname, sheet = "By School")
      df$level <- "Campus"
      standardize_columns(df)
    } else {
      NULL
    }
  }, error = function(e) {
    warning(paste("Could not read By School sheet:", e$message))
    NULL
  })

  # Clean up temp file
  unlink(tname)

  # Combine all sheets
  result <- dplyr::bind_rows(state_df, lea_df, school_df)

  if (nrow(result) == 0) {
    stop("No data found in the downloaded file. The file structure may have changed.")
  }

  result
}


#' Standardize column names from USBE Excel files
#'
#' Converts raw USBE column names to standardized format.
#'
#' @param df Data frame with raw column names
#' @return Data frame with standardized column names
#' @keywords internal
standardize_columns <- function(df) {
  # Get original names
  orig_names <- names(df)

  # Create standardized names
  new_names <- orig_names

  # Standardize: remove special chars, convert spaces to underscores
  new_names <- gsub("\\s+", "_", trimws(new_names))
  new_names <- gsub("[^a-zA-Z0-9_]", "", new_names)

  # Apply specific column mappings for known columns
  name_map <- c(
    "School_Year" = "school_year",
    "LEA_TYPE" = "lea_type",
    "LEA_Name" = "lea_name",
    "School_Name" = "school_name",
    "Total_K12" = "total_k12",
    "K" = "grade_k",
    "Grade_1" = "grade_01",
    "Grade_2" = "grade_02",
    "Grade_3" = "grade_03",
    "Grade_4" = "grade_04",
    "Grade_5" = "grade_05",
    "Grade_6" = "grade_06",
    "Grade_7" = "grade_07",
    "Grade_8" = "grade_08",
    "Grade_9" = "grade_09",
    "Grade_10" = "grade_10",
    "Grade_11" = "grade_11",
    "Grade_12" = "grade_12",
    "Female" = "female",
    "Male" = "male",
    "American_Indian" = "american_indian",
    "AfAmBlack" = "black",
    "Asian" = "asian",
    "Hispanic" = "hispanic",
    "Multiple_Race" = "multiracial",
    "Pacific_Islander" = "pacific_islander",
    "White" = "white",
    "Economically_Disadvantaged" = "econ_disadv",
    "English_Learner" = "lep",
    "Student_With_a_Disability" = "special_ed",
    "Homeless" = "homeless",
    "Preschool" = "grade_pk"
  )

  # Apply mappings
  for (i in seq_along(new_names)) {
    if (new_names[i] %in% names(name_map)) {
      new_names[i] <- name_map[new_names[i]]
    }
  }

  names(df) <- new_names
  df
}


#' Build USBE enrollment data URL
#'
#' Constructs the URL for downloading enrollment data from USBE.
#'
#' @param end_year School year end
#' @return Character string with full URL
#' @keywords internal
build_usbe_url <- function(end_year) {
  base_url <- "https://www.schools.utah.gov/datastatistics/_datastatisticsfiles_/_reports_/_enrollmentmembership_"
  filename <- paste0(end_year, "FallEnrollmentGradeLevelDemographics.xlsx")
  paste0(base_url, "/", filename)
}

# ==============================================================================
# School Directory Data Fetching Functions
# ==============================================================================
#
# This file contains functions for downloading school directory data from the
# Utah State Board of Education (USBE) via the CACTUS system.
#
# Data Sources:
# - School-level data: https://cactus.schools.utah.gov/api/legacy/schools
#   Contains school names, addresses, principals, grades, charter status, etc.
#   Source: CACTUS (Comprehensive Administration of Credentials for Teachers
#   in Utah Schools) system.
#
# - District superintendent data: https://schools.utah.gov/schooldistricts
#   Contains district office addresses, superintendent names/emails, and
#   administrative assistant contacts. Data is embedded as JavaScript on page.
#
# ==============================================================================

# Suppress R CMD check notes about global variables used in dplyr pipelines
utils::globalVariables(c(
  "district_number", "school_number", "school_name", "district_name",
  "is_closed", "is_charter", "is_private", "entity_type",
  "superintendent_name", "superintendent_email",
  "district_name_normalized", "district_name_supt"
))

#' Fetch Utah school directory data
#'
#' Downloads and processes school directory data from the Utah State Board of
#' Education's CACTUS system and district directory. This includes all public
#' schools and districts with contact information, administrator names,
#' and school characteristics.
#'
#' @param end_year Currently unused. The directory data represents current
#'   schools and is updated regularly. Included for API consistency with
#'   other fetch functions.
#' @param tidy If TRUE (default), returns data in a standardized format with
#'   consistent column names. If FALSE, returns raw column names from CACTUS.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#'   Set to FALSE to force re-download from USBE.
#' @return A tibble with school directory data. Columns include:
#'   \itemize{
#'     \item \code{state_district_id}: District number from CACTUS
#'     \item \code{state_school_id}: School number from CACTUS
#'     \item \code{district_name}: District/LEA name
#'     \item \code{school_name}: School name
#'     \item \code{entity_type}: Education type (e.g., "Regular Public", "Charter")
#'     \item \code{school_category}: School category (e.g., "Elementary", "High")
#'     \item \code{grades_served}: Grade range (e.g., "K-6")
#'     \item \code{address}: Street address
#'     \item \code{city}: City
#'     \item \code{state}: State (always "UT")
#'     \item \code{zip}: ZIP code
#'     \item \code{phone}: Phone number
#'     \item \code{principal_name}: School principal name
#'     \item \code{principal_email}: School principal email
#'     \item \code{superintendent_name}: District superintendent name
#'     \item \code{superintendent_email}: District superintendent email
#'     \item \code{website}: School website URL
#'     \item \code{is_charter}: Charter school indicator
#'     \item \code{is_private}: Private school indicator
#'     \item \code{county_name}: County (not available from CACTUS, set to NA)
#'     \item \code{latitude}: Geographic latitude
#'     \item \code{longitude}: Geographic longitude
#'   }
#' @details
#' The directory data is downloaded from two USBE sources:
#' \enumerate{
#'   \item School-level data from the CACTUS (Comprehensive Administration of
#'         Credentials for Teachers in Utah Schools) API, which provides school
#'         names, addresses, principals, grades, and charter status.
#'   \item District superintendent data from the USBE School Districts page,
#'         which provides superintendent names and email addresses.
#' }
#' These two sources are joined by district name to produce a combined
#' directory with both school-level and district-level administrator info.
#'
#' @export
#' @examples
#' \dontrun{
#' # Get school directory data
#' dir_data <- fetch_directory()
#'
#' # Get raw format (original CACTUS column names)
#' dir_raw <- fetch_directory(tidy = FALSE)
#'
#' # Force fresh download (ignore cache)
#' dir_fresh <- fetch_directory(use_cache = FALSE)
#'
#' # Filter to active schools only
#' library(dplyr)
#' active_schools <- dir_data |>
#'   filter(!is_closed)
#'
#' # Find all schools in a district
#' alpine_schools <- dir_data |>
#'   filter(grepl("Alpine", district_name))
#' }
fetch_directory <- function(end_year = NULL, tidy = TRUE, use_cache = TRUE) {

  # Determine cache type based on tidy parameter
  cache_type <- if (tidy) "directory_tidy" else "directory_raw"

  # Check cache first
  if (use_cache && cache_exists_directory(cache_type)) {
    message("Using cached school directory data")
    return(read_cache_directory(cache_type))
  }

  # Get raw data from CACTUS API
  raw <- get_raw_directory()

  # Process to standard schema
  if (tidy) {
    result <- process_directory(raw)
  } else {
    result <- raw
  }

  # Cache the result
  if (use_cache) {
    write_cache_directory(result, cache_type)
  }

  result
}


#' Get raw school directory data from USBE CACTUS API
#'
#' Downloads the raw school directory data from the CACTUS legacy API endpoint.
#' This is official USBE data from the CACTUS (Comprehensive Administration of
#' Credentials for Teachers in Utah Schools) system.
#'
#' @return Raw data frame as downloaded from CACTUS
#' @keywords internal
get_raw_directory <- function() {

  url <- "https://cactus.schools.utah.gov/api/legacy/schools"

  message("Downloading school directory data from USBE CACTUS API...")
  message(paste0("  URL: ", url))

  tryCatch({
    response <- httr::GET(
      url,
      httr::timeout(120),
      httr::user_agent("utschooldata R package"),
      httr::accept_json()
    )

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response)))
    }

    content_type <- httr::http_type(response)
    raw_text <- httr::content(response, as = "text", encoding = "UTF-8")

    # Parse JSON
    parsed <- jsonlite::fromJSON(raw_text, flatten = TRUE)

    # The schools are in the 'schools' element
    if ("schools" %in% names(parsed)) {
      df <- dplyr::as_tibble(parsed$schools)
    } else {
      # Might be a flat array
      df <- dplyr::as_tibble(parsed)
    }

    message(paste("  Loaded", nrow(df), "school records"))

    df

  }, error = function(e) {
    stop(paste("Failed to download school directory data from USBE CACTUS API:",
               e$message))
  })
}


#' Download district superintendent data from USBE
#'
#' Scrapes superintendent names and email addresses from the USBE School
#' Districts page. The data is embedded as a JavaScript array in the page HTML.
#'
#' @return Data frame with district name, superintendent name/email
#' @keywords internal
get_district_superintendent_data <- function() {

  url <- "https://schools.utah.gov/schooldistricts"

  message("  Downloading district superintendent data...")

  tryCatch({
    response <- httr::GET(
      url,
      httr::timeout(60),
      httr::user_agent("utschooldata R package")
    )

    if (httr::http_error(response)) {
      warning(paste("Could not download superintendent data. HTTP error:",
                    httr::status_code(response)))
      return(NULL)
    }

    html_text <- httr::content(response, as = "text", encoding = "UTF-8")

    # Extract the JavaScript districts array from the page source
    # The data is embedded as: var districts = [{...}, ...];
    # We use bracket-matching because the array contains nested arrays
    # (Assistants field) so a simple regex can't find the right closing bracket.
    start_marker <- "var districts = "
    start_pos <- regexpr(start_marker, html_text, fixed = TRUE)

    if (start_pos < 0) {
      warning("Could not find district data in page source")
      return(NULL)
    }

    # Start from the [ after "var districts = "
    json_start <- start_pos + nchar(start_marker)
    remaining <- substring(html_text, json_start)

    # Find the matching closing bracket by counting bracket depth
    depth <- 0L
    end_pos <- 0L
    for (i in seq_len(min(nchar(remaining), 100000L))) {
      ch <- substr(remaining, i, i)
      if (ch == "[") depth <- depth + 1L
      if (ch == "]") {
        depth <- depth - 1L
        if (depth == 0L) {
          end_pos <- i
          break
        }
      }
    }

    if (end_pos == 0L) {
      warning("Could not parse district data array from page source")
      return(NULL)
    }

    json_text <- substr(remaining, 1L, end_pos)

    districts <- jsonlite::fromJSON(json_text, flatten = TRUE)
    districts <- dplyr::as_tibble(districts)

    message(paste("  Found", nrow(districts), "districts with superintendent data"))

    # Standardize to just the fields we need
    result <- dplyr::tibble(
      district_name_supt = if ("Name" %in% names(districts)) {
        paste0(districts$Name, " District")
      } else {
        NA_character_
      },
      superintendent_name = if (all(c("SuperintendentFirstName", "SuperintendentLastName") %in% names(districts))) {
        trimws(paste(districts$SuperintendentFirstName, districts$SuperintendentLastName))
      } else {
        NA_character_
      },
      superintendent_email = if ("SuperintendentEmail" %in% names(districts)) {
        districts$SuperintendentEmail
      } else {
        NA_character_
      },
      district_office_address = if ("OfficeAddress" %in% names(districts)) {
        districts$OfficeAddress
      } else {
        NA_character_
      },
      district_office_city = if ("OfficeCity" %in% names(districts)) {
        districts$OfficeCity
      } else {
        NA_character_
      },
      district_office_zip = if ("OfficeZip" %in% names(districts)) {
        districts$OfficeZip
      } else {
        NA_character_
      },
      district_office_phone = if ("OfficePhone" %in% names(districts)) {
        districts$OfficePhone
      } else {
        NA_character_
      },
      district_website = if ("Website" %in% names(districts)) {
        districts$Website
      } else {
        NA_character_
      }
    )

    result

  }, error = function(e) {
    warning(paste("Could not download superintendent data:", e$message))
    return(NULL)
  })
}


#' Process raw school directory data to standard schema
#'
#' Takes raw school directory data from CACTUS and standardizes column names,
#' types, and adds derived columns. Joins with district superintendent data.
#'
#' @param raw_data Raw data frame from get_raw_directory()
#' @return Processed data frame with standard schema
#' @keywords internal
process_directory <- function(raw_data) {

  cols <- names(raw_data)

  # Helper to find columns with flexible matching
  find_col <- function(patterns) {
    for (pattern in patterns) {
      matched <- grep(pattern, cols, value = TRUE, ignore.case = TRUE)
      if (length(matched) > 0) return(matched[1])
    }
    NULL
  }

  # Helper to safely extract a column value
  safe_extract <- function(col_name) {
    if (!is.null(col_name) && col_name %in% cols) {
      as.character(raw_data[[col_name]])
    } else {
      rep(NA_character_, nrow(raw_data))
    }
  }

  n_rows <- nrow(raw_data)
  result <- dplyr::tibble(.rows = n_rows)

  # District number/ID
  dist_num_col <- find_col(c("^districtNumber$", "^district_number$", "^districtId$"))
  result$state_district_id <- safe_extract(dist_num_col)

  # School number/ID
  school_num_col <- find_col(c("^schoolNumber$", "^school_number$", "^schoolId$"))
  result$state_school_id <- safe_extract(school_num_col)

  # District/LEA name
  lea_col <- find_col(c("^leaName$", "^lea_name$", "^leaTitle$"))
  result$district_name <- trimws(safe_extract(lea_col))

  # School name
  school_col <- find_col(c("^schoolName$", "^school_name$", "^schoolTitle$"))
  result$school_name <- trimws(safe_extract(school_col))

  # Entity/education type
  edu_type_col <- find_col(c("^educationType$", "^education_type$"))
  result$entity_type <- trimws(safe_extract(edu_type_col))

  # School category
  cat_col <- find_col(c("^schoolCategory$", "^school_category$"))
  result$school_category <- trimws(safe_extract(cat_col))

  # Grade range
  grade_low_col <- find_col(c("^gradeLow$", "^grade_low$"))
  grade_high_col <- find_col(c("^gradeHigh$", "^grade_high$"))
  if (!is.null(grade_low_col) && !is.null(grade_high_col)) {
    low <- trimws(safe_extract(grade_low_col))
    high <- trimws(safe_extract(grade_high_col))
    result$grades_served <- ifelse(
      !is.na(low) & !is.na(high) & low != "" & high != "",
      paste0(low, "-", high),
      NA_character_
    )
  } else {
    result$grades_served <- NA_character_
  }

  # Address - prefer physical address over mailing address
  phys_addr_col <- find_col(c("^physicalAddress1$", "^physical_address1$"))
  mail_addr_col <- find_col(c("^address1$", "^address$"))
  addr_col <- if (!is.null(phys_addr_col)) phys_addr_col else mail_addr_col
  result$address <- trimws(safe_extract(addr_col))

  # City
  phys_city_col <- find_col(c("^physicalCity$", "^physical_city$"))
  mail_city_col <- find_col(c("^city$"))
  city_col <- if (!is.null(phys_city_col)) phys_city_col else mail_city_col
  result$city <- trimws(safe_extract(city_col))

  # State
  phys_state_col <- find_col(c("^physicalState$", "^physical_state$"))
  mail_state_col <- find_col(c("^state$"))
  state_col <- if (!is.null(phys_state_col)) phys_state_col else mail_state_col
  state_vals <- trimws(safe_extract(state_col))
  result$state <- ifelse(!is.na(state_vals) & state_vals != "", state_vals, "UT")

  # ZIP
  phys_zip_col <- find_col(c("^physicalZip$", "^physical_zip$"))
  mail_zip_col <- find_col(c("^zip$"))
  zip_col <- if (!is.null(phys_zip_col)) phys_zip_col else mail_zip_col
  result$zip <- trimws(safe_extract(zip_col))

  # Phone
  phone_col <- find_col(c("^phone$"))
  result$phone <- trimws(safe_extract(phone_col))

  # Fax
  fax_col <- find_col(c("^fax$"))
  result$fax <- trimws(safe_extract(fax_col))

  # Principal name
  principal_col <- find_col(c("^principalName$", "^principal_name$"))
  result$principal_name <- trimws(safe_extract(principal_col))

  # Principal email
  principal_email_col <- find_col(c("^principalEmail$", "^principal_email$"))
  result$principal_email <- trimws(safe_extract(principal_email_col))

  # Website
  url_col <- find_col(c("^url$", "^website$"))
  result$website <- trimws(safe_extract(url_col))

  # Charter status
  charter_col <- find_col(c("^isCharter$", "^is_charter$"))
  if (!is.null(charter_col)) {
    charter_vals <- raw_data[[charter_col]]
    result$is_charter <- charter_vals %in% c(TRUE, "Y", "Yes", "true", "TRUE", 1)
  } else {
    result$is_charter <- FALSE
  }

  # Private status
  private_col <- find_col(c("^isPrivate$", "^is_private$"))
  if (!is.null(private_col)) {
    private_vals <- raw_data[[private_col]]
    result$is_private <- private_vals %in% c(TRUE, "Y", "Yes", "true", "TRUE", 1)
  } else {
    result$is_private <- FALSE
  }

  # Closed status
  closed_col <- find_col(c("^isClosed$", "^is_closed$"))
  if (!is.null(closed_col)) {
    closed_vals <- raw_data[[closed_col]]
    result$is_closed <- closed_vals %in% c(TRUE, "Y", "Yes", "true", "TRUE", 1)
  } else {
    result$is_closed <- FALSE
  }

  # Title I status
  title1_col <- find_col(c("^isTitle1CurrentYear$", "^is_title1_current$"))
  if (!is.null(title1_col)) {
    title1_vals <- raw_data[[title1_col]]
    result$is_title1 <- title1_vals %in% c(TRUE, "Y", "Yes", "true", "TRUE", 1)
  } else {
    result$is_title1 <- NA
  }

  # Year opened/closed
  year_opened_col <- find_col(c("^yearOpened$", "^year_opened$"))
  result$year_opened <- safe_extract(year_opened_col)

  year_closed_col <- find_col(c("^yearClosed$", "^year_closed$"))
  result$year_closed <- safe_extract(year_closed_col)

  # Latitude/Longitude
  lat_col <- find_col(c("^latitude$", "^lat$"))
  lon_col <- find_col(c("^longitude$", "^lon$", "^lng$"))
  result$latitude <- if (!is.null(lat_col)) {
    suppressWarnings(as.numeric(raw_data[[lat_col]]))
  } else {
    NA_real_
  }
  result$longitude <- if (!is.null(lon_col)) {
    suppressWarnings(as.numeric(raw_data[[lon_col]]))
  } else {
    NA_real_
  }

  # County is not available from CACTUS API
  result$county_name <- NA_character_

  # --- Join superintendent data from district directory ---
  supt_data <- get_district_superintendent_data()

  if (!is.null(supt_data) && nrow(supt_data) > 0) {
    # Join by district name - need to handle naming differences
    # CACTUS uses "Alpine School District" style, supt page uses "Alpine District"
    # Normalize both for matching
    result$district_name_normalized <- normalize_district_name(result$district_name)
    supt_data$district_name_normalized <- normalize_district_name(supt_data$district_name_supt)

    result <- dplyr::left_join(
      result,
      supt_data |> dplyr::select(
        district_name_normalized,
        superintendent_name, superintendent_email
      ),
      by = "district_name_normalized"
    )

    # Drop the normalized column
    result$district_name_normalized <- NULL
  } else {
    result$superintendent_name <- NA_character_
    result$superintendent_email <- NA_character_
  }

  # Reorder columns for consistency
  preferred_order <- c(
    "state_district_id", "state_school_id",
    "district_name", "school_name",
    "entity_type", "school_category",
    "grades_served",
    "address", "city", "state", "zip", "phone", "fax",
    "principal_name", "principal_email",
    "superintendent_name", "superintendent_email",
    "website",
    "is_charter", "is_private", "is_closed", "is_title1",
    "year_opened", "year_closed",
    "latitude", "longitude",
    "county_name"
  )

  existing_cols <- preferred_order[preferred_order %in% names(result)]
  other_cols <- setdiff(names(result), preferred_order)

  result <- result |>
    dplyr::select(dplyr::all_of(c(existing_cols, other_cols)))

  result
}


#' Normalize district names for matching
#'
#' Strips common suffixes like "School District", "District", etc. and
#' normalizes whitespace/case for matching between data sources.
#'
#' @param names Character vector of district names
#' @return Normalized character vector
#' @keywords internal
normalize_district_name <- function(names) {
  x <- tolower(trimws(names))
  # Remove common suffixes

  x <- gsub("\\s+school\\s+district$", "", x)
  x <- gsub("\\s+district$", "", x)
  x <- gsub("\\s+charter\\s+school$", "", x)
  # Normalize whitespace
  x <- gsub("\\s+", " ", x)
  x
}


# ==============================================================================
# Directory-specific cache functions
# ==============================================================================

#' Build cache file path for directory data
#'
#' @param cache_type Type of cache ("directory_tidy" or "directory_raw")
#' @return File path string
#' @keywords internal
build_cache_path_directory <- function(cache_type) {
  cache_dir <- get_cache_dir()
  file.path(cache_dir, paste0(cache_type, ".rds"))
}


#' Check if cached directory data exists
#'
#' @param cache_type Type of cache ("directory_tidy" or "directory_raw")
#' @param max_age Maximum age in days (default 7). Set to Inf to ignore age.
#' @return Logical indicating if valid cache exists
#' @keywords internal
cache_exists_directory <- function(cache_type, max_age = 7) {
  cache_path <- build_cache_path_directory(cache_type)

  if (!file.exists(cache_path)) {
    return(FALSE)
  }

  # Check age
  file_info <- file.info(cache_path)
  age_days <- as.numeric(difftime(Sys.time(), file_info$mtime, units = "days"))

  age_days <= max_age
}


#' Read directory data from cache
#'
#' @param cache_type Type of cache ("directory_tidy" or "directory_raw")
#' @return Cached data frame
#' @keywords internal
read_cache_directory <- function(cache_type) {
  cache_path <- build_cache_path_directory(cache_type)
  readRDS(cache_path)
}


#' Write directory data to cache
#'
#' @param data Data frame to cache
#' @param cache_type Type of cache ("directory_tidy" or "directory_raw")
#' @return Invisibly returns the cache path
#' @keywords internal
write_cache_directory <- function(data, cache_type) {
  cache_path <- build_cache_path_directory(cache_type)
  cache_dir <- dirname(cache_path)

  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  saveRDS(data, cache_path)
  invisible(cache_path)
}


#' Clear school directory cache
#'
#' Removes cached school directory data files.
#'
#' @return Invisibly returns the number of files removed
#' @export
#' @examples
#' \dontrun{
#' # Clear cached directory data
#' clear_directory_cache()
#' }
clear_directory_cache <- function() {
  cache_dir <- get_cache_dir()

  if (!dir.exists(cache_dir)) {
    message("Cache directory does not exist")
    return(invisible(0))
  }

  files <- list.files(cache_dir, pattern = "^directory_", full.names = TRUE)

  if (length(files) > 0) {
    file.remove(files)
    message(paste("Removed", length(files), "cached directory file(s)"))
  } else {
    message("No cached directory files to remove")
  }

  invisible(length(files))
}

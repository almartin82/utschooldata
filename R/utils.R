# ==============================================================================
# Utility Functions
# ==============================================================================

#' @importFrom rlang .data
NULL


# Note: safe_numeric is defined in process_enrollment.R


#' Get available years for Utah enrollment data
#'
#' Returns the range of years for which enrollment data is available
#' from the Utah State Board of Education.
#'
#' @return Integer vector of available years
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  # Utah enrollment data is available from 2014 to current year
  #
  # Data availability by year range:
  # - 2019-2026: Full State, LEA (district), and School-level data
  #   URL pattern: {YEAR}FallEnrollmentGradeLevelDemographics.xlsx
  #   Where YEAR represents the school year end (e.g., 2024 = 2023-24 school year)
  #

  # - 2014-2018: State-level totals only (from State Total Time Series sheet)
  #   Available in the superintendent annual report file
  #
  # Note: 2026 files exist for projections/current year
  2014:2026
}


#' Get years with full school-level data
#'
#' Returns years that have full State, LEA, and School-level data available.
#' Earlier years (2014-2018) only have state-level totals.
#'
#' @return Integer vector of years with full data
#' @keywords internal
get_full_data_years <- function() {
  2019:2026
}


#' Get years with state-level data only
#'
#' Returns years that only have state-level enrollment totals available.
#' These years use the State Total Time Series sheet from the
#' superintendent annual report.
#'
#' @return Integer vector of years with state-only data
#' @keywords internal
get_state_only_years <- function() {
  2014:2018
}

# ==============================================================================
# Utility Functions
# ==============================================================================

#' Pipe operator
#'
#' See \code{dplyr::\link[dplyr:reexports]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
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
  # Utah enrollment data is available from 2018 to current year

# The USBE publishes Fall Enrollment data each year
  # URL pattern: {YEAR}FallEnrollmentGradeLevelDemographics.xlsx
  # Where YEAR represents the school year end (e.g., 2024 = 2023-24 school year)

  # Current available years based on USBE data portal
  # Note: 2026 files exist for projections/current year
  2018:2026
}

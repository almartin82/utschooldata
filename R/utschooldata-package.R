#' @keywords internal
"_PACKAGE"

#' utschooldata: Fetch and Process Utah School Data
#'
#' The utschooldata package provides functions for downloading, processing,
#' and analyzing school enrollment data from the Utah State Board of Education
#' (USBE). It offers a programmatic interface to Utah's public school data,
#' enabling researchers, analysts, and education policy professionals to
#' easily access Utah public school enrollment data.
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{fetch_enr}}: Download and process enrollment data for a single year
#'   \item \code{\link{fetch_enr_multi}}: Download and process enrollment data for multiple years
#'   \item \code{\link{tidy_enr}}: Transform wide data to tidy (long) format
#'   \item \code{\link{get_available_years}}: List available data years
#' }
#'
#' @section Caching Functions:
#' \itemize{
#'   \item \code{\link{cache_status}}: Show cached data status
#'   \item \code{\link{clear_cache}}: Clear cached data
#' }
#'
#' @section Data Structure:
#' Utah enrollment data includes:
#' \itemize{
#'   \item School-level enrollment counts
#'   \item Grade-level breakdowns (K-12)
#'   \item Demographic breakdowns (race/ethnicity)
#'   \item Special population counts (ELL, Special Ed, Economically Disadvantaged)
#' }
#'
#' @section Data Availability:
#' \itemize{
#'   \item Years: 2018 to present (updated annually)
#'   \item Aggregation levels: State, District (LEA), School (Campus)
#'   \item Source: Utah State Board of Education (USBE) Data and Statistics
#' }
#'
#' @section Identifiers:
#' \itemize{
#'   \item LEA/District ID: Numeric identifier for Local Education Agency
#'   \item School ID: Numeric identifier for individual schools
#' }
#'
#' @name utschooldata-package
#' @aliases utschooldata
NULL

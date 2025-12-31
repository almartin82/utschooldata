# Fetch Utah enrollment data

Downloads and processes enrollment data from the Utah State Board of
Education (USBE) Fall Enrollment reports.

## Usage

``` r
fetch_enr(end_year, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  A school year. Year is the end of the academic year - e.g., 2023-24
  school year is year '2024'. Valid values are 2014-2026.

  **Note on data availability:**

  - Years 2019-2026: Full State, LEA (district), and School-level data

  - Years 2014-2018: State-level totals only (from historical time
    series)

- tidy:

  If TRUE (default), returns data in long (tidy) format with subgroup
  column. If FALSE, returns wide format.

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download from USBE.

## Value

Data frame with enrollment data. Wide format includes columns for
district_id, campus_id, names, and enrollment counts by
demographic/grade. Tidy format pivots these counts into subgroup and
grade_level columns. For years 2014-2018, only state-level totals are
returned.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# Get wide format
enr_wide <- fetch_enr(2024, tidy = FALSE)

# Force fresh download (ignore cache)
enr_fresh <- fetch_enr(2024, use_cache = FALSE)

# Filter to specific district
salt_lake <- enr_2024 %>%
  dplyr::filter(grepl("Salt Lake", district_name, ignore.case = TRUE))

# Historical state-level data (2014-2018)
state_2015 <- fetch_enr(2015)  # State totals only
} # }
```

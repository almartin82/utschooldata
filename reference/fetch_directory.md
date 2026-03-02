# Fetch Utah school directory data

Downloads and processes school directory data from the Utah State Board
of Education's CACTUS system and district directory. This includes all
public schools and districts with contact information, administrator
names, and school characteristics.

## Usage

``` r
fetch_directory(end_year = NULL, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  Currently unused. The directory data represents current schools and is
  updated regularly. Included for API consistency with other fetch
  functions.

- tidy:

  If TRUE (default), returns data in a standardized format with
  consistent column names. If FALSE, returns raw column names from
  CACTUS.

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download from USBE.

## Value

A tibble with school directory data. Columns include:

- `state_district_id`: District number from CACTUS

- `state_school_id`: School number from CACTUS

- `district_name`: District/LEA name

- `school_name`: School name

- `entity_type`: Education type (e.g., "Regular Public", "Charter")

- `school_category`: School category (e.g., "Elementary", "High")

- `grades_served`: Grade range (e.g., "K-6")

- `address`: Street address

- `city`: City

- `state`: State (always "UT")

- `zip`: ZIP code

- `phone`: Phone number

- `principal_name`: School principal name

- `principal_email`: School principal email

- `superintendent_name`: District superintendent name

- `superintendent_email`: District superintendent email

- `website`: School website URL

- `is_charter`: Charter school indicator

- `is_private`: Private school indicator

- `county_name`: County (not available from CACTUS, set to NA)

- `latitude`: Geographic latitude

- `longitude`: Geographic longitude

## Details

The directory data is downloaded from two USBE sources:

1.  School-level data from the CACTUS (Comprehensive Administration of
    Credentials for Teachers in Utah Schools) API, which provides school
    names, addresses, principals, grades, and charter status.

2.  District superintendent data from the USBE School Districts page,
    which provides superintendent names and email addresses.

These two sources are joined by district name to produce a combined
directory with both school-level and district-level administrator info.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get school directory data
dir_data <- fetch_directory()

# Get raw format (original CACTUS column names)
dir_raw <- fetch_directory(tidy = FALSE)

# Force fresh download (ignore cache)
dir_fresh <- fetch_directory(use_cache = FALSE)

# Filter to active schools only
library(dplyr)
active_schools <- dir_data |>
  filter(!is_closed)

# Find all schools in a district
alpine_schools <- dir_data |>
  filter(grepl("Alpine", district_name))
} # }
```

# utschooldata

An R package for fetching, processing, and analyzing school enrollment
data from Utah’s State Board of Education (USBE). It provides a
programmatic interface to Utah public school data, enabling researchers,
analysts, and education policy professionals to easily access Utah
public school enrollment data.

## Installation

You can install the development version of utschooldata from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("almartin82/utschooldata")
```

## Quick Start

``` r
library(utschooldata)

# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# View state totals
enr_2024 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# Get data for multiple years
enr_multi <- fetch_enr_multi(2020:2024)

# Analyze enrollment trends
enr_multi %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)
```

## Data Availability

### Years Available

| Era     | Years     | Format        | Notes                                           |
|---------|-----------|---------------|-------------------------------------------------|
| Current | 2018-2026 | Excel (.xlsx) | Fall Enrollment by Grade Level and Demographics |

**Earliest available year**: 2018 **Most recent available year**: 2026
**Total years of data**: 9 years

### Data Source

Data is downloaded from the Utah State Board of Education (USBE) Data
and Statistics portal:

- **Primary URL**: <https://schools.utah.gov/datastatistics/reports>
- **File Pattern**: `{YEAR}FallEnrollmentGradeLevelDemographics.xlsx`
- **Collection Date**: October 1 of each school year (Fall Enrollment
  count)

### Aggregation Levels

- **State**: Total Utah enrollment
- **District (LEA)**: Local Education Agency totals (aggregated from
  schools)
- **Campus (School)**: Individual school enrollment

### Demographics Available

| Category            | Fields                                                                        |
|---------------------|-------------------------------------------------------------------------------|
| Race/Ethnicity      | White, Black, Hispanic, Asian, Native American, Pacific Islander, Multiracial |
| Gender              | Male, Female                                                                  |
| Special Populations | Economically Disadvantaged, English Learners (ELL/LEP), Special Education     |
| Grade Levels        | Pre-K, K, 1-12                                                                |

### Identifier System

| Identifier      | Description                   | Example                     |
|-----------------|-------------------------------|-----------------------------|
| LEA/District ID | Local Education Agency number | Numeric ID assigned by USBE |
| School ID       | Individual school number      | Unique within the state     |

### Known Caveats

1.  **Data Suppression**: Small cell sizes may be suppressed for privacy
    (typically N \< 10)
2.  **Charter Schools**: Charter schools are included and can be
    identified where the charter_flag column is available
3.  **Historical Changes**: District boundaries and school
    configurations may change year to year
4.  **October 1 Count**: All enrollment figures represent the official
    October 1 count date
5.  **Pre-2018 Data**: Detailed enrollment data prior to 2018 is not
    available through this package; historical summary data may be
    available through the Superintendent’s Annual Report

## Output Schema

### Wide Format (`tidy = FALSE`)

| Column                                                                        | Type      | Description                                  |
|-------------------------------------------------------------------------------|-----------|----------------------------------------------|
| end_year                                                                      | integer   | School year end (2024 = 2023-24 school year) |
| type                                                                          | character | “State”, “District”, or “Campus”             |
| district_id                                                                   | character | LEA identifier                               |
| campus_id                                                                     | character | School identifier                            |
| district_name                                                                 | character | LEA name                                     |
| campus_name                                                                   | character | School name                                  |
| row_total                                                                     | integer   | Total enrollment                             |
| white, black, hispanic, asian, native_american, pacific_islander, multiracial | integer   | Race/ethnicity counts                        |
| male, female                                                                  | integer   | Gender counts                                |
| econ_disadv, lep, special_ed                                                  | integer   | Special population counts                    |
| grade_pk, grade_k, grade_01 - grade_12                                        | integer   | Grade-level enrollment                       |

### Tidy Format (`tidy = TRUE`, default)

| Column        | Type      | Description                                |
|---------------|-----------|--------------------------------------------|
| end_year      | integer   | School year end                            |
| type          | character | Aggregation level                          |
| district_id   | character | LEA identifier                             |
| campus_id     | character | School identifier                          |
| district_name | character | LEA name                                   |
| campus_name   | character | School name                                |
| grade_level   | character | “TOTAL”, “PK”, “K”, “01”-“12”              |
| subgroup      | character | “total_enrollment”, “white”, “black”, etc. |
| n_students    | integer   | Student count                              |
| pct           | numeric   | Percentage of total (0-1 scale)            |
| is_state      | logical   | TRUE for state-level rows                  |
| is_district   | logical   | TRUE for district-level rows               |
| is_campus     | logical   | TRUE for school-level rows                 |
| is_charter    | logical   | TRUE for charter schools                   |

## Caching

The package caches downloaded data locally to avoid repeated downloads:

``` r
# View cache status
cache_status()

# Clear all cached data
clear_cache()

# Clear specific year
clear_cache(2024)

# Force fresh download (ignore cache)
fetch_enr(2024, use_cache = FALSE)
```

Cache location: `rappdirs::user_cache_dir("utschooldata")`

## Functions

### User-facing (exported)

- `fetch_enr(end_year, tidy = TRUE, use_cache = TRUE)` - Fetch
  enrollment data for a single year
- `fetch_enr_multi(end_years, tidy = TRUE, use_cache = TRUE)` - Fetch
  data for multiple years
- `tidy_enr(df)` - Transform wide format to tidy format
- [`get_available_years()`](https://almartin82.github.io/utschooldata/reference/get_available_years.md) -
  List available data years
- `id_enr_aggs(df)` - Add aggregation level flags
- `enr_grade_aggs(df)` - Create K-8, HS, K-12 grade aggregates
- [`cache_status()`](https://almartin82.github.io/utschooldata/reference/cache_status.md) -
  Show cached data status
- `clear_cache(end_year, type)` - Clear cached data

## Part of the 50 State Schooldata Family

This package is part of a family of R packages providing school
enrollment data for all 50 US states. Each package fetches data directly
from the state’s Department of Education.

**See also:**
[njschooldata](https://github.com/almartin82/njschooldata) - The
original state schooldata package for New Jersey.

**All packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## License

MIT

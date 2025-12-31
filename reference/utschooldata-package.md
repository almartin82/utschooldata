# utschooldata: Fetch and Process Utah School Data

Downloads and processes school enrollment data from the Utah State Board
of Education (USBE). Provides functions for fetching enrollment data
from USBE data reports and transforming it into tidy format for
analysis. Supports data from 2014 to present. Full State, LEA
(district), and School-level data is available from 2019 onwards, with
grade-level and demographic breakdowns. Historical state-level totals
are available for 2014-2018.

The utschooldata package provides functions for downloading, processing,
and analyzing school enrollment data from the Utah State Board of
Education (USBE). It offers a programmatic interface to Utah's public
school data, enabling researchers, analysts, and education policy
professionals to easily access Utah public school enrollment data.

## Main Functions

- [`fetch_enr`](https://almartin82.github.io/utschooldata/reference/fetch_enr.md):
  Download and process enrollment data for a single year

- [`fetch_enr_multi`](https://almartin82.github.io/utschooldata/reference/fetch_enr_multi.md):
  Download and process enrollment data for multiple years

- [`tidy_enr`](https://almartin82.github.io/utschooldata/reference/tidy_enr.md):
  Transform wide data to tidy (long) format

- [`get_available_years`](https://almartin82.github.io/utschooldata/reference/get_available_years.md):
  List available data years

## Caching Functions

- [`cache_status`](https://almartin82.github.io/utschooldata/reference/cache_status.md):
  Show cached data status

- [`clear_cache`](https://almartin82.github.io/utschooldata/reference/clear_cache.md):
  Clear cached data

## Data Structure

Utah enrollment data includes:

- School-level enrollment counts

- Grade-level breakdowns (K-12)

- Demographic breakdowns (race/ethnicity)

- Special population counts (ELL, Special Ed, Economically
  Disadvantaged)

## Data Availability

- Years: 2018 to present (updated annually)

- Aggregation levels: State, District (LEA), School (Campus)

- Source: Utah State Board of Education (USBE) Data and Statistics

## Identifiers

- LEA/District ID: Numeric identifier for Local Education Agency

- School ID: Numeric identifier for individual schools

## See also

Useful links:

- <https://github.com/almartin82/utschooldata>

- Report bugs at <https://github.com/almartin82/utschooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>

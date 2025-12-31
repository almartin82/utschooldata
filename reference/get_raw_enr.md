# Download raw enrollment data from USBE

Downloads enrollment data from USBE's Data and Statistics reports. For
years 2019 and later, data is provided as Excel files with multiple
sheets (State, By LEA, By School). For years 2014-2018, only state-level
totals are available from the State Total Time Series sheet.

## Usage

``` r
get_raw_enr(end_year)
```

## Arguments

- end_year:

  School year end (e.g., 2024 = 2023-24 school year)

## Value

Data frame with combined enrollment data (state, district, and school
levels for 2019+; state level only for 2014-2018)

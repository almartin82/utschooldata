# Download USBE historical enrollment data from Time Series

Downloads state-level enrollment data for years 2014-2018 from the
"State Total Time Series" sheet in the superintendent annual report
file. This sheet contains historical state totals that are not available
in individual year files.

## Usage

``` r
download_usbe_time_series(end_year)
```

## Arguments

- end_year:

  School year end (2014-2018)

## Value

Data frame with state-level enrollment data

# Convert to numeric, handling suppression markers

USBE uses various markers for suppressed data (\*, \<5, N\<10, etc.)

## Usage

``` r
safe_numeric(x)
```

## Arguments

- x:

  Vector to convert

## Value

Numeric vector with NA for non-numeric values

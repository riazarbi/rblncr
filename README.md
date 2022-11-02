# rblncr

Automatically Rebalance Equity Portfolios with R.

## Call for issues

This package largely serves my personal needs, so I have stopped short of doing the following:

1.  Comprehensive tests
2.  CRAN compliance and submission (`RCMDCHECK` passes, though)
3.  Implementing other backends

These things are possible, but someone needs to ask for them and convince me that they would be worthwhile. If you would like to request something (or point out a bug), submit an issue.

## Documentation

See <https://riazarbi.github.io/rblncr>

## Install

You can install the development version of rblncr from [GitHub](https://github.com/) with:

`devtools::install_github("riazarbi/rblncr")`

No CRAN submission currently planned.


## Example

The bulk of the package functionality is exercised in this example:

``` r
t_conn <- alpaca_connect('paper',
                        Sys.getenv("ALPACA_PAPER_KEY"),
                        Sys.getenv("ALPACA_PAPER_SECRET"))
d_conn <- alpaca_connect('data',
                        Sys.getenv("ALPACA_LIVE_KEY"),
                        Sys.getenv("ALPACA_LIVE_SECRET"))

portfolio_model <- read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))

get_portfolio_current(t_conn) |>
 load_portfolio_targets(portfolio_model) |>
 price_portfolio(connection = d_conn, price_type = 'close') |>
 solve_portfolio() |>
 constrain_orders(d_conn) |>
 trader(trading_connection = t_conn,
        pricing_connection = d_conn,
        verbose = TRUE)
```

Alternatively you could use the wrapper `balance_portfolio` function to achieve the above:

```r
balance_portfolio(portfolio_model,
                  t_conn,
                  d_conn,
                  verbose = F)
```

## Similar Packages

Here are some R packages that are similar or adjacent to this package.

- [alpacaforr](https://github.com/yogat3ch/AlpacaforR)
- [backtest](https://cran.r-project.org/package=backtest)
- [portfolio](https://cran.r-project.org/package=portfolio)
- [strand](https://cran.r-project.org/package=strand)

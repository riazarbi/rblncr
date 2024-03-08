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

```r
devtools::install_github("riazarbi/rblncr")
```

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

Alternatively you could use the wrapper `balance_portfolio` function to achieve the above. 

```r
balance_portfolio(portfolio_model,
                  t_conn,
                  d_conn,
                  verbose = F)
```

Note that `balance_portfolio` does not guarantee that the portfolio will be balanced by the end of execution. For instance, your orders could fail to find a buyer before cancellation. To _guarantee_ that your portfolio rebalances, consider placing your code in a `while` loop.

```
$portfolio_balanced
[1] FALSE

$drift
  symbol drift
1   AAPL   0.0
2   GOOG   0.0
3   TSLA   0.0
4     VT   7.5

$trades
            timestamp symbol order  limit filled   status
1 2022-11-02 13:44:04   AAPL    29 149.88     29   filled
2 2022-11-02 13:44:05     VT   118  83.83      0 canceled
3 2022-11-02 13:44:14     VT   118  83.87      0 canceled
4 2022-11-02 13:44:23     VT   118  83.87      0 canceled
5 2022-11-02 13:44:33     VT   118  83.88      0 canceled
```
## Similar Packages

Here are some R packages that are similar or adjacent to this package. This does not constitute an endorsement.

- [alpacaforr](https://github.com/yogat3ch/AlpacaforR): Interact with Alpaca from R
- [backtest](https://cran.r-project.org/package=backtest): The backtest package provides facilities for exploring portfolio-based conjectures about financial instruments (stocks, bonds, swaps, options, et cetera). 
- [portfolio](https://cran.r-project.org/package=portfolio): Classes for analysing and implementing equity portfolios, including routines for generating tradelists and calculating exposures to user-specified risk factors.
- [strand](https://cran.r-project.org/package=strand): Provides a framework for performing discrete (share-level) simulations of investment strategies.

# Python Refactor

I'm deleting R files as I go. 

I've done the alpaca functions, and validation functions. Along with tests. 


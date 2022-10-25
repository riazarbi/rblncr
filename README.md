# rblncr

Declarative portfolio management with R. 

## Aspiration

It should be possible to rebalance your equity portfolio by changing the contents of a file on your computer or in a github repo.

## WIP Notice

This repo is a work in progress. The rationale for the project is covered in this [blog post](https://riazarbi.github.io/quant/portfoli-model-spec/). Everything in this repo (including this README) is likely to change dramatically as I code through the problem. 

## Basic elements

- Portfolio model specification  
- Tooling to retrieve current holdings from broker  
- Portfolio solver to tell us what needs to happen to balance our portfolio
- Trade generation engine to generate required trades to get the current holdings to the model specification  
- Trade submission tooling to actually submit trades to broker  

## Dev Steps

[X] Develop portfolio model spec and tooling  
[X] Select initial broker to develop against  
[X] Write functions to obtain portfolio holdings from broker  
[X] Build portfolio solver  
[X] Build order generator  
[ ] Write functions to submit orders to broker  
[ ] Write tests  
[ ] Write documentation  
[ ] Jump through RCMDCHECK hoops  
[ ] Create a github action to periodically execute the code necessary to rebalance the portfolio  

## Core Concepts and Usage

I haven't turned this into a proper R package yet, so to load the functions you'll have to manually source the R files in the `R` subdirectory.

```r  
source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
```

### Portfolio Model

A portfolio model is a specification of what your ideal portfolio allocations should be. It's easiest to see this as a `yaml` document:

```yaml
name: sample_portfolio
description: create from function
cash:
  percent: 10.0
  tolerance: 0.0
assets:
- symbol: AAPL
  percent: 80.5
  tolerance: 2.0
- symbol: GOOG
  percent: 9.5
  tolerance: 2.0
created_at: 2022-10-19T10:08:50
updated_at: 2022-10-19T10:08:50
```

When loaded into R, a portfolio model is actually a nested R list, and has four elements.

1. A name (string)  
2. A description (string)  
3. A desired cash allocation (list). The `cash` element must be a list with two elements, `percent`, and `tolerance`, both numeric.   
4. A desired asset_weights (data frame). The `asset_weights` data frame must have three columns. `symbol` and `percent`.
5. A drift `tolerance`.

In `cash` and `asset_weights`, `percent` refers to the desired percentage allocation to the respective asset. So, `percent = 30` means allocate 30% of the portfolio to the asset. `tolerance` refers to the acceptable relative level of deviation from the target percentage without triggering a trade. So, with `percent = 30` and `tolerance = 10`, an actual holding can vary by 10% of 30% (ie between 27.27% and 33%) without triggering a rebalance. 

Setting appropriate tolerances is something of an art, as it depends on the size of your portfolio, the number of allocations, and trade-offs between trade churn (which is expensive) and appropriate exposure. 

We can either create a portfolio model by creating it directly in R, or we can just manually create a `yaml` file.

Here's how we might generate these elements:

```r
name <- "sample_portfolio"
description <- "create from function"
cash <- list(percent = 10)
assets <- data.frame(symbol = c("AAPL","GOOG"), percent = c(80.5,9.5)). 
tolerance <- list(percent = 5)

sample_portfolio <- create_portfolio_model(name = name,
                             description = description,
                             cash = cash,
                             assets = assets,
                             tolerance = tolerance)
```

Here's the actual structure of the object:

```
> str(sample_portfolio)
List of 7
 $ name       : chr "sample_portfolio"
 $ description: chr "create from function"
 $ cash       :List of 1
  ..$ percent: num 10
 $ assets     :'data.frame':	2 obs. of  2 variables:
  ..$ symbol : chr [1:2] "AAPL" "GOOG"
  ..$ percent: num [1:2] 80.5 9.5
 $ tolerance  :List of 1
  ..$ percent: num 5
 $ created_at : chr "2022-10-24T09:38:58"
 $ updated_at : chr "2022-10-24T09:38:58"
```

We can save the model to yaml, and we can open that file in a text editor to verify that it looks like the example above.

```r
save_portfolio_model(sample_portfolio, "inst/extdata/sample_portfolio.yaml")  
```

We can load a model from yaml

```r
loaded_model <- read_portfolio_model("inst/extdata/sample_portfolio.yaml")
```

And we can check that it is a valid portfolio model object.

```r
validate_portfolio_model(loaded_model)
```

We can change a model by either manually editing the yaml file, or by updating an element of the list.

```r
modified_model <- update_portfolio_model(loaded_model, "name", "port3")
```

Note that the `name` and `updated_at` elements have changed.

```
> str(modified_model)
List of 7
 $ name       : chr "port3"
 $ description: chr "create from function"
 $ cash       :List of 1
  ..$ percent: num 10
 $ assets     :'data.frame':	2 obs. of  2 variables:
  ..$ symbol : chr [1:2] "AAPL" "GOOG"
  ..$ percent: num [1:2] 80.5 9.5
 $ tolerance  :List of 1
  ..$ percent: num 5
 $ created_at : chr "2022-10-24T09:38:58"
 $ updated_at : chr "2022-10-24T09:40:02"
```

We can then write that updated model to the same location (if, say, we want to trigger a git commit based workflow) or to a new location.

### Current Holdings

In order to obtain our current holdings, we need to have an account with a broker, and we need to be able to programmatically connect to our broker. 

Our generic `get_positions`, `get_cash`, and `get_portfolio_current` functions take a single `connection` argument as an input. This input must be a list. The structure of the list can be whatever we define, but it has to have one element named `backend` that helps these functions determine which broker-specific functions to call to query the backend. 

At present, we are only implementing the `alpaca` backend. This backend works both with paper and live alpaca accounts.

You define an alpaca connection as follows:

```r
t_conn <- alpaca_connect("paper", api_key, api_secret)
```

`mode` can be either `paper`, `live` or `data`, because Alpaca implements these as separate API domains.

Here's what the `t_conn` object looks like. Note the `backend` element. The rest of the object is specific to the details of how our `alpaca_*` functions connect to the broker.

```
> t_conn
$backend
[1] "alpaca"

$domain
[1] "https://paper-api.alpaca.markets"

$headers
<request>
Headers:
* APCA-API-KEY-ID: [REDACTED]
* APCA-API-SECRET-KEY: [REDACTED]
```


Once we have our connection, we can obtain our portfolio holdings as follows:

```r
get_portfolio_current(t_conn)
```

The result is a list of two data frames, one called `cash` and the other called `assets`, which are analogous to our portfolio model elements.

```
> get_portfolio_current(t_conn)
$cash
  currency quantity
1      USD 99908.33

$assets
  symbol quantity
1   AAPL        1
2    GME        1
3     VT       -1
```

## Solve for Portfolio Changes

At this point, we have a `portfolio_model` object which specifies what portfolio holdings we desire, and we have a `portfolio_current` object which tells us what our current holdings are. 

We can use these two objects, plus some market pricing data, to work out what we need to buy or sell to align our current holdings with our desired weights.

```r
portfolio_current <- get_portfolio_current(t_conn)
portfolio_model <- read_portfolio_model("inst/extdata/sample_portfolio.yaml")
```

First we need to use the current holdings object and the model obect to create a portfolio targets object:

```r
portfolio_targets <- load_portfolio_targets(portfolio_current, portfolio_model)
```

This is just a stripped-down version of the information contained in the model and current data frames.

```
> portfolio_targets
$cash
  currency quantity_held percent_target
1      USD      99908.33             10

$assets
  symbol quantity_held percent_target
1   AAPL             1           80.5
2    GME             1            0.0
3     VT            -1            0.0
4   GOOG             0            9.5

$tolerance
$tolerance$percent
[1] 5
```

We currently have two incompatible measures of each symbol. The holdings quantity is number of shares held. The model quantity is percentage of portfolio. In order to link these two we need to translate them both into market values. To do this, we need to obtain price data on each symbol. We do this as late as possible to try minimize approximation error. 

Because alpaca uses a different domain for their market data API, we create a new connection. Then we can price our portfolio.

```r
d_conn <- alpaca_connect("data", api_key, api_secret)
portfolio_priced <- price_portfolio(portfolio_targets, "close", d_conn)
```

```
> portfolio_priced
$cash
  currency quantity_held percent_target price value_held percent_held
1      USD      99908.33             10      1   99908.33            1

$assets
  symbol quantity_held percent_target  price value_held percent_held
1   AAPL             1           80.5 143.86     143.86            0
2    GME             1            0.0  24.54      24.54            0
3     VT            -1            0.0  80.67     -80.67            0
4   GOOG             0            9.5 236.48       0.00            0
```

Now we have all the ingredients in place to solve for how each position needs to change in order to balance our portfolio.

```r
portfolio_changes <- solve_portfolio(portfolio_priced)
```

```
> portfolio_changes
$cash
  currency quantity_held percent_target price value_held percent_held
1      USD      99908.33             10     1   99908.33            1
  out_of_band optimal_value
1        TRUE      10151.88

$assets
  symbol quantity_held percent_target  price value_held percent_held
1   AAPL             1           80.5 147.27     147.27            0
2    GME             1            0.0  25.30      25.30            0
3     VT            -1            0.0  81.96     -81.96            0
4   GOOG             0            9.5 101.48       0.00            0
  out_of_band optimal_order optimal_value
1        TRUE           545      80409.42
2        TRUE            -1          0.00
3        TRUE             1          0.00
4        TRUE            93       9437.64

$tolerance
$tolerance$percent
[1] 5
```

## Generate Orders

Our `portfolio_changes` represent the frictionless changes required to balance our portfolio. However, there may not be sufficient liquidity in the market, or, worse, we may move the price of the market if our trades are large enough. So mitigate these risks, we can add some guard rails - make sure we keep our trades below a certain size, and keep our volume below a certain percentage of daily volume. 

We accomplish this with a `constrain_orders` function.

```r
order_quantities <- constrain_orders(portfolio_changes, 
                 d_conn,
                 daily_vol_pct_limit = 0.02,
                 symbol_trade_limit = 10000)
```

What's returned is a list of symbols along with their constrained order amounts and values.

```
> order_quantities
  symbol order   value
1   AAPL    66 9863.70
2    GME    -1  -24.71
3     VT     1   82.12
4   GOOG    92 9473.24
```

## Assign Trade Limits

Now we need to work out what price we are willing to pay or receive for these stock amounts. Up until now we have used yesterday's close to work out our changes. But yesterdays closing price could be quite far from where the market is currently trading at. We need to assign trade limits so that we don't pay too much (or receive too little) for our stock.

```
orders <- apply_price_limits(order_quantities, d_conn, spread_tolerance = 0.02)
```

The above function creates limit prices that are the midpoint between the last known bid and ask. The `spread_tolerance` parameter will ensure that no limit is placed if the bid-ask spread is too wide. The intention here is to prevent the placing of trades when there is little to no liquidity in the market. 

The basic usage of `apply_price_limits` creates limit prices that are close to the market price _when the market is active and the stock is liquid_. But there are many ways to determine appropriate prices. For this reason we have an `override_values` parameter. You can use this to pass in a set of arbitrary values.

```r
overrides <- get_symbols_last_closing_price(order_quantities$symbol, d_conn) %>% 
  dplyr::select(symbol, close) %>% 
  dplyr::rename(limit = close)

orders <- apply_price_limits(orders, override_values = overrides)
```
Here we see the limits:

```
> orders
  symbol order  limit   value
1   AAPL    66 149.45 9863.70
2    GME    -1  24.71  -24.71
3     VT     1  82.12   82.12
4   GOOG    92 102.97 9473.24
```

The `apply_price_limits` function is **additive**. So, you can overlay limits in a procedural manner. This is especially useful if you have a fair value conviction for a particular stock and only want to buy it if it reaches a certain price.

```r
override_apple <- data.frame(symbol = "AAPL", limit = 160)
orders <- apply_price_limits(orders, override_values = override_apple)
```

```
> orders
  symbol order  limit    value
1   AAPL    66 160.00 10560.00
2    GME    -1  24.71   -24.71
3     VT     1  82.12    82.12
4   GOOG    92 102.97  9473.24
```



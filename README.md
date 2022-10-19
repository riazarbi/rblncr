# rblncr

Declarative portfolio management with R. 

## Aspiration

It should be possible to rebalance your equity portfolio by changing the contents of a file on your computer or in a github repo.

## WIP Notice

This repo is a work in progress. The rationale for the project is covered in this [blog post](https://riazarbi.github.io/quant/portfoli-model-spec/). Everything in this repo (including this README) is likely to change dramatically as I code through the problem. 

## Basic elements

- Portfolio Model Specification  
- tooling to retrieve current holdings from broker  
- trade generation engine to compute required trades to get the current holdings to the model specification  
- trade submission tooling to actually submit trades to broker  

## Dev Steps

[ ] Develop portfolio model spec and tooling  
[ ] Select initial broker to develop against  
[ ] Write functions to obtain portfolio holdings from broker  
[ ] Build order generator  
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
4. A desired asset_weights (data frame). The `asset_weights` data frame must have three columns. `symbol`, `percent`, and `tolerance`.

In `cash` and `asset_weights`, `percent` refers to the desired percentage allocation to the respective asset. So, `percent = 30` means allocate 30% of the portfolio to the asset. `tolerance` refers to the acceptable relative level of deviation from the target percentage without triggering a trade. So, with `percent = 30` and `tolerance = 10`, your actual holding can vary by 10% of 30% (ie between 27.27% and 33%) without triggering a rebalance. 

Setting appropriate tolerances is something of an art, as it depends on the size of your portfolio, the number of allocations, and trade-offs between trade churn (which is expensive) and appropriate exposure. 

We can either create a portfolio model by creating it directly in R, or we can ust manually create a `yaml` file.

Here's how we might generate these elements:

```r
cash <- list(percent = 10, tolerance = 2)
asset_weights <- data.frame(symbol = c("AAPL","GOOG"), percent = c(80.5,9.5), tolerance = c(2,2))

sample_portfolio <- create_portfolio_model("sample_portfolio",
                             "create from function",
                             cash = list(percent = 10, tolerance = 0),
                             asset_weights)
```

Here's the actual structure of the object:

```
> str(sample_portfolio)
> str(sample_portfolio)
List of 6
 $ name       : chr "sample_portfolio"
 $ description: chr "create from function"
 $ cash       :List of 2
  ..$ percent  : num 10
  ..$ tolerance: num 0
 $ assets     :'data.frame':	2 obs. of  3 variables:
  ..$ symbol   : chr [1:2] "AAPL" "GOOG"
  ..$ percent  : num [1:2] 80.5 9.5
  ..$ tolerance: num [1:2] 2 2
 $ created_at : chr "2022-10-19T10:08:50"
 $ updated_at : chr "2022-10-19T10:08:50"
 ```

We can save the model to yaml, and we can open that file in a text editor to verify that it looks like the example above.

```r
save_portfolio_model(sample_portfolio, "inst/extdata/sample_portfolio.yaml")  
```

We can load a model from yaml

```r
loaded_model <- load_portfolio_model("inst/extdata/sample_portfolio.yaml")
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
List of 6
 $ name       : chr "port3"
 $ description: chr "create from function"
 $ cash       :List of 2
  ..$ percent  : num 10
  ..$ tolerance: num 0
 $ assets     :'data.frame':	2 obs. of  3 variables:
  ..$ symbol   : chr [1:2] "AAPL" "GOOG"
  ..$ percent  : num [1:2] 80.5 9.5
  ..$ tolerance: num [1:2] 2 2
 $ created_at : chr "2022-10-19T10:08:50"
 $ updated_at : chr "2022-10-19T10:20:00"
```

We can then write that updated model to the same location (if, say, we want to trigger a git commit based workflow) or to a new location.

### Current Holdings

In order to obtain our current holdings, we need to have an account with a broker, and we need to be able to programmatically connect to our broker. 

Our generic `get_positions`, `get_cash`, and `get_portfolio` functions take a single `connection` argument as an input. This input must be a list. The structure of the list can be whatever we define, but it has to have one element named `backend` that helps these functions determine which broker-specific functions to call to query the backend. 

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
get_portfolio(t_conn)
```

The result is a list of two data frames, one called `cash` and the other called `assets`, which are analogous to our portfolio model elements.

```
> get_portfolio(t_conn)
$cash
  currency quantity
1      USD 99908.33

$assets
  symbol quantity
1   AAPL        1
2    GME        1
3     VT       -1
```



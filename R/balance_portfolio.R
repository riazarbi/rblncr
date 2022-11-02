#' Balance portfolio
#'
#' Wrapper function to automatically rebalance a portfolio. Requires a `portfolio_model` input (see `create_portfolio_model()` or `read_portfolio_model()`), a trading connection and a data connection as a minimum (see, for example, `alpaca_connect()` although others may be supported in the future).
#'
#' @param portfolio_model a portfolio model, as created by `create_portfolio_model()`
#' @param trading_connection a connection to a trading backend
#' @param pricing_connection a connection to a data backend
#' @param min_order_size minimum trader order size
#' @param max_order_size maximum trader order size
#' @param daily_vol_pct_limit `trader()` function will not trade more than this percentage of a symbol's trailing 10 day average daily volume
#' @param pricing_spread_tolerance limit order setting function will not set a price if the bid-ask spread for a symbol is greater than this spread
#' @param pricing_overrides options. Use this to set your own symbol price limits
#' @param trader_life duration in seconds that the `trader()` should keep trading before timing out
#' @param resubmit_interval duration in seconds that a `trader()` should keep an order in the market before cancelling it and resubmitting at an updated limit price
#' @param buy_only TRUE/FALSE flag to indicate whether the `trader()` should limit itself to only buy orders
#' @param verbose TRUE/FALSE flag to indicate if the function should emit messages
#'
#' @return a list containing a `portfolio_balanced` value (TRUE/FALSE), a data frame indicating the `drift` of each symbol, and a data frame detailing the `trades` attempted.
#' @export
#' @importFrom rlang .data
#' @importFrom utils capture.output
#' @examples
#'t_conn <- alpaca_connect('paper',
#'                         Sys.getenv("ALPACA_PAPER_KEY"),
#'                         Sys.getenv("ALPACA_PAPER_SECRET"))
#'d_conn <- alpaca_connect('data',
#'                         Sys.getenv("ALPACA_LIVE_KEY"),
#'                         Sys.getenv("ALPACA_LIVE_SECRET"))
#'portfolio_model <- read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))
#'
#'balance_portfolio(portfolio_model,
#'                              t_conn,
#'                              d_conn,
#'                              verbose = F)
balance_portfolio <- function(portfolio_model,
                              trading_connection,
                              pricing_connection,
                              min_order_size = 1000,
                              max_order_size = 10000,
                              daily_vol_pct_limit = 0.02,
                              pricing_spread_tolerance = 0.02,
                              pricing_overrides = NULL,
                              trader_life = 30,
                              resubmit_interval = 5,
                              buy_only = FALSE,
                              verbose = TRUE) {

  runs <- c("TRADE", "TALLY")

  for (run in runs) {
    if(verbose){message(paste0("\n# ", run, " RUN"))}
    # check portfolio balance
    priced_portfolio <-  get_portfolio_current(trading_connection) |>
      load_portfolio_targets(portfolio_model) |>
      price_portfolio(connection = pricing_connection,
                      price_type = 'close')

    solved_portfolio <- priced_portfolio |>
      solve_portfolio(terse = F)

    asset_drift <- abs(solved_portfolio$assets$value_held / solved_portfolio$assets$optimal_value - 1)
    asset_max_drift <- max(asset_drift)
    cash_drift <- abs(solved_portfolio$cash$optimal_value / solved_portfolio$cash$value_held - 1)
    max_drift <- round(max(asset_max_drift, cash_drift) * 100, 2)

    asset_drift_df <- data.frame(symbol = solved_portfolio$assets$symbol,
                                 drift = round(100*asset_drift,2))

    if(verbose){message(paste0("MAX ASSET DRIFT: ", max_drift, "%"))}

    portfolio_balanced <- max_drift < solved_portfolio$tolerance$percent


    if(!portfolio_balanced & run == "TRADE") {

      orders <- solved_portfolio |>
        constrain_orders(pricing_connection,
                         min_order_size = min_order_size,
                         max_order_size = max_order_size,
                         daily_vol_pct_limit = daily_vol_pct_limit,
                         buy_only = buy_only)

      if(verbose){message(paste0("\nORDERS FOR THIS RUN:"))}
      if(verbose){message(paste0(utils::capture.output(orders), collapse = "\n"))}
      if(verbose){message(paste0("\n"))}

      trades <- trader(orders = orders,
                       trader_life = trader_life,
                       resubmit_interval = resubmit_interval,
                       trading_connection = trading_connection,
                       pricing_connection = pricing_connection,
                       pricing_spread_tolerance = pricing_spread_tolerance,
                       pricing_overrides = pricing_overrides,
                       verbose = verbose)

      if(verbose){message(paste0("\nORDER LOG:"))}
      if(verbose){message(paste0(utils::capture.output(trades), collapse = "\n"))}
      if(verbose){message(paste0("\n"))}

    } else if (portfolio_balanced & run == "TRADE") {
      if(verbose){message("PORTFOLIO ALREADY BALANCED.")}
      trades <- NA
    } else {
      if(verbose){message("TALLY COMPLETE.")}
      result <- list()
      result$portfolio_balanced <- portfolio_balanced
      result$drift <- asset_drift_df
      result$trades <- trades
      return(result)
    }
  }
}

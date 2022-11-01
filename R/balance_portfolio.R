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
      price_portfolio("close", pricing_connection)
    
    solved_portfolio <- priced_portfolio |>
      solve_portfolio(terse = F) 
    
    asset_drift <- abs(solved_portfolio$assets$value_held / solved_portfolio$assets$optimal_value - 1)
    asset_max_drift <- max(asset_drift)
    cash_drift <- abs(solved_portfolio$cash$optimal_value / solved_portfolio$cash$value_held - 1)
    max_drift <- round(max(asset_max_drift, cash_drift) * 100, 2)
    
    asset_drift_df <- data.frame(symbol = solved_portfolio$assets$symbol, drift = round(100*asset_drift,2)) 
    
    if(verbose){message(paste0("MAX ASSET DRIFT: ", max_drift, "%"))}
    
    portfolio_balanced <- max_drift < solved_portfolio$tolerance$percent
    
    
    if(!portfolio_balanced & run == "TRADE") {
      
      orders <- solved_portfolio |> 
        constrain_orders(pricing_connection, min_order_size = min_order_size, 
                         max_order_size = max_order_size, daily_vol_pct_limit = daily_vol_pct_limit, buy_only = buy_only) 
      
      if(verbose){message(paste0("\nORDERS FOR THIS RUN:"))}
      if(verbose){message(paste0(capture.output(orders), collapse = "\n"))}
      if(verbose){message(paste0("\n"))}
      
      overrides <- get_symbols_last_closing_price(solved_portfolio$assets$symbol, pricing_connection) |> 
        dplyr::select(symbol, close) |> 
        dplyr::rename(limit = close)
      
      trades <- trader(orders = orders,
                       trader_life = trader_life,
                       resubmit_interval = resubmit_interval,
                       trading_connection = trading_connection,
                       pricing_connection = pricing_connection,
                       pricing_spread_tolerance = pricing_spread_tolerance,
                       pricing_overrides = pricing_overrides, 
                       verbose = verbose)
      
      if(verbose){message(paste0("\nORDER LOG:"))}
      if(verbose){message(paste0(capture.output(trades), collapse = "\n"))}
      if(verbose){message(paste0("\n"))}
      
    } else if (portfolio_balanced & run == "TRADE") {
      if(verbose){message("PORTFOLIO ALREADY BALANCED.")}
      trades <- NA
    } else {
      if(verbose){message("TALLY COMPLETE.")}
      result <- list()
      result$portfolio_balanced <- portfolio_balanced
      result$max_drift <- asset_drift_df
      result$trades <- trades
      return(result)
    }
  }
}

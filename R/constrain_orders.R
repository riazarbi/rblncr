

constrain_orders <- function(solved_portfolio, 
                                        connection, 
                                        daily_vol_pct_limit = 0.02, 
                                        symbol_trade_limit = 10000,
                                        terse = TRUE) {
  # extract assets and symbols
  assets <- solved_portfolio$assets
  symbols <- solved_portfolio$assets$symbol
  
  # get some current volume and price data
  bars <- purrr::map(symbols, ~ get_symbol_10d_bars(.x, connection))
  names(bars) <- symbols
  
  # get the daily volume
  assets$daily_volume <- purrr::map_dbl(bars, ~ median(.x$volume))
  
  # work out the per-symbol constraints
  assets$volume_constraint <- floor(assets$daily_volume * daily_vol_pct_limit)
  assets$value_constraint <- symbol_trade_limit
  
  # work out the constrained trade value
  assets$value <- pmin(abs(assets$optimal_order_value), assets$value_constraint)
  # work out constrained order size
  assets$order <- floor(pmin(assets$volume_constraint, assets$value / assets$price))
  # recompute the constrained value for rounding issues
  assets$value <- assets$order * assets$price
  
  # correct the sign for sell orders
  assets$value <- ifelse(assets$optimal_order_value < 0, -assets$value, assets$value)
  assets$order <- ifelse(assets$optimal_order < 0, -assets$order, assets$order)

  # neaten up
  assets <- dplyr::relocate(assets, daily_volume, .after = price)
  assets <- dplyr::relocate(assets, value, .after = dplyr::last_col())
  
  # drop cols if terse
  if(terse) {
    assets <- dplyr::select(assets, symbol, order, value)
  }
  
  return(assets)

}

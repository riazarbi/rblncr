apply_price_limits <- function(order_quantities, connection = NA,  
                                spread_tolerance = 0.02,
                                override_values = NULL) {
  
  if (!is.null(override_values)) {
    # validation for overide_values data frame
    if(!is.data.frame(override_values)) {
      stop("param override_values must be a data frame")
    }
    if(!identical(sort(colnames(override_values)), c("limit", "symbol"))) {
      stop("column names of override_values must be 'symbol' and 'limit'")
    }
    quotes <- override_values
    
  } else {
    # or automatically split the spread
    quotes <- get_quotes(order_quantities$symbol, connection)
    quotes <- dplyr::filter(quotes, 
                            !(ask_price == 0), 
                            !(bid_price == 0), 
                            !(ask_size ==0), 
                            !(bid_size ==0))
    quotes <- dplyr::mutate(quotes, spread = (ask_price - bid_price)/ask_price)
    quotes <- dplyr::filter(quotes, spread < spread_tolerance)
    if(nrow(quotes > 0)) {
      quotes <- dplyr::mutate(quotes, limit = (ask_price + bid_price)/2)
      quotes <- dplyr::select(quotes, symbol, limit)

    } else {
      quotes <- dplyr::select(order_quantities, symbol)
      quotes$limit <- NA
    }
    
  }
  
  # at a limit column if it doesn't exist
  if(is.null(order_quantities$limit)) {
    order_quantities$limit <- NA
  }  
  
  trade_limits <- dplyr::left_join(order_quantities, quotes, by = c("symbol"))
  trade_limits <- dplyr::mutate(trade_limits, limit = ifelse(is.na(limit.y), limit.x, limit.y))
  trade_limits$value <- trade_limits$order * trade_limits$limit
  trade_limits <- dplyr::select(trade_limits, symbol, order, limit, value)
  return(trade_limits)
}

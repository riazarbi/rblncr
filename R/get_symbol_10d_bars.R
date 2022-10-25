get_symbol_10d_bars <- function(symbol, connection) {
  # backend implementations
  if(connection$backend == "alpaca") {
    dailies <- alpaca_daily_bars(symbol, 10, d_conn)
    dailies$t <- lubridate::ymd_hms(dailies$t)
    dailies <- dplyr::rename(dailies,
                             timestamp = t,
                             open= o, 
                             high = h,
                             low = l,
                             close = c,
                             volume = v,
                             trades = n,
                             vwap = vw)
    dailies <- dplyr::arrange(dailies, timestamp)
    dailies <- dplyr::filter(dailies, timestamp < lubridate::today())

  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(dailies), c("timestamp", "open", "high", "low", "close", "volume", "trades", "vwap"))
  
  if(!test) {
    stop("data validation failed")
  } else {
    return(dailies)
  }
}

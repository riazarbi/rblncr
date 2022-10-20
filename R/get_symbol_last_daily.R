

get_symbol_last_daily <- function(symbol, connection) {
  # backend implementations
  if(connection$backend == "alpaca") {
    dailies <- alpaca_daily_bars(symbol, 7, d_conn)
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
    last_daily <- tail(dailies, 1)
    last_daily <- dplyr::select(last_daily, timestamp, open, high, low, close, volume)
    
  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(last_daily), c("timestamp", "open", "high", "low", "close", "volume"))
  
  if(!test) {
    stop("data validation failed")
  } else {
    return(last_daily)
  }
}

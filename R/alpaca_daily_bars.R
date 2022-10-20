alpaca_daily_bars <- function(symbol, days, alpaca_connection) {
  start <- lubridate::now("UTC") - lubridate::days(days)
  start <- strftime(start, "%Y-%m-%dT%H:%M:%S", tz = "UTF")
  endpoint <- paste0("/v2/stocks/",symbol,"/bars?timeframe=1day&start=", start, "Z")
  result <- alpaca_query(endpoint, alpaca_connection)
  do.call(rbind.data.frame, result$bars)
}

alpaca_minute_bars <- function(symbol, minutes, alpaca_connection) {
  start <- lubridate::now("UTC") - lubridate::minutes(minutes)
  start <- strftime(start, "%Y-%m-%dT%H:%M:%S", tz = "UTF")
  endpoint <- paste0("/v2/stocks/",symbol,"/bars?timeframe=1min&start=", start, "Z")
  result <- alpaca_query(endpoint, alpaca_connection)
  result_parsed <- jsonlite::fromJSON(result, flatten = TRUE)
  result_parsed$bars
}

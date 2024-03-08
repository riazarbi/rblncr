alpaca_quote <- function(symbol, alpaca_connection) {
  endpoint <- paste0("/v2/stocks/",symbol,"/quotes/latest")
  result <- alpaca_query(endpoint, alpaca_connection)
  result_lst <- jsonlite::fromJSON(result, flatten = TRUE)
  result_lst$quote
}

alpaca_positions <- function(alpaca_connection) {
  result <- alpaca_query("/v2/positions", alpaca_connection)
  jsonlite::fromJSON(result, flatten = TRUE)
}

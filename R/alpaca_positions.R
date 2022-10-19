alpaca_positions <- function(alpaca_connection) {
  result <- alpaca_query("/v2/positions", alpaca_connection)
  do.call(rbind.data.frame, result)
}

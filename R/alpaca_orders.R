alpaca_orders <- function(alpaca_connection) {
  result <- alpaca_query("/v2/orders", alpaca_connection)
  do.call(rbind.data.frame, result)
}

alpaca_account <- function(alpaca_connection) {
  result <- alpaca_query("/v2/account", alpaca_connection)
  as.data.frame(unlist(result))
}

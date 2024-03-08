alpaca_get_orders <- function(alpaca_connection,
                              status = "open") {
  result <- alpaca_query(paste0("/v2/orders?status=",status), alpaca_connection)
  
  jsonlite::fromJSON(result, flatten = TRUE)
}

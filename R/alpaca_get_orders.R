alpaca_get_orders <- function(alpaca_connection,
                              status = "open") {
  result <- alpaca_query(paste0("/v2/orders?status=",status), alpaca_connection)
  # convert NULLs to NA
  result <- purrr::map(result, 
                       function(x) purrr::map(x, 
                                              function(y) ifelse(is.null(y),  NA, y)))
  do.call(rbind.data.frame, result)
}

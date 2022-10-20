alpaca_quote <- function(symbol, alpaca_connection) {
  endpoint <- paste0("/v2/stocks/",symbol,"/quotes/latest")
  result <- alpaca_query(endpoint, alpaca_connection)
  
  result_drop_arrays <-  purrr::list_modify(result$quote, "c" = NULL)
  as.data.frame(result_drop_arrays)
}

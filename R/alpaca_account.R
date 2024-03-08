alpaca_account <- function(alpaca_connection) {
  result <- alpaca_query("/v2/account", alpaca_connection)
  df <- jsonlite::fromJSON(paste0("[", result, "]"), flatten = TRUE)
  rownames(df) <- NULL
  return(df)
}

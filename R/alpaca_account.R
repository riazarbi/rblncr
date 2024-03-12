alpaca_account <- function(alpaca_connection) {
  result <- alpaca_query("/v2/account", alpaca_connection)
  df <- jsonlite::fromJSON(paste0("[", result, "]"), flatten = TRUE)
  rownames(df) <- NULL
  df <- dplyr::select(df, "account_number", "status", "currency", "cash", "equity", "portfolio_value")
  df <- dplyr::select(df, "account_number", "status", "currency", "cash", "equity", "portfolio_value")
  df <- dplyr::mutate(df, 
                      cash = as.numeric(cash), 
                      equity = as.numeric(equity), 
                      portfolio_value = as.numeric(portfolio_value))
  df <- validate_account_class(df)
  return(df)
}

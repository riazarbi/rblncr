ib_account <- function(ib_connection) {
  endpoint <-  paste0("/v1/api/portfolio/",ib_connection$account_id,"/meta")
  result <- ib_query(endpoint, ib_connection)
  df <- jsonlite::fromJSON(paste0("[", result, "]"), flatten = TRUE)
  rownames(df) <- NULL
  currency <- df$currency
    status <- df$clearingStatus

  # clearingStatus: String
  # Status of the Account
  # Potential Values: O: Open; P or N: Pending; A: Abandoned; R: Rejected; C: Closed.
  account_number <- ib_connection$account_id
  endpoint <-  paste0("/v1/api/portfolio/",ib_connection$account_id,"/allocation")
  result <- ib_query(endpoint, ib_connection)
    df <- jsonlite::fromJSON(paste0("[", result, "]"), flatten = TRUE)

  cash <- as.numeric(df$assetClass.long.STK)
  equity <- as.numeric(df$assetClass.long.CASH)
  portfolio_value <- cash+equity
  df <- data.frame(account_number, currency, status, cash, equity, portfolio_value)
  rownames(df) <- NULL
  df <- validate_account_class(df)
  return(df)
}

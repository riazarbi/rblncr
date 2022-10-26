get_quotes <- function(symbols, connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    quotes <- purrr::map_df(symbols, 
                            function(x) {
                              alpaca_quote(x, connection)})

    quotes$symbol <- symbols
    quotes <- dplyr::select(quotes, symbol, ap, as, bp, bs)
    quotes <- dplyr::rename(quotes, ask_price = ap, ask_size = as, bid_price = bp, bid_size = bs)

  } else {
    stop("backend connection failed")
  }
  
  # generic tests
  test <- identical(colnames(quotes), c("symbol", "ask_price", "ask_size", "bid_price", "bid_size"))
  
  if(!test) {
    stop("data validation failed")
  } else {
    return(quotes)
  }
}

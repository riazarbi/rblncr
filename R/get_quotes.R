#' Get quotes from a data backend
#'
#' @param symbols a vector of stock symbols
#' @param connection a data backend
#'
#' @return a dataframe of quotes
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr select rename
#' @importFrom purrr map_df
#'
get_quotes <- function(symbols, connection) {
  
  # backend implementations
  if(connection$backend == "alpaca") {
    quotes <- purrr::map_df(symbols,
                            function(x) {
                              alpaca_quote(x, connection)})
    
    quotes$symbol <- symbols
    quotes <- dplyr::select(quotes,
                            "symbol",
                            "ap",
                            "as",
                            "bp",
                            "bs")
    quotes <- dplyr::rename(quotes,
                            ask_price = "ap",
                            ask_size = "as",
                            bid_price = "bp",
                            bid_size = "bs")
    quotes <- dplyr::mutate(quotes,
                            across(ask_price:bid_size, as.numeric))
    
  } else {
    stop("backend connection failed")
  }
  
  # data type tests
  test1 <- all(purrr::map_chr(quotes, class) == c("character", "numeric", "numeric", "numeric", "numeric"))
  
  # generic tests
  test2 <- identical(colnames(quotes),
                     c("symbol", "ask_price", "ask_size", "bid_price", "bid_size"))
  
  test <- test1 & test2
  
  if(!test) {
    stop("data validation failed")
  } else {
    return(quotes)
  }
}


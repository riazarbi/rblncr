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
                            .data$symbol,
                            .data$ap,
                            .data$as,
                            .data$bp,
                            .data$bs)
    quotes <- dplyr::rename(quotes,
                            ask_price = .data$ap,
                            ask_size = .data$as,
                            bid_price = .data$bp,
                            bid_size = .data$bs)

  } else {
    stop("backend connection failed")
  }

  # generic tests
  test <- identical(colnames(quotes),
                    c("symbol", "ask_price", "ask_size", "bid_price", "bid_size"))

  if(!test) {
    stop("data validation failed")
  } else {
    return(quotes)
  }
}

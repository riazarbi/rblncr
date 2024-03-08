#' Get the last closig price of a vector of symbols
#'
#' @param symbols a vector of stock symbols
#' @param connection a backend data connection
#'
#' @return a data frame of last closing prices
#' @importFrom rlang .data
#' @noRd
#'
get_symbols_last_closing_price <- function(symbols, connection) {
  last_dailies <- purrr::map_df(symbols, ~ get_symbol_last_daily(.x, connection), )
  last_dailies$symbol <- symbols
  last_close <- dplyr::select(last_dailies,
                              "timestamp",
                              "symbol",
                              "close")
  return(last_close)
}

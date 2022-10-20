get_symbols_last_closing_price <- function(symbols, connection) {
  last_dailies <- purrr::map_df(symbols, ~ get_symbol_last_daily(.x, connection), )
  last_dailies$symbol <- symbols
  last_close <- dplyr::select(last_dailies, timestamp, symbol, close)
  last_close
}

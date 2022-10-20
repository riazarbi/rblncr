

price_target_symbols <- function(portfolio, portfolio_model, connection) {
  symbols <- sort(unique(c(portfolio$assets$symbol, portfolio_model$assets$symbol)))
  prices <- get_symbols_last_closing_price(symbols, connection)
  return(prices)
}

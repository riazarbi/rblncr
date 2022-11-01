

price_portfolio <- function(portfolio, price_type, connection, percent_decimal_places = 2) {
  symbols <- portfolio$assets$symbol
  if(price_type == "close") {
    prices <- get_symbols_last_closing_price(symbols, connection)
    prices <- dplyr::rename(prices, price = close)
  } else {
    stop("invalid price_type")
  }
  
  prices <- dplyr::select(prices, -timestamp)
  portfolio$assets <- dplyr::left_join(portfolio$assets, prices, by = "symbol")
  portfolio$cash$price <- 1
  
  portfolio$cash$value_held = portfolio$cash$quantity_held *portfolio$cash$price
  portfolio$assets$value_held = portfolio$assets$quantity_held *portfolio$assets$price
  
  total_value <- portfolio$cash$value_held + sum(portfolio$assets$value_held)
  
  portfolio$assets$percent_held <- 100 * round(portfolio$assets$value_held / total_value,
                                         percent_decimal_places + 2)  
  portfolio$cash$percent_held <- 100 * round(portfolio$cash$value_held / total_value,
                                       percent_decimal_places + 2) 
  
  
  return(portfolio)
}


solve_portfolio <- function(portfolio_priced, terse  = TRUE) {
  cash <- portfolio_priced$cash
  assets <- portfolio_priced$assets
  
  total_value <- cash$value + sum(assets$value)
  
  assets$percent_held <- assets$value_held / total_value * 100
  cash$percent_held <- cash$value_held / total_value * 100
  
  cash$value_target <- total_value * (cash$percent_target / 100)
  assets$value_target <- total_value * (assets$percent_target / 100)
  
  assets$quantity_target <- floor(assets$value_target / assets$price)
  cash$quantity_target <- floor(cash$value_target / cash$price)

  assets$percent_deviation <- abs((assets$value_held - assets$value_target) / assets$value_target) * 100
  cash$percent_deviation <- abs((cash$value_held - cash$value_target) / cash$value_target) * 100
  
  assets$out_of_band <- ifelse(assets$percent_deviation > portfolio_priced$tolerance, T, F)
  cash$out_of_band <- ifelse(cash$percent_deviation > portfolio_priced$tolerance, T, F)
  
  assets$optimal_order <- assets$quantity_target - assets$quantity_held
  assets$optimal_value <- (assets$quantity_held + assets$optimal_order) * assets$price
  assets$optimal_order_value <- assets$price * assets$optimal_order
  
  post_rebalancing_cash_balance <- total_value - sum(assets$optimal_value)
  cash$optimal_value <- post_rebalancing_cash_balance
  
  portfolio_priced$cash$out_of_band <- cash$out_of_band
  portfolio_priced$cash$optimal_value <- cash$optimal_value
  
  portfolio_priced$assets$out_of_band <- assets$out_of_band
  portfolio_priced$assets$optimal_order <- assets$optimal_order
  portfolio_priced$assets$optimal_order_value <- assets$optimal_order_value
  portfolio_priced$assets$optimal_value <- assets$optimal_value
  
  if(terse) {
    portfolio_priced$assets <- dplyr::select(portfolio_priced$assets, symbol, price, out_of_band, optimal_order, optimal_order_value)
    portfolio_priced$cash <- dplyr::select(portfolio_priced$cash, currency, out_of_band, optimal_value)
  }
  
  return(portfolio_priced)  
}

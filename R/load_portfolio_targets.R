

load_portfolio_targets <- function(portfolio, portfolio_model) {
  assets <- dplyr::full_join(portfolio$assets, portfolio_model$assets, by = "symbol")
  assets[is.na(assets)] <- 0
  assets <- dplyr::rename(assets, percent_target = percent)
  
  portfolio$cash$percent <- portfolio_model$cash$percent
  portfolio$cash$tolerance <- portfolio_model$cash$tolerance
  cash <- portfolio$cash
  cash[is.na(cash)] <- 0
  cash <- dplyr::rename(cash, percent_target = percent)
  
  rebalancing_frame <- list(cash = cash,
                            assets = assets) 
  
  return(rebalancing_frame)
}

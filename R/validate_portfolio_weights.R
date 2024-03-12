validate_portfolio_weights <- function(cash,
                             assets) {
  sum(assets$percent) + cash$percent == 100
}

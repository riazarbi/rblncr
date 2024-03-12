validate_portfolio_tolerance <- function(tolerance) {
  tests <- is.list(tolerance) & 
    identical(sort(names(tolerance)), c("percent")) &
    is.numeric(tolerance$percent) &
    all(tolerance$percent >= 0) &
    all(tolerance$percent <= 100) 
  
  return(tests)
}

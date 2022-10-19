validate_cash <- function(cash) {
  tests <- is.list(cash) &
    !(is.data.frame(cash)) &
    identical(sort(names(cash)), c("percent", "tolerance")) &
    cash$percent >= 0 &
    cash$percent <= 100 &
    cash$tolerance >= 0 &
    cash$tolerance <= 100 
  
  return(tests)
}

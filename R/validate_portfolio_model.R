validate_portfolio_model <- function(portfolio_model) {
  
  if(!(validate_string(portfolio_model$name))) {
    stop("name element must be a string")
  }
  if(!(validate_string(portfolio_model$description))) {
    stop("description element must be a string")
  }
  if(!validate_cash(portfolio_model$cash)) {
    stop("cash element validation failed")
  }
  
  if(!validate_assets(portfolio_model$assets)  ) {
    stop("assets element validation failed")
  }
  
  if(!(validate_weights(portfolio_model$cash, portfolio_model$assets))) {
    stop("asset weights plus cash weights don't exactly equal 100.")
  } 
  
  return(TRUE)
}

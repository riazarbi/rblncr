#' Validate a portfolio model
#'
#' @param portfolio_model a portfolio model
#'
#' @return TRUE if passed
#' @export
#' @examples
#' model <- read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))
#' validate_portfolio_model(model)
validate_portfolio_model <- function(portfolio_model) {

  
  
  if(!(validate_portfolio_elements(portfolio_model))) {
    stop("model contains unrecognised elements.")
  }

  if(!(validate_string(portfolio_model$name))) {
    stop("name element must be a string")
  }
  if(!(validate_string(portfolio_model$description))) {
    stop("description element must be a string")
  }
  if(!(validate_portfolio_cash(portfolio_model$cash))) {
    stop("cash element validation failed")
  }

  if(!validate_portfolio_assets(portfolio_model$assets)  ) {
    stop("assets element validation failed")
  }

  if(!validate_portfolio_tolerance(portfolio_model$tolerance)) {
    stop("tolerance validation failed")
  }
  if(!validate_portfolio_cooldown(portfolio_model$cooldown)) {
    stop("cooldown validation failed")
  }

  if(!(validate_portfolio_weights(portfolio_model$cash, portfolio_model$assets))) {
    stop("asset weights plus cash weights don't exactly equal 100.")
  }

  # Add class "account"
  if (!("portfolio" %in% class(portfolio_model))) {
    class(portfolio_model) <- c("portfolio", class(portfolio_model))
  }
  
  return(portfolio_model)
}

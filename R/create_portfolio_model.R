create_portfolio_model <- function(name,
                                   description,
                                   cash,
                                   assets,
                                   tolerance) {
  
  portfolio_model <- list(
    name = name,
    description = description,
    cash = cash,
    assets = assets,
    tolerance = tolerance,
    created_at = strftime(lubridate::now(tzone = "UTC"), "%Y-%m-%dT%H:%M:%S", tz = "UTF"),
    updated_at = strftime(lubridate::now(tzone = "UTC"), "%Y-%m-%dT%H:%M:%S", tz = "UTF")
    
  )
  
  validate_portfolio_model(portfolio_model)
  
  return(portfolio_model)
}

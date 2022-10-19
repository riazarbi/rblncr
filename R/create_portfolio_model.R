create_portfolio_model <- function(name,
                                   description,
                                   cash,
                                   assets) {
  
  model <- list(
    name = name,
    description = description,
    cash = cash,
    assets = assets,
    created_at = strftime(lubridate::now(tzone = "UTC"), "%Y-%m-%dT%H:%M:%S", tz = "UTF"),
    updated_at = strftime(lubridate::now(tzone = "UTC"), "%Y-%m-%dT%H:%M:%S", tz = "UTF")
    
  )
  
  validate_portfolio_model(model)
  
  return(model)
}

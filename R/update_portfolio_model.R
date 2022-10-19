update_portfolio_model <- function(portfolio_model, element_name, element_content) {
  old_port <- portfolio_model
  
  portfolio_model[[element_name]] <- element_content
  
  validate_portfolio_model(portfolio_model)
  
  if(!(identical(old_port, portfolio_model))) {
    portfolio_model$updated_at = strftime(lubridate::now(tzone = "UTC"), "%Y-%m-%dT%H:%M:%S", tz = "UTF")
    
  }
  return(portfolio_model)
}

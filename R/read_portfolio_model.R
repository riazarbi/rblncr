read_portfolio_model <- function(file_path) {
  portfolio_model  <- yaml::read_yaml(file_path)
  portfolio_model$assets <- do.call(rbind.data.frame, portfolio_model$assets)
  validate_portfolio_model(portfolio_model)
  return(portfolio_model)
}

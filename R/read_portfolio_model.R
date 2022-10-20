read_portfolio_model <- function(file_path) {
  portfolio_model  <- yaml::read_yaml(file_path)
  portfolio_model$assets <- do.call(rbind.data.frame, portfolio_model$assets)
  return(portfolio_model)
}

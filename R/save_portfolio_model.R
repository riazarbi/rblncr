save_portfolio_model <- function(portfolio_model, file_path) {
  portfolio_model$assets <- purrr::transpose(portfolio_model$assets)
  yaml::write_yaml(portfolio_model, file = file_path)
  
}

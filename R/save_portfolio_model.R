#' Save a portfolio model to disk
#'
#' @param portfolio_model a portfolio model created with `create_portfolio_model()`
#' @param file_path a file path string
#'
#' @return file_path
#' @export
#' @importFrom purrr transpose
#' @importFrom yaml write_yaml
#'
save_portfolio_model <- function(portfolio_model, file_path) {
  portfolio_model$assets <- purrr::transpose(portfolio_model$assets)
  yaml::write_yaml(portfolio_model, file = file_path)
  return(file_path)

}

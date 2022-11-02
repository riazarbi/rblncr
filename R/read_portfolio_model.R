#' Read a portfolio model from disk
#'
#' Reads a portfolio model yaml file and returns a portoflio model object
#'
#' @param file_path a file path string
#'
#' @return a portfolio model object
#' @export
#' @importFrom yaml read_yaml
#' @examples
#' read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))
#'
read_portfolio_model <- function(file_path) {
  portfolio_model  <- yaml::read_yaml(file_path)
  portfolio_model$assets <- do.call(rbind.data.frame, portfolio_model$assets)
  validate_portfolio_model(portfolio_model)
  return(portfolio_model)
}

#' Update a portfolio model
#'
#' This function allow us to make changes to a portfolio model using R tooling. An alternative approach would be to edit the yaml file directly.
#'
#' @param portfolio_model an existing portfolio model
#' @param element_name the name of the portfolio model element to replace
#' @param element_content  the new content of the element
#'
#' @return a portfolio model
#' @export
#' @importFrom lubridate now
#' @examples
#' model <- read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))
#' update_portfolio_model(model, 'tolerance', list(percent = 10))
update_portfolio_model <- function(portfolio_model, element_name, element_content) {
  old_port <- portfolio_model

  portfolio_model[[element_name]] <- element_content

  validate_portfolio_model(portfolio_model)

  if(!(identical(old_port, portfolio_model))) {
    portfolio_model$updated_at = strftime(lubridate::now(tzone = "UTC"),
                                          "%Y-%m-%dT%H:%M:%S",
                                          tz = "UTF")

  }
  return(portfolio_model)
}

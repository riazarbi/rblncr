#' Create a portfolio model
#'
#' A portfolio model specifies the target weights of a portfolio, along with drift tolerances and cooldown periods.
#'
#' @param name name of the model
#' @param description description of the model
#' @param cash cash data frame
#' @param assets assets data frame
#' @param tolerance percentage by which and symbols is permitted to drift from target weight
#' @param cooldown number of days after successful rebalance to wait before new rebalance can be triggered
#'
#' @return a portfolio model object
#' @export
#'
#' @examples
#' name <- "sample_portfolio"
#' description <- "create from function"
#' cash <- list(percent = 10)
#' assets <- data.frame(symbol = c("AAPL","GOOG"), percent = c(80.5,9.5))
#' tolerance <- list(percent = 5)
#' cooldown <- list(days = 365)
#'
#' create_portfolio_model(name = name,
#'                        description = description,
#'                        cash = cash,
#'                        assets = assets,
#'                        tolerance = tolerance,
#'                        cooldown = cooldown)
create_portfolio_model <- function(name,
                                   description,
                                   cash,
                                   assets,
                                   tolerance,
                                   cooldown) {

  portfolio_model <- list(
    name = name,
    description = description,
    cash = cash,
    assets = assets,
    tolerance = tolerance,
    cooldown = cooldown,
    created_at = strftime(lubridate::now(tzone = "UTC"), "%Y-%m-%dT%H:%M:%S", tz = "UTF"),
    updated_at = strftime(lubridate::now(tzone = "UTC"), "%Y-%m-%dT%H:%M:%S", tz = "UTF")

  )

  validate_portfolio_model(portfolio_model)

  return(portfolio_model)
}




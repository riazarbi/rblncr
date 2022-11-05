
#' Has the cooldown period for a portfolio elapsed?
#'
#' @param last_rebalance a POSIXct timestamp of the last successful rebalance activity
#'
#' @param cooldown_days number of cooldown days post a successful rebalance specified in the portfolio model
#'
#' @importFrom lubridate now days
#' @export
#' @return TRUE/FALSE
#' @examples
#' cooldown_elapsed(lubridate::now() - lubridate::days(30), 35)

cooldown_elapsed <- function(last_rebalance, cooldown_days) {

  is_datetime <- any(class(last_rebalance) %in% c("POSIXt", "POSIXct"))

  if(is.null(last_rebalance)) {
   elapsed <- TRUE
  } else if(is_datetime) {
    next_rebalance <- last_rebalance + lubridate::days(cooldown_days)
    elapsed <- next_rebalance < lubridate::now()
    } else {
    stop("last_rebalance parameter is not a datetime object.")
    }
  return(elapsed)
}





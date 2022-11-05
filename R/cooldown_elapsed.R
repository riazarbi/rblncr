#' @importFrom lubridate now days

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





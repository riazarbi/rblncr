validate_cooldown <- function(cooldown) {
  tests <- is.list(cooldown) &
    identical(sort(names(cooldown)), c("days")) &
    is.numeric(cooldown$days) &
    all(cooldown$days >= 0)

  return(tests)
}

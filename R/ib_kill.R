ib_kill <- function(ibc_process, attempts=10) {

  while (ibc_process$is_alive() & attempts > 0) {
    ibc_process$kill_tree()
    attempts = attempts-1
  }

  if (ibc_process$is_alive()) {return(FALSE)}
  else {return(TRUE)}
}

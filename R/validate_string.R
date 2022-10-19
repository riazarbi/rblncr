validate_string <- function(name) {
  if(is.character(name) & length(name) == 1) {
    return(TRUE) 
  } else {
    return(FALSE)
  }
}

validate_portfolio_elements <- function(portfolio_model) {
  tests <- all(
    names(portfolio_model) %in%
    c("assets",
      "cash",
      "cooldown",
      "created_at",
      "description",
      "name",
      "tolerance",
      "updated_at"))
  
  return(tests)
}

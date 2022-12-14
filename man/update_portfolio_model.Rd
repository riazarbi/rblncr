% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/update_portfolio_model.R
\name{update_portfolio_model}
\alias{update_portfolio_model}
\title{Update a portfolio model}
\usage{
update_portfolio_model(portfolio_model, element_name, element_content)
}
\arguments{
\item{portfolio_model}{an existing portfolio model}

\item{element_name}{the name of the portfolio model element to replace}

\item{element_content}{the new content of the element}
}
\value{
a portfolio model
}
\description{
This function allow us to make changes to a portfolio model using R tooling. An alternative approach would be to edit the yaml file directly.
}
\examples{
model <- read_portfolio_model(system.file(package='rblncr','extdata/sample_portfolio.yaml'))
update_portfolio_model(model, 'tolerance', list(percent = 10))
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fmp_get.R
\name{fmp_get}
\alias{fmp_get}
\title{Retrieve Financial Data from the Financial Modeling Prep (FMP) API}
\usage{
fmp_get(
  resource,
  symbol = NULL,
  params = list(),
  api_version = "v3",
  snake_case = TRUE
)
}
\arguments{
\item{resource}{A string indicating the API resource to query. Examples
include \code{"balance-sheet-statement"}, \code{"income-statement"},
\code{"cash-flow-statement"}, \code{"historical-market-capitalization"},
\code{"profile"}, and \code{"stock/list"}.}

\item{symbol}{A string specifying the stock ticker symbol (optional).}

\item{params}{List of additional arguments to customize the query (optional).}

\item{api_version}{A string specifying the version of the FMP API to use.
Defaults to \code{"v3"}.}

\item{snake_case}{A boolean indicating whether column names are converted
to snake_case. Defaults to \code{TRUE}.}
}
\value{
A data frame containing the processed financial data.
}
\description{
This function fetches financial data from the FMP API, including
balance sheet statements, income statements, cash flow statements,
historical market data, stock lists, and company profiles.
}
\examples{
\dontrun{
# Get available balance sheet statements
fmp_get(
  resource = "balance-sheet-statement",
  symbol = "AAPL"
)

# Get last income statements
fmp_get(
  resource = "income-statement",
  symbol = "AAPL",
  params = list(limit = 1)
)

# Get annual cash flow statements
fmp_get(
  resource = "cash-flow-statement",
  symbol = "AAPL",
  params = list(period = "annual")
)

# Get historical market capitalization
fmp_get(
  resource = "historical-market-capitalization",
  symbol = "UNH",
  params = list(from = "2023-12-01", to = "2023-12-31")
)

# Get stock list
fmp_get(
  resource = "stock/list"
)

# Get company profile
fmp_get(
  resource = "profile", symbol = "AAPL"
)

# Search for stock information
fmp_get(
  resource = "search", params = list(query = "AAP")
)

# Get data with original column names
fmp_get(
  resource = "profile", symbol = "AAPL", snake_case = FALSE
)
}

}

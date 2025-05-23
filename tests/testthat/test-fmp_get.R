# Validation tests --------------------------------------------------------

test_that("fmp_get validates limit correctly", {
  expect_error(
    fmp_get(
      resource = "balance-sheet-statement",
      symbol = "AAPL",
      params = list(limit = -1)
    ),
    "limit.*must be an integer larger than 0"
  )
  expect_error(
    fmp_get(
      resource = "balance-sheet-statement",
      symbol = "AAPL",
      params = list(limit = "ten")
    ),
    "limit.*must be an integer larger than 0"
  )
})

test_that("fmp_get validates period input", {
  expect_error(
    fmp_get(
      resource = "cash-flow-statement",
      symbol = "AAPL",
      params = list(period = "monthly")
    ),
    "period.*must be either 'annual' or 'quarter'"
  )
})

test_that("fmp_get validates symbol input", {
  expect_error(
    fmp_get(resource = "profile", symbol = c("AAPL", "MSFT")),
    "provide a single `symbol`"
  )
})

# Request handling tests --------------------------------------------------

test_that("fmp_get parses response without symbol inputs", {
  example_body <- '[
    {
      "symbol": "ABCX.US",
      "name": "AlphaBeta Corporation",
      "price": 152.35,
      "exchange": "New York Stock Exchange",
      "exchangeShortName": "NYSE",
      "type": "stock"
    },
    {
      "symbol": "GLOTECH.TO",
      "name": "Global Technologies Inc.",
      "price": 88.50,
      "exchange": "Toronto Stock Exchange",
      "exchangeShortName": "TSX",
      "type": "stock"
    }
  ]'

  my_mock <- function(req) {
    response(
      status_code = 200L,
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(example_body)
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        result <- fmp_get(resource = "stock/list")
        expect_type(result, "list")
        expect_equal(nrow(result), 2)
        expect_equal(result$symbol[1], "ABCX.US")
      }
    )
  )
})

test_that("fmp_get parses response with symbol inputs", {
  example_body <- c(
    '{
    "date": "2024-09-28",
    "symbol": "XYZC",
    "reportedCurrency": "USD",
    "cik": "0001234567",
    "fillingDate": "2024-11-01",
    "acceptedDate": "2024-11-01 06:01:36",
    "calendarYear": "2024",
    "period": "FY",
    "cashAndCashEquivalents": 67890
    }'
  )

  my_mock <- function(req) {
    response(
      status_code = 200,
      body = charToRaw(example_body),
      headers = list("Content-Type" = "application/json")
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        result <- fmp_get(resource = "balance-sheet-statement", "AAPL")
        expect_type(result, "list")
      }
    )
  )
})

test_that("perform_request throws error on non-200 response", {
  my_mock <- function(req) {
    response(
      status_code = 400,
      body = charToRaw('{"Invalid request"}'),
      headers = list("Content-Type" = "application/json")
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        expect_error(
          perform_request(resource = "invalid-resource", params = list()),
          "Invalid request"
        )
      }
    )
  )
})

test_that("perform_request handles empty responses", {
  my_mock <- function(req) {
    response(
      status_code = 200,
      body = charToRaw("[]"),
      headers = list("Content-Type" = "application/json")
    )
  }

  with_mocked_bindings(
    validate_api_key = function(...) invisible(TRUE),
    with_mocked_responses(
      my_mock,
      {
        expect_error(
          perform_request(resource = "invalid-resource", params = list()),
          "Response body is empty."
        )
      }
    )
  )
})

# Conversion tests --------------------------------------------------------

test_that("convert_column_names converts names to snake_case", {
  df <- data.frame(
    calendarYear = 2023,
    Date = "2023-12-31",
    SymbolName = "AAPL"
  )
  df_converted <- convert_column_names(df)

  expect_equal(
    names(df_converted),
    c("calendar_year", "date", "symbol_name")
  )
})


test_that("convert_column_types updates column types", {
  df <- data.frame(
    calendarYear = c("2023", "2022"),
    date = c("2023-12-31", "2022-12-31"),
    value = c(12345, 54321)
  )
  df_converted <- convert_column_types(df)

  expect_type(df_converted$calendarYear, "integer")
  expect_s3_class(df_converted$date, "Date")
  expect_type(df_converted$value, "double")
})

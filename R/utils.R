library(jsonlite)
library(R.utils)
library(zoo)
library(timeDate)
library(dplyr)
library(tibble)
library(magrittr)
library(forecast)
library(lubridate)

InferType <- function(x) {
  # Infers the type of a character object and retains its name.
  #
  # Args:
  #   x: atomic character element.
  #
  # Returns:
  #   Object of inferred type with the same name as the input

  if (!is.na(suppressWarnings(as.numeric(x)))) {
    xInferred <- as.numeric(x)
  } else if (!is.na(suppressWarnings(as.logical(x)))) {
    xInferred <- as.logical(x)
  } else {
     xInferred <- as.character(x)
  }
  names(xInferred) <- names(x)
  return(xInferred)
}

# This is the character date format used by Dataiku DSS for dates as per the ISO8601 standard.
# It is needed to parse dates from Dataiku datasets.
dkuDateFormat = "%Y-%m-%dT%T.000Z"
alternativeDateFormats = c(dkuDateFormat, "%Y-%m-%dT%T.000000Z", "%Y-%m-%dT%T")

AggregateNa <- function(x, strategy) {
  # Aggregates a numeric object in a way that is robust to missing values.
  # It can be applied in a dplyr group_by pipeline.
  #
  # Args:
  #   x: numerical array or matrix
  #   strategy: character string describing how to aggregate (one of "mean", "sum").
  #
  # Returns:
  #   Sum or average of non-missing values of x (or NA if x has no values).

  agg <- case_when(
      strategy == 'mean' ~ ifelse(all(is.na(x)), NA, mean(x, na.rm = TRUE)),
      strategy == 'sum' ~  ifelse(all(is.na(x)), NA, sum(x, na.rm = TRUE))
  )
  return(agg)
}

TruncateDate <- function(date, granularity) {
  # Truncates a date to the start of the chosen granularity.
  # It guarantees that ResampleDataframeWithTimeSeries function works at yearly/quarterly/monthly granularity.
  # Indeed they have varying lengths contrary to week/day/hour granularity.
  #
  # Args:
  #   date: object of POSIX or Date class. It can be an atomic date or an array of dates.
  #   granularity: character string (one of "year", "quarter", "month", "week", "day", "hour")
  #
  # Returns:
  #   Truncated date object. For weekly granularity, we consider that weeks start on Monday.

  tmpDate <- as.POSIXlt(date)
  outputDate <-  switch(granularity,
    year = as.Date(tmpDate) - tmpDate$yday,
    quarter = as.Date(zoo::as.yearqtr(tmpDate)),
    month = as.Date(tmpDate) - tmpDate$mday + 1,
    week = as.Date(tmpDate) - tmpDate$wday + 1,
    day = as.Date(tmpDate),
    hour = as.POSIXct(trunc(tmpDate, "hour")))
  return(outputDate)
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/time_series_plots.R
\name{ts_alos_plt}
\alias{ts_alos_plt}
\title{Plot ALOS - Average Length of Stay}
\usage{
ts_alos_plt(.data, .date_col, .value_col, .by_grouping, .interactive)
}
\arguments{
\item{.data}{The time series data you need to pass}

\item{.date_col}{The date column}

\item{.value_col}{The value column}

\item{.by_grouping}{How you want the data summarized - "sec", "min", "hour",
"day", "week", "month", "quarter" or "year"}

\item{.interactive}{TRUE or FALSE. TRUE returns a \code{plotly} plot and FALSE
returns a static \code{ggplot2} plot}
}
\value{
A timetk time series plot
}
\description{
Plot ALOS - Average Length of Stay
}
\details{
\itemize{
\item Expects a tibble with a date time column and a value column
\item Uses \code{timetk} for underlying sumarization and plot
\item If .by_grouping is missing it will default to "day"
\item A static ggplot2 object is return if the .interactive function is FALSE
otherwise a \code{plotly} plot is returned.
}
}
\examples{
set.seed(123)

suppressPackageStartupMessages(library(timetk))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(dplyr))

# Make A Series of Dates ----
ts_tbl <- tk_make_timeseries(
   start = "2019-01-01"
   , by = "day"
  , length_out = "1 year 6 months"
)

# Set Values ----
values <- runif(548, 5, 10)

# Make tibble ----
df_tbl <- tibble(x = ts_tbl, y = values) \%>\% set_names("Date","Values")

ts_alos_plt(
.data = df_tbl, .date_col = Date, .value_col = Values, .by = "month"
, .interactive = FALSE
)

}
\author{
Steven P. Sanderson II, MPH
}

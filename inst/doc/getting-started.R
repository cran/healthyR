## ---- echo = FALSE, message = FALSE, warning = FALSE--------------------------
knitr::opts_chunk$set(
    message = FALSE,
    warning = FALSE,
    fig.width = 8, 
    fig.height = 4.5,
    fig.align = 'center',
    out.width='95%', 
    dpi = 100,
    collapse = TRUE,
    comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(healthyR)

## ----random_los_data----------------------------------------------------------
set.seed(123)

# Library Load ----
if(!require(pacman)) {install.packages("pacman")}
pacman::p_load(
  "timetk"
  , "healthyR"
  , "tidyverse"
)

# Make A Series of Dates ----
ts_tbl <- tk_make_timeseries(
  start = "2019-01-01"
  , by = "day"
  , length_out = "1 year 6 months"
)

# Set Values ----
values <- runif(548, 5, 10)

# Make tibble ----
df_tbl <- tibble(x = ts_tbl, y = values) %>% set_names("Date","Values")

## ----alos_plot----------------------------------------------------------------
ts_alos_plt(
  .data = df_tbl
  , .date_col = Date
  , .value_col = Values
  , .by = "month"
  , .interactive = FALSE
)

## ----alos_plot_interactive----------------------------------------------------
ts_alos_plt(
  .data = df_tbl
  , .date_col = Date
  , .value_col = Values
  , .by = "month"
  , .interactive = TRUE
)


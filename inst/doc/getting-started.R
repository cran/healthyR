## ----echo = FALSE, message = FALSE, warning = FALSE---------------------------
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

## ----setup, warning=FALSE, message=FALSE--------------------------------------
library(healthyR)
library(healthyR.data)
library(timetk)
library(dplyr)
library(purrr)

## ----random_los_data----------------------------------------------------------
# Get Length of Stay Data
data_tbl <- healthyR_data

df_tbl <- data_tbl %>%
  filter(ip_op_flag == "I") %>%
  select(visit_end_date_time, length_of_stay) %>%
  summarise_by_time(
    .date_var = visit_end_date_time
    , .by     = "day"
    , visits  = mean(length_of_stay, na.rm = TRUE)
  ) %>%
  filter_by_time(
    .date_var     = visit_end_date_time
    , .start_date = "2012"
    , .end_date   = "2019"
  ) %>%
  set_names("Date","Values")

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


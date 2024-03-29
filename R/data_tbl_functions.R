#' Make LOS and Readmit Index Summary Tibble
#'
#' @author Steven P. Sanderson II, MPH
#'
#' @description
#' Create the length of stay and readmit index summary tibble
#'
#' @details
#' - Expects a tibble
#' - Expects the following columns and there should only be these 4
#'   * Length Of Stay Actual - Should be an integer
#'   * Length Of Stacy Benchmark - Should be an integer
#'   * Readmit Rate Actual - Should be 0/1 for each record, 1 = readmitted, 0 did not.
#'   * Readmit Rate Benchmark - Should be a percentage from the benchmark file.
#' - This will add a column called visits that will be the count of records per
#' length of stay from 1 to .max_los
#' - The .max_los param can be left blank and the function will default to 15. If
#' this is not a good default and you don't know what it should be then set it to
#' 75 percentile from the [stats::quantile()] function using the defaults, like so
#' .max_los = `stats::quantile(data_tbl$alos)[[4]]`
#' - Uses all data to compute variance, if you want it for a particular time frame
#' you will have to filter the data that goes into the .data argument. It is
#' suggested to use [timetk::filter_by_time()]
#' - The index is computed as the excess of the length of stay or readmit rates
#' over their respective expectations.
#'
#' @param .data The data you are going to analyze.
#' @param .max_los You can give a maximum LOS value. Lets say you typically do
#' not see los over 15 days, you would then set .max_los to 15 and all values greater
#' than .max_los will be grouped to .max_los
#' @param .alos_col The Average Length of Stay column
#' @param .elos_col The Expected Length of Stay column
#' @param .readmit_rate The Actual Readmit Rate column
#' @param .readmit_bench The Expected Readmit Rate column
#'
#' @examples
#'
#' suppressPackageStartupMessages(library(dplyr))
#'
#' data_tbl <- tibble(
#'   "alos"            = runif(186, 1, 20)
#'   , "elos"          = runif(186, 1, 17)
#'   , "readmit_rate"  = runif(186, 0, .25)
#'   , "readmit_bench" = runif(186, 0, .2)
#' )
#'
#' los_ra_index_summary_tbl(
#'   .data = data_tbl
#'   , .max_los       = 15
#'   , .alos_col      = alos
#'   , .elos_col      = elos
#'   , .readmit_rate  = readmit_rate
#'   , .readmit_bench = readmit_bench
#' )
#'
#' los_ra_index_summary_tbl(
#'   .data = data_tbl
#'   , .max_los       = 10
#'   , .alos_col      = alos
#'   , .elos_col      = elos
#'   , .readmit_rate  = readmit_rate
#'   , .readmit_bench = readmit_bench
#' )
#'
#' @return
#' A tibble
#'
#' @export
#'

los_ra_index_summary_tbl <- function(.data,
                                     .max_los = 15,
                                     .alos_col,
                                     .elos_col,
                                     .readmit_rate,
                                     .readmit_bench) {
    # * Tidyeval ----
    max_los_var_expr       <- .max_los
    alos_col_var_expr      <- rlang::enquo(.alos_col)
    elos_col_var_expr      <- rlang::enquo(.elos_col)
    readmit_rate_var_expr  <- rlang::enquo(.readmit_rate)
    readmit_bench_var_expr <- rlang::enquo(.readmit_bench)

    # * Checks ----
    if (!is.data.frame(.data)) {
        stop(call. = FALSE,
             "(data) is not a data-frame/tibble. Please provide.")
    }

    if (!(.max_los)) {
        max_los_var_expr = stats::quantile(!!alos_col_var_expr)[[4]]
    }

    if (rlang::quo_is_missing(alos_col_var_expr)) {
        stop(call. = FALSE, "(.alos_col) is missing. Please supply.")
    }

    if (rlang::quo_is_missing(elos_col_var_expr)) {
        stop(call. = FALSE, "(.elos_col) is missing. Please supply.")
    }

    if (rlang::quo_is_missing(readmit_rate_var_expr)) {
        stop(call. = FALSE, "(.readmit_rate) is missing. Please supply.")
    }

    if (rlang::quo_is_missing(readmit_bench_var_expr)) {
        stop(call. = FALSE, "(.readmit_bench) is missing. Please supply.")
    }

    if (ncol(.data) > 4) {
        stop(call. = FALSE, "(.data) has more than 4 columns. Please fix.")
    }

    # * Summarize and Manipulate ----
    df_tbl <- tibble::as_tibble(.data) %>%
        dplyr::mutate(alos = {
            {
                alos_col_var_expr
            }
        } %>%
            as.integer() %>%
            as.double())

    df_summary_tbl <- df_tbl %>%
        dplyr::mutate(los_group = dplyr::case_when(alos > max_los_var_expr ~ max_los_var_expr
                                                   , TRUE ~ alos)) %>%
        dplyr::group_by(los_group) %>%
        dplyr::summarise(
            tot_visits = dplyr::n(),
            tot_los  = sum(alos, na.rm = TRUE),
            tot_elos = sum({
                {
                    elos_col_var_expr
                }
            }, na.rm = TRUE)
            ,
            tot_ra   = sum({
                {
                    readmit_rate_var_expr
                }
            }, na.rm = TRUE)
            ,
            tot_perf = base::round(base::mean({
                {
                    readmit_bench_var_expr
                }
            }, na.rm = TRUE), digits = 2)
        ) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(tot_rar = dplyr::case_when(tot_ra != 0 ~ base::round((
            tot_ra / tot_visits
        ), digits = 2),
        TRUE ~ 0)) %>%
        dplyr::mutate(los_index = dplyr::case_when(tot_elos != 0 ~ (tot_los / tot_elos),
                                                   TRUE ~ 0)) %>%
        dplyr::mutate(rar_index = dplyr::case_when((tot_rar != 0 &
                                                        tot_perf != 0) ~ (tot_rar / tot_perf),
                                                   TRUE ~ 0)) %>%
        dplyr::mutate(los_ra_var = base::abs(1 - los_index) + base::abs(1 - rar_index)) %>%
        dplyr::select(los_group, los_index, rar_index, los_ra_var)

    # * Return ----
    return(df_summary_tbl)

}

#' Tibble to named list
#'
#' @author Steven P. Sanderson II, MPH
#'
#' @description
#' Takes in a data.frame/tibble and creates a named list from a supplied grouping
#' variable. Can be used in conjunction with [save_to_excel()] to create a new
#' sheet for each group of data.
#'
#' @details
#' - Requires a data.frame/tibble and a grouping column.
#'
#' @param .data The data.frame/tibble.
#' @param .group_col The column that contains the groupings.
#'
#' @examples
#' library(healthyR.data)
#'
#' df <- healthyR_data
#' df_list <- named_item_list(.data = df, .group_col = service_line)
#' df_list
#'
#' @export
#'

named_item_list <- function(.data, .group_col) {
    # * Tidyeval ----
    group_var_expr <- rlang::enquo(.group_col)

    # * Checks ----
    if (!is.data.frame(.data)) {
        stop(call. = FALSE,
             "(.data) is not a data.frame/tibble. Please supply")
    }

    if (rlang::quo_is_missing(group_var_expr)) {
        stop(call. = FALSE, "(.group_col) is missing. Please supply")
    }

    # * Manipulate ----
    data_tbl <- tibble::as_tibble(.data)

    data_tbl_list <- data_tbl %>%
        dplyr::group_split({
            {
                group_var_expr
            }
        })

    names(data_tbl_list) <- data_tbl_list %>%
        purrr::map( ~ dplyr::pull(., {
            {
                group_var_expr
            }
        })) %>%
        purrr::map( ~ base::as.character(.)) %>%
        purrr::map( ~ base::unique(.))

    # * Return ----
    return(data_tbl_list)

}

#' Counts by Category
#'
#' @author Steven P. Sanderson II, MPH
#'
#' @description
#' Get the counts of a column by a particular grouping if supplied, otherwise just
#' get counts of a column.
#'
#' @details
#' - Requires a data.frame/tibble.
#' - Requires a value column, a column that is going to counted.
#'
#' @param .data The data.frame/tibble supplied.
#' @param .count_col The column that has the values you want to count.
#' @param .arrange_value Defaults to true, this will arrange the resulting tibble
#' in descending order by .count_col
#' @param ... Place the values you want to pass in for grouping here.
#'
#' @examples
#' library(healthyR.data)
#' library(dplyr)
#'
#' healthyR_data %>%
#'   category_counts_tbl(
#'     .count_col = payer_grouping
#'     , .arrange = TRUE
#'     , ip_op_flag
#'   )
#'
#' healthyR_data %>%
#'   category_counts_tbl(
#'     .count_col = ip_op_flag
#'     , .arrange_value = TRUE
#'     , service_line
#'   )
#'
#' @export
#'

category_counts_tbl <- function(.data, .count_col,
                                .arrange_value = TRUE,
                                ...){

    # * Tidyeval ----
    count_col_var_expr <- rlang::enquo(.count_col)

    arrange_value      <- .arrange_value

    # * Checks ----
    if(!is.data.frame(.data)){
        stop(call. = FALSE,"(.data) is missing. Please supply.")
    }

    if(rlang::quo_is_missing(count_col_var_expr)){
        stop(call. = FALSE,"(.count_col) is missing. Please supply.")
    }

    # * Data ----
    data <- tibble::as_tibble(.data)

    # * Manipulate ----
    data_tbl <- data %>%
        dplyr::group_by(...) %>%
        dplyr::count({{count_col_var_expr}}) %>%
        dplyr::ungroup()

    if(arrange_value) {
        data_tbl <- data_tbl %>%
            dplyr::arrange(dplyr::desc(n))
    }

    # * Return ----
    return(data_tbl)

}

#' Top N tibble
#'
#' @author Steven P. Sanderson II, MPH
#'
#' @description
#' Get a tibble returned with n records sorted either by descending order (default) or
#' ascending order.
#'
#' @details
#' - Requires a data.frame/tibble
#' - Requires at least one column to be chosen inside of the ...
#' - Will return the tibble in sorted order that is chosen with descending as
#' the default
#'
#' @param .data The data you want to pass to the function
#' @param .n_records How many records you want returned
#' @param .arrange_value A boolean with TRUE as the default. TRUE sorts data in
#' descending order
#' @param ... The columns you want to pass to the function.
#'
#' @examples
#' library(healthyR.data)
#'
#' df <- healthyR_data
#'
#' df_tbl <- top_n_tbl(
#'   .data = df
#'   , .n_records = 3
#'   , .arrange_value = TRUE
#'   , service_line
#'   , payer_grouping
#' )
#'
#' print(df_tbl)
#'
#' @export
#'

top_n_tbl <- function(
    .data
    , .n_records
    , .arrange_value = TRUE
    , ...
) {

    # * Tidyeval ----
    top_n_var_expr <- rlang::enquo(.n_records)
    group_var_expr <- rlang::quos(...)

    arrange_value  <- .arrange_value

    # * Checks ----
    if (!is.data.frame(.data)) {
        stop(call. = FALSE, "(data) is not a data-frame/tibble. Please provide.")
    }

    if (rlang::quo_is_missing(top_n_var_expr)) {
        stop(call. = FALSE, "(.n_records) is missing. Please provide.")
    }

    # * Data ----
    data <- tibble::as_tibble(.data)

    # * Manipulate ----
    data_tbl <- data %>%
        dplyr::count(...)

    # Arrange tibble
    if(arrange_value) {
        data_tbl <- data_tbl %>%
            dplyr::arrange(dplyr::desc(n))
    }

    # Slice off n records
    data_tbl <- data_tbl %>%
        dplyr::slice(1:( {{top_n_var_expr}} ))

    # * Return ----
    return(data_tbl)

}


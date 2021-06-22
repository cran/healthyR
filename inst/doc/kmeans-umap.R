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

## ----get_data-----------------------------------------------------------------
library(healthyR.data)
library(dplyr)
library(broom)
library(ggplot2)

data_tbl <- healthyR_data %>%
    filter(ip_op_flag == "I") %>%
    filter(payer_grouping != "Medicare B") %>%
    filter(payer_grouping != "?") %>%
    select(service_line, payer_grouping) %>%
    mutate(record = 1) %>%
    as_tibble()

data_tbl %>%
  glimpse()

## ----uit----------------------------------------------------------------------
uit_tbl <- kmeans_user_item_tbl(data_tbl, service_line, payer_grouping, record)

uit_tbl

## ----kmm_tbl------------------------------------------------------------------
kmm_tbl <- kmeans_mapped_tbl(uit_tbl)

kmm_tbl

## ----kmm_tbl_glance-----------------------------------------------------------
kmm_tbl %>%
  tidyr::unnest(glance)

## ----scree_plt----------------------------------------------------------------
kmeans_scree_plt(.data = kmm_tbl)

## ----scree_data---------------------------------------------------------------
kmeans_scree_data_tbl(kmm_tbl)

## ----umap_list, message=FALSE, warning=FALSE----------------------------------
ump_lst <- umap_list(.data = uit_tbl, kmm_tbl, 3)

## ----kmeans_obj_inspect-------------------------------------------------------
km_obj <- ump_lst$kmeans_obj
kmeans_tidy_tbl(.kmeans_obj = km_obj, .data = uit_tbl, .tidy_type = "glance")

kmeans_tidy_tbl(km_obj, uit_tbl, "augment")

kmeans_tidy_tbl(km_obj, uit_tbl, "tidy")

## ----umap_plt-----------------------------------------------------------------
umap_plt(.data = ump_lst, .point_size = 3, TRUE)


#- ===================================
#- APP: api_errors
#- NAME: Global.R
#- DESCRIPTION: Source global libraries, functions, modules, etc
#- DATE: 2021-11-16
#- AUTHOR: lg
#- ==================================

library(shiny)
library(lubridate)
library(dplyr)
library(stringr)
library(DT)
library(reactable)
library(data.table)

#- source ALL files in the modules and functions directories
list.files("R/modules") %>% 
    purrr::map(~ source(paste0("R/modules/", .)))
list.files("R/functions") %>% 
    purrr::map(~ source(paste0("R/functions/", .)))

errorFile = NA  #'data/errorTest.RData'
traitFile = NA  #'data/traitsTest.RData'

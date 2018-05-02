library(RSQLite)
library(data.table)
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(countrycode)
library(plotly)


# Global Settings
DEBUG = FALSE

# Don't use absolute paths, to avoid problems in with shinyapps.io
#setwd('C:/Users/popaz/Documents/DataScience/ShinyProject2/')
source("./helpers.R")
source("./wcloud.R")

# Various debug-friendly settings, because Shiny is hard to debug. 
if(DEBUG==TRUE)
{
  options(shiny.reactlog=TRUE)
  options(shiny.trace=TRUE)
  options(shiny.error=recover)
}

dbname = "./f2015jan.sqlite"
tblname = "f2015jan"


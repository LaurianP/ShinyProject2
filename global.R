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

setwd('C:/Users/popaz/Documents/DataScience/ShinyProject/')
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



library(shiny)
library(globe4r)
library(dplyr)
library(stringr)
library(shinyWidgets)
library(globe4r)
library(GoogleTooltip)
library(mapboxer)
library(ggmap)
library(reactable)
library(OweatherR)
library(echarts4r)

key <- "AIzaSyC-L1JqEFQyWuwMiflGyA-8HRMi8K31noM"
register_google(key)

set_weather_key("7ade3673d5e34cd670eaeeae0209c16d")

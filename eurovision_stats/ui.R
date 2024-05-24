library(shiny)
library(shinyWidgets)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(plotly)
library(ggiraph)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = div(
    style = "display: flex; align-items: baseline; justify-content: center; margin-top: 2px;",
    div("EUROVISION", style = "color: #FFF400; font-size: 14px; font-weight: 700; font-family: 'Cantarell', sans-serif; margin-right: 10px;"),
    div("STATISTICS", style = "color: white; font-size: 14px; font-weight: 400; font-family: 'Cantarell', sans-serif;")
  )),
  dashboardSidebar(
    # main page
    # maybe some other pages
  ),
  dashboardBody(
    includeCSS("www/style.css"),
    fluidRow(column(
      width = 10,
      div(
        style = "display: flex; align-items: baseline; justify-content: left; margin-top: 1px;",
        div("EUROVISION", style = "color: #FFF400; font-size: 30px; font-weight: 700; font-family: 'Cantarell', sans-serif; margin-right: 10px;"),
        div("STATISTICS", style = "color: white; font-size: 30px; font-weight: 400; font-family: 'Cantarell', sans-serif;")
      )
    )),
    fluidRow(splitLayout(
      box(
        title = "The Most Frequent Eurovision Hosts", 
        width = 10,
        girafeOutput("map")
      ),
      box(
        title = "The Most Common Language In Eurovision Songs", 
        width = 10,
        girafeOutput("circles")
    ))
  )
)
)

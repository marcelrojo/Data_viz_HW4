library(shiny)
library(shinyWidgets)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(plotly)
library(ggiraph)
library(shinydashboard)
library(highcharter)

data_UI<-read.csv("datasets/eurovision_results.csv")
Countries_list<-sort(unique(data_UI$Country))
Years_list<-data_UI$Year
Places_list<-sort(as.numeric(unique(data_UI$Grand.Final.Place)))

dashboardPage(
  dashboardHeader(
    title = div(
      style = "display: flex; align-items: baseline; justify-content: center; margin-top: 2px;",
      div("EUROVISION", style = "color: #FFF400; font-size: 14px; font-weight: 700; font-family: 'Cantarell', sans-serif; margin-right: 10px;"),
      div("STATISTICS", style = "color: white; font-size: 14px; font-weight: 400; font-family: 'Cantarell', sans-serif;")
    )
  ),
  dashboardSidebar(
    includeCSS("www/style.css"),
    sidebarMenu(
      id = "tabs",  # Add an ID for the tab menu
      selected = "main",  # Set the default selected tab
      menuItem("Main Page", tabName = "main"),
      menuItem("Most Points Received", tabName = "most_points"),
      menuItem("Country Placements", tabName = "placements")
      # maybe some other pages
    )
  ),
  dashboardBody(tabItems(
    tabItem(
      tabName = "main",
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
        box(title = "The Most Frequent Eurovision Hosts",
            width = 8.9,
            girafeOutput("map")),
        box(title = "The Most Common Language In Eurovision Songs",
            width = 12,
            girafeOutput("circles")),
        box(
          title = "Winners And Their Songs",
          width = 12,
          highchartOutput("winners")
        ),
      )),
      fluidRow(splitLayout(valueBoxOutput("contests")))
    ),
    tabItem(
      tabName = "most_points",
      includeCSS("www/style.css"),
      fluidRow(column(
        width = 10,
        div(
          style = "display: flex; align-items: baseline; justify-content: left; margin-top: 1px;",
          div("EUROVISION", style = "color: #FFF400; font-size: 30px; font-weight: 700; font-family: 'Cantarell', sans-serif; margin-right: 10px;"),
          div("STATISTICS", style = "color: white; font-size: 30px; font-weight: 400; font-family: 'Cantarell', sans-serif;")
        )
      )),
      fluidRow(
        column(
          width = 4,
          box(selectInput(
            "select",
            "Select a time-period:",
            choices = list("1975 - 2003", "2004 - 2015", "2016 - 2024"),
            selected = c(1975, 2003)
          ),
          height = 180,
          width= 70),
          box(title = "Voting Format Description",
            textOutput("description"),
            width=70)
          
        ),
        column(
          width = 8,
          box(title = "Most Points Received",
              width = 12,
              girafeOutput("points"))
        )
      )
    ),
    tabItem(
      tabName = "placements",
      includeCSS("www/style.css"),
      fluidRow(column(
        width = 10,
        div(
          style = "display: flex; align-items: baseline; justify-content: left; margin-top: 1px;",
          div("EUROVISION", style = "color: #FFF400; font-size: 30px; font-weight: 700; font-family: 'Cantarell', sans-serif; margin-right: 10px;"),
          div("STATISTICS", style = "color: white; font-size: 30px; font-weight: 400; font-family: 'Cantarell', sans-serif;")
        )
      )),
      fluidRow(
        column(
          width = 4,
          box(
            selectInput("countries", "Select Countries:", choices = unique(Countries_list),
                        selected="Poland", multiple = TRUE),
            sliderInput("years", "Select Year Range:", 
                        min = min(Years_list),
                        max = max(Years_list),
                        value = c(min(Years_list), 
                                  max(Years_list)), 
                        step = 1, 
                        sep = ""),
            sliderInput("places", "Select Placement Range:", 
                        min = min(Places_list),
                        max = max(Places_list),
                        value = c(min(Places_list), 
                                  max(Places_list)), 
                        step = 1, sep = ""),
            height = 300,
            width = 12
          )),
        column(
          width=8,
          box(title = "Change of Placements Over Time",
              width = 12,
              girafeOutput("placements_plot")
              )
          
        ))
    )
    
  ))
)

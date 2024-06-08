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
      id = "tabs",  
      selected = "main",  
      menuItem("Main Page", tabName = "main"),
      menuItem("Most Points Received", tabName = "most_points"),
      menuItem("Country Placements", tabName = "placements"),
      menuItem("Country Participation Details", tabName = "participation")
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
      fluidRow(
        column(
          width=12,
          tags$img(src = "Eurovision_generic_white.png", height = "100px", style = "display: block; margin: 0 auto; margin-bottom: 10px")
        ),
        column(
          width=4,
          box(
            title = "The Most Frequent Eurovision Hosts",
            width = 12,
            height= 475,
            girafeOutput("map")
          )
        ),
        column(
          width=4,
          box(
            title = "The Most Frequent Eurovision Song Languages",
            width = 12,
            height= 475,
            girafeOutput("circles")
          )
        ),
        column(
          width=4,
          box(
            title = "Winners And Their Songs",
            width = 12,
            height= 475,
            highchartOutput("winners")
          )
      ))
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
          width = 2
        ),
        column(
          width = 6,
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
          width = 2
        ),
        column(
          width=6,
          box(title = "Change of Placements Over Time",
              width = 12,
              girafeOutput("placements_plot")
              )
          
        ))
    ),
    tabItem(
      tabName = "participation",
      includeCSS("www/style.css"),
      fluidRow(column(
        width = 10,
        div(
          style = "display: flex; align-items: baseline; justify-content: left; margin-top: 1px;",
          div("EUROVISION", style = "color: #FFF400; font-size: 30px; font-weight: 700; font-family: 'Cantarell', sans-serif; margin-right: 10px;"),
          div("STATISTICS", style = "color: white; font-size: 30px; font-weight: 400; font-family: 'Cantarell', sans-serif;")
        )
      )),
      fluidRow(column(width = 4,
                      box(
                        checkboxGroupInput(
                          "continent",
                          "Select Continents: ",
                          choices = c(
                            "Europe" = "europe",
                            "Asia" = "asia",
                            "Africa" = "africa",
                            "Oceania" = "oceania"
                          ),
                          selected = c("europe", "asia", "africa", "oceania")
                        ),
                      )),
               column(width=6,
                      box(title = "Countries Participation Datatable",
                          width = 12,
                          reactableOutput("countries_table")
                      )))
    )
    
  ))
)

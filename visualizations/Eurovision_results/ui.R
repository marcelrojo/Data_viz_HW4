library(shiny)
library(ggiraph)

ui <- fluidPage(
  titlePanel("Eurovision Results"),
  sidebarLayout(
    sidebarPanel(
      selectInput("countries", "Select up to 5 countries:", choices = unique(data$Country), multiple = TRUE),
      sliderInput("years", "Select Year Range:", min = min(data$Year), max = max(data$Year),
                  value = c(min(data$Year), max(data$Year)), step = 1, sep = "")
    ),
    mainPanel(
      girafeOutput("eurovision_plot")
    )
  )
)
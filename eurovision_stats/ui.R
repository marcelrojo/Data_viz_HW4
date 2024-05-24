library(shiny)
library(shinyWidgets)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(plotly)
library(ggiraph)

fluidPage(# ------> Custom CSS - font from google fonts <------
          tags$style(
            HTML(
              "
          @import url('https://fonts.googleapis.com/css2?family=Cantarell:ital,wght@0,400;0,700;1,400;1,700&display=swap');
          body {
          	background-color: #010039;
           	color: white;
          }

          h2 {
          	font-family: 'Cantarell', sans-serif;
          }

          .shiny-input-container {
          	color: white;
          }"
            )
          ),
          
          # ------> Application title <------
          titlePanel(div(
            style = "display: flex; align-items: baseline;",
            div("EUROVISION", style = "color: #FFF400; font-size: 30px; font-weight: 700; font-family: 'Cantarell', sans-serif; margin-right: 10px;"),
            div("STATISTICS", style = "color: white; font-size: 30px; font-weight: 400; font-family: 'Cantarell', sans-serif;")
          )),
          # sidebarLayout(
          #   sidebarPanel(
          #     # You can add input elements here if needed
          #   ),
          #   mainPanel(
          #     girafeOutput("map")
          #   )
          # ),
          splitLayout(
            girafeOutput("map"),
            girafeOutput("circles")
          )
          )












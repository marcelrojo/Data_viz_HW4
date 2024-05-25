library(shiny)
library(ggplot2)
library(plotly)
library(ggiraph)
library(ggflags)
library(countrycode)

data <- read.csv("eurovision_results.csv")

# Convert necessary columns
data <- data[!is.na(data$Grand.Final.Place), ]
data$Year <- as.numeric(data$Year)
data$Grand.Final.Place <- as.numeric(data$Grand.Final.Place)
data$Country <- factor(data$Country)
data$Code <- tolower(countrycode(data$Country, "country.name", "iso2c"))

custom_colors <- c(
  "#fff800",
  "#ff0188",
  "#0043fe",
  "#aed258",
  "#ff7815"
)

server <- function(input, output) {
  output$eurovision_plot <- renderGirafe({
    # Filter data based on selected country
    selected_data <- subset(data, Country %in% input$countries & Year >= input$years[1] & Year <= input$years[2])
    
    # Plot selected data
    p <- ggplot(selected_data, aes(x = Year, y = Grand.Final.Place, group = Country, color = Country, fill=Country)) +
      geom_line(size = 1.5) +
      geom_point_interactive(aes(tooltip=paste0("Country: ", Country, "<br>",
                                                "Year: ", Year, "<br>",
                                                "Place: ", Grand.Final.Place, "<br>",
                                                "\"", Song, "\" by ", Artist)), size = 9.5, alpha=1) + # Plot all places as small circles
      geom_flag(aes(country = Code, color = Country), size = 8) +      
      scale_shape_manual(name = "", values = 16) + # Change shape to a circle
      scale_fill_manual(values = custom_colors) +
      scale_color_manual(values = custom_colors) +
      scale_y_reverse(name = "Place", breaks = seq(1, max(selected_data$Grand.Final.Place, na.rm = TRUE), 1)) +
      labs(title = "Changes in Eurovision Grand Final Places Over Time",
           x = "Year",
           y = "Place") +
      theme_minimal() +
      theme(legend.position = "none",
            panel.background = element_rect(fill = "#010039"),
            plot.background = element_rect(fill = "#010039"),
            plot.title = element_text(color = "white", size = 20, hjust = 0.5),
            axis.text = element_text(color = "white", size = 14, face = "bold"),
            panel.grid.minor.y = element_blank(),
            panel.grid.minor.x = element_blank())
    
    widg <- girafe(ggobj = p, width_svg = 10, height_svg = 10)
    widg
  })
}
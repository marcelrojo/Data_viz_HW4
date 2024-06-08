library(rnaturalearth)
library(sf)
library(ggiraph)

results <- read.csv("datasets/eurovision_results.csv")
events <- read.csv("datasets/events_info.csv")

# EUROPE MAP DATA -------------------------------------------------------------
eurovision_countries <- c(
  "Albania", "Andorra", "Armenia", "Australia", "Austria", "Azerbaijan", 
  "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", 
  "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", 
  "Georgia", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Israel", 
  "Italy", "Kazakhstan", "Kosovo", "Latvia", "Lithuania", "Luxembourg", 
  "Malta", "Moldova", "Monaco", "Montenegro", "Morocco", "Netherlands", 
  "North Macedonia", "Norway", "Poland", "Portugal", "Romania", "Russia", 
  "San Marino", "Serbia", "Serbia and Montenegro", "Slovakia", "Slovenia", 
  "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "United Kingdom", 
  "Yugoslavia"
)
europe <- ne_countries(scale = "medium", returnclass = "sf", country = eurovision_countries)
number_of_times_hosting <- events %>%
                           group_by(Country) %>%
                           summarise(n = n())
europe['events'] <- number_of_times_hosting$n[match(europe$name, number_of_times_hosting$Country)] %>%
                   replace_na(0) %>%
                   as.factor()
data.frame(europe$name, europe$event)
custom_colors_map = rev(c("#6B10C5","#d9009b","#ff1e6e","#FF7814","#ffa65b","#ffd254","#f9f871","lightgrey"))

map_viz <-  ggplot(europe) +
            geom_sf_interactive(aes(fill = events, tooltip = paste("Country: ", name, "\n", 
                                                                   "Number of hosted events: ", events)),
                                color = "white") +
            theme_void() +
            scale_fill_manual(values = custom_colors_map) +
            coord_sf(xlim = c(-25, 50),
                     ylim = c(35, 70),
                     expand = FALSE) +
            theme(
              legend.position = "none",
              panel.background = element_rect(fill = "#010039"),
              plot.background = element_rect(fill = "#010039"),
              plot.margin = unit(c(0, 0, 0, 0), 'cm')
            )

girafe_map_viz <- girafe(ggobj = map_viz,
                         width_svg = 2*8.9,
                         height_svg = 2*6.8436,
                         options = list(opts_sizing(rescale = T)))

function(input, output, session) { 
  # VALUE BOX ------------------------------------------------------------------
  output$contests <- renderValueBox({
    valueBox(
      value = paste(nrow(results)),
      subtitle = "ESC hass been held annuualy for almost 70 years!",
      icon = icon("trophy"),
      color = "fuchsia"
    )
  })
  # EUROPE MAP -----------------------------------------------------------------
  output$map <- renderGirafe({
    girafe_map_viz
  })
  # LANGUAGES CIRCLES --------------------------------------------------------------------
  
}

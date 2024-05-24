library(shiny)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(plotly)
library(ggiraph)
library(ggplot2)
library(packcircles)


function(input, output, session) {
  # the map visualization
  output$map <- renderGirafe({
    results = read.csv("datasets/eurovision_results.csv")
    events = read.csv("datasets/events_info.csv")
    world <- ne_countries(scale = "medium", returnclass = "sf")
    hosting <- events %>%
      group_by(Country) %>%
      summarise(n = n()) %>%
      arrange(desc(n))
    
    world['events'] <- hosting$n[match(world$name, hosting$Country)]
    data.frame(world$name, world$events)
    
    world$events[is.na(world$events)] <- 0
    world$events <- as.factor(world$events)
    
    Europe <- world[which(world$continent == "Europe"), ]
    custom_colors = rev(
      c(
        "#6B10C5",
        "#d9009b",
        "#ff1e6e",
        "#FF7814",
        "#ffa65b",
        "#ffd254",
        "#f9f871",
        "lightgrey"
      )
    )
    p <- ggplot(world) +
      geom_sf_interactive(aes(
        fill = events,
        tooltip = paste('Country: ', name, '\n',
                        'Number of events hosted: ', events)),
      color = 'white',
      size = 0.6) +
      theme_void() +
      scale_fill_manual(values = custom_colors) +
      coord_sf(xlim = c(-25, 50),
               ylim = c(35, 70),
               expand = FALSE) +
      labs(fill = "Number of events",
           title = "Which Countries Have Been the Most Frequent Eurovision Hosts?") +
      theme(legend.position = "null",
            panel.background = element_rect(fill = "#010039"),
            plot.background = element_rect(fill = "#010039"),
            plot.title = element_text(color = "white", size = 20, hjust = 0.5))
    girafe(ggobj = p, width_svg = 10, height_svg = 8)
  })
  
  # the language visualization
  output$circles <- renderGirafe({
    results = read.csv("datasets/eurovision_results.csv")
    # prepare datafreame
    country_lang = data.frame(country = results$Country, lang = results$Language)
    country_lang$lang = gsub(" ", "", country_lang$lang)
    freq_table = table(unlist(strsplit(country_lang$lang, ",")))
    prop_table = prop.table(freq_table)
    lang_freq = data.frame(freq_table)
    lang_count = data.frame(prop_table)
    lang_count$Count = lang_freq$Freq
    colnames(lang_count) = c("Language", "Proportion", "Count")
    lang_count$Proportion = round(lang_count$Proportion * 100, 2)
    lang_count = lang_count[lang_count$Proportion > 3.0,]
    
    # prepare the circles 
    packing <- circleProgressiveLayout(lang_count$Proportion, sizetype='area')
    data <- cbind(lang_count, packing)
    data$text <- paste("Language: ",data$Language, "\n", "Proportion: ", data$Proportion, "\n", 
                       "Proportion of ", data$Language, 
                       " eurovision songs is ", data$Proportion, 
                       ", that is ", data$Count, " songs.")
    dat.gg <- circleLayoutVertices(packing, npoints=50)
    
    custom_colors <- c(
      "#6B10C5",
      "#aa20ab",  
      "#d9009b",
      "#ff1e6e",
      "#ff5f49",  
      "#FF7814",
      "#ff9e35",  
      "#ffa65b",
      "#ffd254",
      "#f9f871"
    )
    dat.gg$id <- as.factor(dat.gg$id)
    p <- ggplot() + 
      geom_polygon_interactive(data = dat.gg, aes(x, y, group = id, fill=id, tooltip = data$text[id])) +
      geom_text(data = data, aes(x, y, size=Proportion, label = Language), color = "white") +
      scale_fill_manual(values = custom_colors) +
      scale_size_continuous(range = c(3,7)) +
      theme_void() + 
      coord_equal() +
      labs(title = "What Is The Most Common Language In Eurovision Songs?") +
      theme(legend.position = "null",
            panel.background = element_rect(fill = "#010039"),
            plot.background = element_rect(fill = "#010039"),
            plot.title = element_text(color = "white", size = 20, hjust = 0.5))
    
    widg <- girafe(ggobj = p, width_svg = 10, height_svg = 10)
  })
  
}
